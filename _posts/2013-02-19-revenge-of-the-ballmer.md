---
layout: post
published: true
pygments: true
title: "Doing Selenium Part II: Revenge of the Ballmer"
tags: [code, selenium, projects, bash, testing, automation, QA, IE, Ballmer, VMs]
comments: true
---

After using the solution I detailed in [my last post](pettazz.com/2013/02/13/Showing-Internet-Explorer-Who-Its-Boss-Is/) for about a week, I found that more often than not, even with spawning entirely new VMs every night, on one or both of the IE machines, while a test was running, iexplore.exe would be using 99% CPU. <!--more-->Under that kind of pressure, a test that normally takes about 46 seconds on Chrome (with another test running in Firefox on the same machine, no less) would take over five minutes on IE 8. No, seriously. I have actual data this time. Didn't see that coming, did you?

![IE 8: Carefully crafted to destroy all your hopes and dreams!](http://i.imgur.com/wjMaMRL.png)


I'll let you digest that for a few minutes. It's okay, as you can see, I've got _plenty_ of time to wait. Clearly, this is not going to work once we move on to running more than four tests. I investigated some possibile causes in, because I am an inherently lazy sack, order from least difficult to fix to most. 

My first thought after seeing occasional 100% usage of all four cores using htop during test runs was that maybe my desktop and/or VirtualBox was having trouble handling three VMs at once, though the fact that the Chrome/Firefox VM never seemed to run into this kind of trouble was a little more than unsettling. I found a [number of possible solutions](http://home.icequake.net/~nemesis/blog/index.php/archives/321) (yes, including an OS-less dummy machine for some reason), but found no real success. So I tried replacing VirtualBox entirely, and switching all my VMs to hardcore mode (also known as [QEMU](http://wiki.qemu.org/Main_Page). It actually went a lot better than I expected.

First, my Base images would have to be something useable by QEMU; I needed to convert them from VirtualBox .vdi's to .qcow's, but I was also worried about keeping the originals in case I completely boned this new setup and had to revert. This was accomplished easily enough by running these for each VM:

{% highlight bash %}
VBoxManage clonehd "Win7 ie8 Base.vdi" "Win7ie8Base.img" --format RAW
qemu-img convert -f raw Win7ie8Base.img -O qcow2 Win7ie8Base.qcow
rm Win7ie8Base.img
{% endhighlight %}

Next, my nightly reset script would need a little attention. The fact that QEMU is essentially an entirely command-line based tool made this even easier.

{% highlight bash %}
#!/bin/bash
 
function reset_vm {
    echo "resetting $1..."
 
    cd /home/pettazz/VMs/
 
    if [ -a $1.pid ]
    then
        echo "killing existing VM pid:"
        echo `cat $1.pid`
        echo -e "\n"
        kill -9 `cat $1.pid`
        rm $1.pid
    fi 
 
    rm $1Active.qcow
 
    cp -v $1Base.qcow $1Active.qcow
 
    kvm -m 2048 -usbdevice tablet -hda $1Active.qcow -vga std -redir tcp:$2::$2 > $1.log &
    echo $! > $1.pid
    echo -e "done.\n\n\n"
}
 
reset_vm "Win7ie8" 5555
reset_vm "Win7ie9" 5556
reset_vm "Win7ffchrome" 5557
{% endhighlight %}

[https://gist.github.com/pettazz/4990397](Check it out on Gist)

And suddenly I was the proud owner of three VMs running in QEMU, the solution to all my life's problems. 

![IE 8: Still trying desperately to consume your every want and desire.](http://i.imgur.com/1Cx73Aw.png)

Oh, son of a _bitch_. 