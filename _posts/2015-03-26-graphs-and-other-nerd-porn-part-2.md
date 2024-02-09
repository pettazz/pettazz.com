---
layout: post
published: true
title: Graphs and Other Nerd Porn, Part 2
tagline: "Now that I can see how hot my server is, I want to see what the hell is causing it."
tags: [blag, ubuntu, server, cacti, rrdtool, sensors, plex, linux, graphs, mysql]
comments: true
image: nerd_porn_graphs.png
---


> Previously, on Graphs and Other Nerd Porn: [Part 1](/graphs-and-other-nerd-porn)
{: .notice}

So here I am, with a bunch of graphs showing me that once in a while on my server, the load average goes up and the temperature follows. Big damn deal. What good is any of this if I can't get some kind of insight into what's causing it? I mean, what am I going to do if the temp graph suddenly shows 80, go get an ice pack and put it on top of the power supply? 

![Extra Cooling](http://i.imgur.com/VruQNty.jpg "Other solutions proved inconvenient.")

I need some kind of visibility into what is generating all that load. Luckily, I think I know exactly what it is.

[PLEX](http://plex.tv) is a marvel of modern technology. The days of converting videos to put on your iPod are over. Well, I mean, technically, they're still here. But we don't have to give a shit anymore. PLEX handles all the transcoding per client into a format that the device can play, all while maintaining quality. It's pretty spectacular, but also can be fairly resource intensive, since all this work gets done on the server in chunks as the video is being streamed to the client. ffmpeg doesn't natively support any real GPU accelerated transcoding, so this is all CPU-bound. Add onto this the fact that I hand out shared access to my PLEX server like a drunken grandma hands out full size candy bars on Halloween, and you have a recipe for some serious CPU load. 

Given that this is almost definitely the main culprit behind the recent heat-related issues facing my friend Alonso, I thought it would be a good idea to add this to the graph. As it turns out, once you've gone through the 907-step process of creating a graph once, it starts to be pretty straightforward.

### 1. The Data Source

We need to feed our data into Cacti so that it can start graphing it. Conveniently for us, we don't have to go through the trouble of figuring out not only how to obtain the data we need but also aggregating it into an rrd, because Cacti can do it all for us if we produce an output that matches its incredibly simple data format. [From the Cacti Manual](http://www.cacti.net/downloads/docs/html/making_scripts_work_with_cacti.html):

{% highlight bash %}
<fieldname_1>:<value_1> <fieldname_2>:<value_2> ... <fieldname_n>:<value_n>
{% endhighlight %}

Easy enough, especially when we're only graphing a single field. Using the absurdly convenient [plexapi python module](https://github.com/mjs7231/plexapi), writing a script to output the current number of active PLEX transcode¹ sessions becomes just about trivial:

{% highlight python %}
#!/usr/bin/env python
from plexapi.myplex import MyPlexUser

user = MyPlexUser.signin('myplexusername', 'myplexpassword')
plex = user.getServer('osto.us').connect()

sessions = plex.query('/status/sessions')
print 'sessions:' + sessions.get('size')
{% endhighlight %}

> ¹ I realize that a PLEX session doesn't necessarily equal a transcode session, but I'd rather include every streaming session in the graph than exclude anything potentially useful. It still uses CPU, and I don't want to be desperately grepping syslog about a spike in load because my graph excludes the sixteen people streaming a 4K movie over Direct Play.
{: .notice}

Slap a ``chmod +x`` on there and drop it into ``/usr/local/bin/``, and my data source is ready to serve.

### 2. The Graph

#### Data Input Method

First, we need to create a new Data Input Method for this source. From Console > Data Input Methods > Add, we can give it a name, tell Cacti that this is a Script/Command, and then give it the full path to the script to run. Once saved, we need to add Output Field that matches the exact field name in the script's output, and enable updating the RRD. 

![Plex Sessions Data Input Method](https://www.evernote.com/shard/s2/sh/90be8493-58e3-40c8-8bcf-07df76e77cc1/74fe1d86951ed7258fb3e4372e3a0a93/deep/0/Console----Data-Input-Methods----(Edit).png "That's right, do all the hard work for me. Good Cacti.")

#### Data Template

The next few steps are essentially plumbing to hook up our new Data Input Method to the graph.

From Console > Data Template > Add, we can set up the details of how the data is fed into any graph that uses it: give it a useful name, give our Data Source the kind of name that would go well on a graph, and then select our newly created Data Input Method and mark it as active. This time, we only need to add one Data Source Item, using the same field name again for Internal Data Source Name and the Output Field we added in the previous step.

![Plex Sessions Data Template](https://www.evernote.com/shard/s2/sh/a2e0549b-f40b-4a25-89db-536b5d04921e/806a0aff2879a6e4fb5b8c4be304c49f/deep/0/Console----Data-Templates----(Edit).png "Feed me data.")

#### Graph Template

Next up, we need to add a graph template at Console > Graph Templates > Add. Aside from Name, Title, and Vertical Label (sessions), all the defaults of the Template are acceptable, and we can save and move right on to adding the Template Items. We only need to add one AREA Item to graph our sessions, so we select our new Data Source from the previous step, a super attractive color, and make sure the Type is AREA and the CF is Average. After this, we can add a second Item using the same sessions Data Source, but choosing the LEGEND Type, which will automagically create three GPRINT Items to show the Current, Average, and Max values on the graph's legend. 

![Plex Sessions Graph Template](https://www.evernote.com/shard/s2/sh/58b615a1-dbfb-44ab-934c-fd690c1f461e/f282e9fe03187542bdca28a3902c8209/deep/0/Console----Graph-Templates----(Edit).png "Go ahead and fuck around with the rest if you're brave.")

#### Graph, Like, For Real

Time to add our sweet new graph. Console > Create > New Graphs gives us the option to select our new Template from the Create dropdown, and that is that. The first data starts flowing after 5 minutes, and a few days later, we're practically swimming in data.

![DATA FOR DAYS](https://www.evernote.com/shard/s2/sh/c4225699-09c1-404d-bb4a-0ae6a7a3181b/a859223e82dfde25b5bce55e7bb50301/deep/0/Graphs----Tree-Mode.png "But seriously what the fuck is that 2am spike?")

Suddenly, my graphs are showing me some realistically useful information. I can see a trend of load average and temperature spikes that clearly relate to PLEX transcoding chunks of video for active sessions. So, the next time Alonso is yelling at me in my living room, I can pretty clearly see that I need to kick some friends off and just pretend we had a power outage or something. 

Now, if I could only figure out what the hell is going on at 2am...