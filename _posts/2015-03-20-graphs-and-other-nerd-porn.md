---
layout: post
published: true
title: Graphs and Other Nerd Porn
excerpt: "I got bored and decided I wanted to know how hot my server gets. Spoilers: I installed a bunch of shit and I still don't really know."
tags: [blag, ubuntu, server, cacti, rrdtool, sensors, plex, linux, graphs, mysql]
comments: true
image:
  feature: nerd_porn_graphs.png
---


There's a guy named Alonso who lives in my living room, and lately he's been making a lot more noise than he used to. He's actually an Ubuntu Server who runs my instances of [PLEX](http://plex.tv) and [Sonarr](http://sonarr.tv), so it's a little less weird but still makes me worry. His fans used to run at a pretty constant rate until recently when he started interrupting my favorite shows by preparing for takeoff and setting his fans to Max Power.

![MAX POWER](http://i.imgur.com/Iq1Y0Hl.jpg "But you mustn't touch!")

So I decided to get some logging on things like CPU/Memory usage, temperatures, and fan speeds to maybe try to figure out what's going on in Alonso's guts. After a solid 12 seconds of googling, the majority of StackOverflow seems to roll with lm-sensors, RRDTool, and Cacti. And who am I to argue with them? 

### Installing Junk

#### 1. lm-sensors

The first thing we need is an interface to the actual sensors, and the [lm-sensors](http://www.lm-sensors.org/) package does exactly that, plus sensord, a daemon for logging the data. 

{% highlight bash %}
$ sudo apt-get install lm-sensors sensord
{% endhighlight %}

Well that was easy. I bet the configuration is hard though.

{% highlight bash %}
$ sudo sensors-detect
{% endhighlight %}

Well, fuck. I'm going to be watching live graphs in no time. 

{% highlight bash %}
$ watch -dc sensors
{% endhighlight %}

Nope, gross. Not done yet.

#### 2. RRDTool

{% highlight bash %}
$ sudo apt-get install rrdtool
{% endhighlight %}

This isn't even fun anymore. Where's the challenge?

#### 3. Cacti

{% highlight bash %}
$ sudo apt-get install cacti-spine
{% endhighlight %}

![Passwords are hard](/images/mysql_passwords.png "Maybe if I try typing it one more time...")

Oh, I found that challenge. I forgot the MySQL root password, and it doesn't seem to be blank or any of the ones I commonly use. Welp.

#### 3. <strike>Cacti</strike> Resetting MySQL root Password

Luckily for me, MySQL really doesn't give a shit what you want to do to it, as long as you're root. 

{% highlight bash %}
$ sudo service mysql stop
$ sudo mysqld_safe --skip-grant-tables --skip-networking &
$ mysql -u root
mysql> UPDATE mysql.user SET Password=PASSWORD('MyNewPass') WHERE User='root';
mysql> FLUSH PRIVILEGES;
mysql> exit;
$ sudo kilall mysqld_safe
$ sudo service mysql start
{% endhighlight %}

Yep. Just start that server up with the ``--skip-grant-tables`` option, and suddenly there's no such thing as permissions, privileges, or even passwords. You probably don't want to be exposing your server to the internet in this kind of state, so mysqld_safe and ``--skip-networking`` have got your back. Then, since MySQL conveniently uses MySQL databases for its own data, you can just alter the mysql.user entry for root with your new password. Flush privileges and restart normally, and the problem is solved. Now, if you're an idiot like me, you can switch back to your tab where Cacti is trying to configure the database and give it a real password, pretending nothing ever happened. 

#### 4. Cacti

"Uh, yeah, Cacti. Sorry, had to go do...some work. Yeah. Real busy. Here's that password I *definitely* know and have known forever."

{% highlight bash %}
$ sudo apt-get install cacti-spine
{% endhighlight %}

Cool.

### Setting Up Junk

For this post, the server address is going to be ``http://butts.lol``, which you should replace in any of these examples with your own server's real one, because obviously is not your server's address. Unless it is. In which case sell that to me now. I *deserve* it more than you ever will.
{: .notice}

#### Cacti

Cacti has its own installation tool, which you should now be able to find at ``http://butts.lol/cacti``. It steps through a few simple configuration options, such as choosing whether this is a new installation, and configuring paths to binaries. If everything above installed correctly, this should all be pre-filled properly. Click Finish, create your new admin password, and hope for the best. 

I won't go into details of the Cacti dashboard and configuring views and users here, because it's not exactly complicated, and it's basically just a matter of picking which nerd porn you want to see, and because writing *just pick the goddamned options you want, what am I, your dad?* over and over doesn't seem like a lot of fun. Just check out the Console tab and you'll find a bunch of existing ones you can just turn on, like memory usage and even disk space on a mounted partition. Trust me, you'll figure it out.

#### sensord

Sensord by default doesn't really do anything but spit sensor output into syslog every few minutes. What we really need is a round-robin database file that Cacti can determine how to read from. Good thing sensord already knows exactly what that is and how to make one, because I sure don't. To enable that, we just need to uncomment a single line in ``/etc/default/sensord``.

{% highlight bash %}
# Uncomment this to enable a 7-day round-robin database of sensor
# readings.  See the ROUND ROBIN DATABASES section of the sensord
# manual page for details.
RRD_FILE=/var/log/sensord.rrd
{% endhighlight %}

This enables logging of all sensor data to ``/var/log/sensord.rrd``, but you can change it to any path. The line directly below can also be updated for a higher frequency of updates than the default of 5 minutes:

{% highlight bash %}
# Interval between RRD readings; e.g. 30s, 5m (default), 1h
RRD_INTERVAL=1m
{% endhighlight %}

I mean, let's realtime the shit out of this, huh? Make sure to restart the daemon after so it will pick up the new settings:

{% highlight bash %}
$ sudo service sensord restart
{% endhighlight %}

### Making Junk Talk to Other Junk

Time to tell Cacti about the rrd file we're writing to constantly with our sweet, sweet data. Let's check out exactly what fields we have in the database with this command:

{% highlight bash %}
$ rrdtool info /var/log/sensord.rrd
{% endhighlight %}

You'll see something along the lines of this:

{% highlight bash %}
filename = "/var/log/sensord.rrd"
rrd_version = "0003"
step = 60
last_update = 1426890780
header_size = 1208
ds[temp1].index = 0
ds[temp1].type = "GAUGE"
ds[temp1].minimal_heartbeat = 300
ds[temp1].min = -1.0000000000e+02
ds[temp1].max = 2.5000000000e+02
ds[temp1].last_ds = "33.9"
ds[temp1].value = 2.7990552000e+00
ds[temp1].unknown_sec = 0
ds[fan1].index = 1
ds[fan1].type = "GAUGE"
ds[fan1].minimal_heartbeat = 300
ds[fan1].min = 0.0000000000e+00
ds[fan1].max = 1.2000000000e+04
ds[fan1].last_ds = "2460"
ds[fan1].value = 2.0311728000e+02
ds[fan1].unknown_sec = 0
ds[temp1_0].index = 2
ds[temp1_0].type = "GAUGE"
ds[temp1_0].minimal_heartbeat = 300
ds[temp1_0].min = -1.0000000000e+02
ds[temp1_0].max = 2.5000000000e+02
ds[temp1_0].last_ds = "38.0"
ds[temp1_0].value = 3.1375840000e+00
ds[temp1_0].unknown_sec = 0
rra[0].cf = "AVERAGE"
rra[0].rows = 10080
rra[0].cur_row = 4418
rra[0].pdp_per_row = 1
rra[0].xff = 5.0000000000e-01
rra[0].cdp_prep[0].value = NaN
rra[0].cdp_prep[0].unknown_datapoints = 0
rra[0].cdp_prep[1].value = NaN
rra[0].cdp_prep[1].unknown_datapoints = 0
rra[0].cdp_prep[2].value = NaN
rra[0].cdp_prep[2].unknown_datapoints = 0
{% endhighlight %}

The ``ds`` statements give us the names of each field being logged. I've got ``temp1``, ``fan1``, and ``temp1_0`` because apparently temp2 would just be too straightforward. 

Let's get this into a Data Template. In the Cacti console, click on Templates > Data Templates, and then click the Add link in the top right. Give the Template and Source names, and make sure that the Data Input Method is None, and the Data Source Active box is unchecked for now. Next, head into the Data Source Item [] section below, and fill in the info about the first ``ds`` that we found in our rrdtool spew. For example, mine looks like this:

![Data Source Me](https://www.evernote.com/shard/s2/sh/e95f467a-2ff6-4929-b872-03fa5c587a9a/97978b523fb60b2191d4f3914db664eb/deep/0/Console----Data-Templates----(Edit).png "You know it's super important data because of all the scientific notation.")

Once you click the Create button, You'll be back on a similar page, but now with a New link in the Data Source Item header. Click that and add each of your ``ds`` fields, making sure to click the Save button before clicking New again. *Trust me on this one.*

Next up, we need a Graph Template. Head over to Templates > Graph Templates and click the Add link. Give it a name and Create, then click Add under Graph Template Items and choose the first ``ds`` from our Data Source from the last step. You can also set the details, like color and graph type, using an exceptionally unhelpful list of hex colors. Repeat this for each of the ``ds`` values you'll want to show on this graph. Be sure to also add one for each ds with no changes except to set the type to LEGEND. Cacti will automagically add three GPRINT entries to display a min/max/avg value for each in the graph's legend.

Now we can add this to our host (there are only like two things left, I promise). This one is easy. Go to Management > Devices, and click on localhost. In the Associated Graph Templates section, we can add our new one, then Save.

Under Management > Data Sources, we can now Add our Data Template to the Host. Once we've created it, a Data Source Path field will appear, and we can enter the path to the .rrd file, which in my case is ``/var/log/sensord.rrd``.

Finally, it's time to make the goddamned graph. Click on that glorious, beautiful, Create > New Graphs link, and check the box next to our lovely new Graph Template, and click Create. 

Now, before you lose your mind and hurl your computer through the nearest window, keep in mind that we have to wait the first five minutes for the data collection interval. Until there is any data, the graph will fail to work, and instead just give you the worst feeling in the world after all this work.

![No graphs :(](https://www.evernote.com/shard/s2/sh/0c5291c1-f9be-43c3-bc7a-257cb37deafb/1d04f6b1c9f8e902c4422076d8c71248/deep/0/Graphs----Preview-Mode----Temp-Average.png "No. No no no no no.")

Give it a little time to catch up, and everything will be alright, I promise.

![Graphs for days. Literally.](https://www.evernote.com/shard/s2/sh/d17dd34a-1365-4fea-91da-e97f19a57509/670b29942f0cbc252f19fd30d4ff233e/deep/0/Graphs----Temp-Average.png "Well this is...moderately useful.")

### Why was I doing this again?

So in the end, I now have a realtime graph to track temperatures within my server. I'm a solid 87% sure that my temp1 is the CPU sensor, and temp1_0 is a motherboard sensor, so this actually gives me a pretty good idea of what's going on inside my buddy Alonso. But it's not quite enough. I need to see what's causing the temperatures to spike, so what I really need is a graph that shows current PLEX sessions. ...I need more caffeine first.