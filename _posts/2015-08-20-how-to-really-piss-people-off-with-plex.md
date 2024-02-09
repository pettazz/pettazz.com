---
layout: post
published: true
title: How to Really Piss People Off With Plex
tagline: "Unauthorized users will be force-fed mom's spaghetti."
tags: [blag, plex, ubuntu, squid, python, being unnecessarily mean]
comments: true
image: spaghetti.jpg
---

As I've mentioned a few times, I have a [PLEX](http://plex.tv) server full of delicious, nutritious content. Thanks to an update some time ago, I can easily share this content with my friends and family [via their own PLEX accounts](https://support.plex.tv/hc/en-us/sections/200295083-Server-Sharing), so that I don't have to go handing out my server admin login info, or deal with seeing suggestions for all the stupid crap they watch.

![Shitty Plex On Deck](/images/plex-garbage.png "Ugh.")

> Please, stop. We're all worried about you.
{: .notice}

On the downside, this also makes it somewhat harder to lock things down. I'm not particularly interested in subsidizing the TV and movie watching habits of friends of friends and people I will never meet, especially if there's any question about the legality of any of the content (which of course there isn't; everything I have is [totally public domain for sure definitely 100%](https://en.wikipedia.org/wiki/List_of_films_in_the_public_domain_in_the_United_States)). I don't want to be wasting precious CPU cycles and upload bandwidth so that someone from sixteen states over can watch *Ted 2* sixty-five times. Unfortunately, PLEX using the library sharing feature only allows me to restrict by section per user. So if a friend logs into one of their friends' Roku once, as long as they don't log out, they have access to all the same things that my friend does. My sharing dashboard doesn't even allow me to see what devices are being used under different accounts, even though that's completely available in the logs ([or a shiny log parsing web frontend](https://github.com/ljunkie/plexWatch)). This just isn't acceptable to my power-hungry server admin persona.

Looks like we have to do some work ourselves. First things first, let's decide what should happen to clients that are "blacklisted" from using the server. It would be easy enough to blackhole their requests and either let them waste away to nothing waiting for the loading spinner to finally finish, or simply throw some 5xx HTTP error state, but I never miss an opportunity to gaslight someone into questioning their own sanity. What I want is to alter any incoming video stream request from a "blacklisted" (or just non-whitelisted) client such that PLEX is still able to respond with a genuine stream, just not one that the user is expecting. Basically, I want everything to appear completely normal for them until they try to play something, at which point all they ever see is this video instead:

<iframe width="560" height="315" src="https://www.youtube.com/embed/SW-BU6keEUw" frameborder="0" allowfullscreen></iframe><br />

Bob's Burgers? Mom's Spaghetti. Cloudy with a Chance of Meatballs? More like 100% chance of Spaghetti. I think you get the idea.

### Boil Water

What we really want to do is check every request that comes in to plex to see whether it's coming from someone we want to spaghettify, and if so, edit the stream accordingly, else just let it go as usual. Sounds like a job for [Squid](http://squid-cache.org) and [iptables](https://help.ubuntu.com/community/IptablesHowTo). Go Google ````apt-get install```` on your own if you don't know how to install them. 

We'll also need the actual spaghetti video itself. I got mine from some Chrome extension that lets me grab YouTube videos as .mp4 files. In the interest of not linking to questionably legal things, I'll leave this one to Google as well. In the end, what I have is a new Plex section called "Wat" which scans a directory ````~tvrobot/plex-wat```` which just happens to contain spaghetti.mp4.

### Cook

Once spaghetti.mp4 has been scanned and loaded by Plex, we can get its metadata id. Head over to the Plex web client and dig up your spaghetti video. On its details page, we can just grab the id from the url:

{% highlight bash %}
http://yourplexserver.com/manage/index.html#!/server/blahblahuuidblah/details/%2Flibrary%2Fmetadata%2F42554
{% endhighlight %} 

The key part being the id at the very end after ````metadata%2F````, which in my case is ````42554````. Hang onto this tightly.

### Drain and Rinse

What Squid lets us do is specify a script to inspect and potentially rewrite any urls that are passed in. Squid writes the details of the incoming request to stdin, and just runs with whatever you hand over on stdout as the new url. Plex also conveniently just uses a fairly straightforward HTTP API to stream transcoded chunks of video. So our script just needs to check the if requester's IP address is one of our desired spaghetti targets, and if so, replace the metadata id of whatever they're trying to watch with our spaghetti id. 

Here's a python script I threw together to do that along with some basic logging.

{% highlight python %}
#!/usr/bin/env python
import sys

BAD_PEOPLE = [
    '192.168.1.118',
    '192.168.1.119'
]

while True:
    # squid writes stuff to us via stdin like this:
    # http://pettazz.com/transcode/sessions/123456789 91.44.124.101/- - GET myip=192.168.1.117 myport=32400
    line = sys.stdin.readline().strip()
    new_url = '\n'
    list = line.split(' ')
    if len(list) > 1:
        with open('/etc/squid3/spaghetti.log', 'a') as logfile:
            logfile.write('LINE: ------------------------\n')
            logfile.write(line + '\n\n')
            old_url = list[0]
            ip = list[1].split("/")[0]
            if ip in BAD_PEOPLE:
                logfile.write('IP MATCH\n')
                if "/video" in old_url and "metadata%2F" in old_url:
                    old_parts = old_url .split("metadata%2F", 1)
                    new_url = old_parts[0] + "metadata%2F42554&" + old_parts[1].split('&', 1)[1] + new_url;
                    logfile.write('REWRITE:--------------------------------\n')
                    logfile.write(old_url + '\n')
                    logfile.write(new_url)
                    logfile.write('----------------------------------------\n\n')
            else:
                logfile.write('IP MISS:' + ip + '\n')

    sys.stdout.write(new_url)
    sys.stdout.flush()
{% endhighlight %} 

I'm _almost_ surprised there isn't already a module to do this. The list at the top defines which IPs will get spaghetti all over them, and the path ````/etc/squid3/spaghetti.log```` can be defined as wherever you want my garbage logging spewed into. 

### Add Sauce

Telling Squid how to fuck with your users is surprisingly easy through the use of a configuration directive in its conf file (mine was located at ````/etc/squid3/squid.conf````):

{% highlight bash %}
#  TAG: url_rewrite_program
#   Specify the location of the executable URL rewriter to use.
#   Since they can perform almost any function there isn't one included.
--
# none

url_rewrite_program /etc/squid3/spaghetti.py
{% endhighlight %} 

There's probably a lesson in here somewhere about web security and trusting non-https connections, but I'm too busy forcibly shoveling spaghetti into peoples' mouths to notice. Once you change the configuration, restart squid (````sudo service squid3 restart````, probably).

### Serve

The venerable iptables tool lets us divert the pipe of incoming connections directly to Squid:

{% highlight bash %}
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 32400 -j REDIRECT --to-port 3128
{% endhighlight %} 

Where ````eth0```` is whatever network interface you're using, and ````32400```` and ````3128```` are your Plex and Squid ports, respectively (both of these are the defaults). 

This is also easy to undo (but really why would you _ever_ stop the flow of spaghetti):

{% highlight bash %}
sudo iptables -t nat -D PREROUTING 1
{% endhighlight %} 

### Enjoy

At this point the only worry you should have is all the extra sodium added to your delicious spaghetti from the tears of all the freeloaders who can no longer leech off your server. That, and possibly a lawsuit from some guy named Marshall Mathers, but who cares. Sounds like a real nerd.
