---
layout: post
published: true
pygments: true
title: "Doing Selenium Part I: Showing Windows and IE Who's Boss"
tags: [code, selenium, projects, bash, testing, automation, QA, IE, Ballmer, VMs]
comments: true
---

After dealing with Selenium testing on Internet Explorer for some time now, I've learned one thing in particular: IE is horrifically self-destructive.<!--more--> I don't know exactly what it is, but the more it's used for tests, the more quickly its performance degrades. I would think it has something to do with the fact that Firefox and Chrome each are started with new user profiles each time Selenium runs, a feature that IE doesn't support, but I have no real idea what the cause is or even what in particular makes it become so slow and useless. Though I have a pretty good idea. 

![Needs more developers](http://i.imgur.com/S6ZP6.jpg)

[SauceLabs](https://saucelabs.com/) is a fantastic solution to this problem, which they solve by spawning new Virtual Machines on demand, and then destroying them when your tests have finished. Their browsers never survive long enough to get themselves into that shitty state. But, after accidentally going over my minutes by about 600% in one month, I needed a solution that didn't cost my sum net worth to handle the insane quantity of tests I throw at it daily. I decided to take my own Sauce-inspired, half-assed VM approach. 

One desktop and three [VirtualBoxes](https://www.virtualbox.org/) later, I had base images to use for each browser I need to support: IE8, IE9, Firefox, and Chrome. "*Three*? But that's *four* browsers! What kind of dumbass are you that you can't even count and why should I be reading your blog of lies and why does this coffee taste so bad I hope no one put bleach in it because last time I had to wear special glasses for some--" Whoa, calm down there buddy. After some seriously confusing errors, I found that both IEs really prefer to be running on their own, and other Selenium tests can interfere, even those running on entirely separate browsers. So I started with one Windows 7 installation, installed Java, Chrome, and Firefox, along with their appropriate drivers, got my network drive attached and batch scripts downloaded, and configured all the first run nonsense for every browser. From there, I could use VirtualBox's clone feature to create two duplicates of that VM, and on one of them installed the IE9 update. All it took from there was to specify a different port in the batch script that launches Selenium as a node for each VM, and forward that port through the Network/NAT settings, and I had all the browsers I needed attached to my grid. 

But this left me back at the original problem: IE, if left to its own devices long enough, will completely shit itself. To death. In comes the [vboxmanage command-line tool](http://www.virtualbox.org/manual/ch08.html) and a little bit of cron-based magic to save the day. 

{% highlight bash %}
#!/bin/bash
 
function reset_vm {
    echo -e "\e[0;32m\n\nresetting $1...\n\n\e[00m"
    echo -e "\e[0;34mpoweroff\e[00m"
    vboxmanage controlvm "$1 - active" poweroff
    sleep 5s
    echo -e "\e[0;34munregister\e[00m"
    vboxmanage unregistervm "$1 - active" --delete
    echo -e "\e[0;34mclone\e[00m"
    vboxmanage clonevm "$1 Base" --name="$1 - active" --register
    echo -e "\e[0;34mstart\e[00m"
    vboxmanage startvm "$1 - active"
    echo -e "\e[0;32m\n\ndone.\n\n\e[00m"
}
reset_vm "Win7 ie8"
reset_vm "Win7 ie9"
reset_vm "Win7 ff,chrome"
 
echo -e "\e[0;32m\n\ndone.\n\n\e[00m"
{% endhighlight %}

[Check it out on Gist](https://gist.github.com/pettazz/4947662)

Every night at ```@midnight```, each of the "active" VMs is destroyed, and a new instance is created by cloning the appropriate "Base" VM. It's not quite as fresh as an instance Sauce would serve up, but it definitely solves the IE shenanigans that have been slowly eating away at my sanity for the past few months. 

PS Don't ask me about the Windows licenses. The less you know, the safer you are. But if you're looking for a short-term solution, Microsoft has just launched a surprisingly awesome site: [modern.IE](http://modern.ie/) which includes a pretty solid stack of resources for developers to make sites compatible with IE, and even some VM disk images, which some people have used to create [some very useful tools](https://github.com/xdissent/ievms) if you don't need to have things like Selenium preconfigured before launching your VM. 