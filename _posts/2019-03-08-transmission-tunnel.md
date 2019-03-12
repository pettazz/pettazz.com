---
layout: post
published: true
modified: 2019-03-11
title: "Tunnel Transmissions: Securing Transmission with OpenVPN"
tagline: "I remember thinking it would take a man six hundred years to tunnel through the internet to Sweden. Old openVPN did it in less than twenty."
tags: [blag, openvpn, vpn, privacy, alonso, homelab, transmission]
comments: true
image:
  feature: tunnel.jpg
---

In this week's installment of *Extremely Justified TBH Privacy Paranoia Theater*, we'll take a look at making sure one of the most popular download tools isn't broadcasting to everyone in between your ethernet port and your peers in Estonia what kind of weird torrents you're into.<!--more--> There are a lot of download tools out there, but Transmission is still one of the best thanks to its stability and almost unbelievably easy setup and usage. One downside is that it doesn't natively support VPNs or even binding to specific network interfaces, but luckily we can use a little bit of configuration wizardry to reach that end goal anyway. It's the type of thing that can be used for skirting copyright law and downloading media illegally, so please don't use my knowledge to break the law.

Or do; honestly, what the fuck do I care?

There's plenty of reason not to trust anyone, including (especially) your ISP, with your private data when you don't have to, even if everything you're doing is entirely above board. Comcast for example is known to use deep packet inspection to throttle different forms of content despite really, really promising they would never do anything like that. You pay for this internet pipe, it's your own damn business what you pump through it.

Essentially the plan is to force the sequence of OpenVPN and Transmission service startups so that we can make some configuration changes at the appropriate times:

1. OpenVPN Client starts up, connects, establishes the tunnel
2. Establish a network route for using the tunnel that was just created
3. Create firewall rules explicitly disallowing traffic on the normal interface using a port dedicated to Transmission
4. Create firewall rules allowing *only* traffic using Transmission's port on the tunnel
5. Start transmission using the dedicated port, bound to the tunnel's IP 

## Prerequisites

#### Provider

First of all, you'll need a VPN provider. I'm using [Private Internet Access](https://www.privateinternetaccess.com/), but anything compatible with OpenVPN will work just fine. Do check out [the EFF's extremely solid guide](https://ssd.eff.org/en/module/choosing-vpn-thats-right-you) on things to consider if you're shopping.

#### System Software

I did this on a Linux system running `systemd`, (that means 16.04+ if you're using Ubuntu) but it shouldn't be hard to modify to work with whatever obscure distro and/or service manager you're using. It also relies on `ufw`, but if you're using something else for your firewall you probably already know how to do this anyway. As for installed versions, these were used at the time of this writing, although I've had this same setup working for well over a year before this, so it likely also works with older versions as well:

- `transmission-daemon`: **2.84**
- `openvpn`: **2.3.10**

A helpful tool you'll want to grab to verify that your changes are actually working:

- `nethogs`: basically `top` for network activity, see what processes are sending how much traffic over which interfaces.

#### Working Tunnel

I won't cover installing and configuring Transmission or your OpenVPN client just to get them up and running since it's fairly straightforward (`apt-get install`) and varies depending on your provider (they'll most likely give you the conf files and certs you need). 

You should have a tunnel that is alive and well at this point, which we'll assume for the rest of this is on an interface named `tun0`. If you're not sure what the interface name is, you can check the `dev` line of your conf file (probably somewhere like `/etc/openvpn/tunnel.conf`), or check the output of `ip tuntap show` for any such devices.

Found the interface, but not sure if the tunnel is active? First, check if the interface is actually up:

{% highlight bash %}
ip link show up tun0 >/dev/null 2>/dev/null && echo "yup" || echo "nope"
{% endhighlight %}

If it is, you'll see your tunnel exit IP address, entirely different than your typical external IP using:

{% highlight bash %}
curl ipinfo.io/ip
{% endhighlight %}

You can double check by shutting down OpenVPN with `sudo service openvpn stop` and running the curl command again, this time expecting to see your usual external address. If you see the same result whether or not OpenVPN is running, you'll need to take another look at your OpenVPN Client.

#### I Always Forget This Part

Make sure both the OpenVPN and Transmission services **are not running** before you make configuration changes.

## Tell OpenVPN to Take a Break, We Got This

Your VPN conf file is probably located in `/etc/openvpn/tunnel.conf`, but with a more specific name. It's essentially [a list of command line arguments](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-3/) to pass to the client when it starts, and we need to add a few more. Starting with options to run our scripts properly:

    script-security 2
    route-noexec

First, `script-security 2` will allow us to call our own scripts beyond simple tasks, which we'll need to do for all this Transmission nonsense. `route-noexec` will tell OpenVPN not to automatically add the network routes for normal tunnel use, handing the details off to a user script instead. We're going to create our own and restrict the traffic that uses it.

Now we can add the actual script triggers:

    route-up "/etc/openvpn/transmission-up.sh"
    down "/etc/openvpn/transmission-down.sh"

Fairly straightforwardly, `route-up` names a script to be run when the tunnel is up and the routes would normally be added, if we hadn't specified the `route-noexec` option, and `down` similarly specifies a script to run after the tunnel has been closed. The [guide has a full list](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-3/#scripting-and-environmental-variables) of the order of operations available. You can set the script paths and names to anything, but I find it's easier to keep track of stuff related to the VPN all in the same directory. 

## Oh That Means We Actually Have to Do It, Huh

Now we need to create the scripts. Since they're going to be run during the OpenVPN startup, that means they'll run as root. Once you create the files, you'll of course need to set the executable bit with `chmod +x` but also make sure the permissions make sense: `chmod 700`, `chown root:root`.

#### Startup Script

Let's start with the up script, which I called `/etc/openvpn/transmission-up.sh`. Here's my complete version:

{% highlight bash %}
#!/bin/bash

export $route_vpn_gateway
export $ifconfig_local
export PORT=51413

/sbin/ip route add default via $route_vpn_gateway dev tun0 table 200
/sbin/ip rule add from $ifconfig_local table 200
/sbin/ip route flush cache

/usr/sbin/ufw insert 1 reject out on enp7s0 from any port $PORT
/usr/sbin/ufw insert 1 reject in on enp7s0 to any port $PORT
/usr/sbin/ufw insert 1 deny in on tun0 to any
/usr/sbin/ufw insert 1 allow in on tun0 to any port $PORT proto udp

systemctl start transmission-daemon
{% endhighlight %}

Conveniently, that `route-noexec` option also passes all the newly created tunnel parameters along to the various `-up` scripts by setting some [environment variables](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-3/#environmental-variables). So we start off by making two of those available:

- `route_vpn_gateway`: the new default gateway to use for the tunnel route 
- `ifconfig_local`: the new local tunnel IP address

And we set one of our own, which in this case is Transmission's default port, 51413. If you're using a nonstandard port, this is the place to change it.

{% highlight bash %}
/sbin/ip route add default via $route_vpn_gateway dev tun0 table 200
/sbin/ip rule add from $ifconfig_local table 200
/sbin/ip route flush cache
{% endhighlight %}

Next, we use the Unix `ip` tool to create the network route to enable using the tunnel on the `tun0` device using the details we were so kindly given by OpenVPN, flush out the cache and it's ready to go.

After that, we need to add firewall rules that both prevent Transmission's traffic from using the normal interface, and restrict the tunnel's interface to only accept Transmission traffic. The `ufw` firewall has a super simple interface to do both of these things. 

{% highlight bash %}
/usr/sbin/ufw insert 1 reject out on enp7s0 from any port $PORT
/usr/sbin/ufw insert 1 reject in on enp7s0 to any port $PORT
{% endhighlight %}

Make sure to replace `enp7s0` with whatever your actual usual network interface is. 
{: .notice}

We use the port that Transmission sends all its traffic through as an easy and reliable shortcut to differentiate it from any other network traffic. We tell `ufw` to create rules rejecting any traffic through that port in or out on the normal interface.

{% highlight bash %}
/usr/sbin/ufw insert 1 deny in on tun0 to any
/usr/sbin/ufw insert 1 allow in on tun0 to any port $PORT proto udp
{% endhighlight %}

Now we tell the firewall to first deny all traffic over the tunnel's interface `tun0`, then add an exception for our special Transmission-only port. 

{% highlight bash %}
systemctl start transmission-daemon
{% endhighlight %}

Finally, we tell `systemd` to start up Transmission, now that we've laid all the groundwork for it. 

#### Shutdown Script

The shutdown script is basically for cleanup if and when we decide to close the tunnel. In typical usage this won't come up a lot, but it'd usually a good idea to clean up after yourself when you're doing weird things to your firewall and network routes. Here's my `/etc/openvpn/transmission-down.sh`:

{% highlight bash %}
#! /bin/bash

export PORT=51413

systemctl stop transmission-daemon

/usr/sbin/ufw delete reject out on enp7s0 from any port $PORT
/usr/sbin/ufw delete reject in on enp7s0 to any port $PORT
/usr/sbin/ufw delete deny in on tun0 to any
/usr/sbin/ufw delete allow in on tun0 to any port $PORT proto udp

/sbin/ip route flush cache
{% endhighlight %}

Just like in the up script, we start off setting the special Transmission port. Again, make sure you change this if you need to. Next we tell `systemd` to stop Transmission, since by the time this script has been called, the tunnel is closed and we're about to remove the firewall rules that make sure none of its traffic goes out to your normal internet connection. It wouldn't be great to just silently switch over to downloading with zero privacy whenever the VPN goes down for any reason.

{% highlight bash %}
/usr/sbin/ufw delete reject out on enp7s0 from any port $PORT
/usr/sbin/ufw delete reject in on enp7s0 to any port $PORT
/usr/sbin/ufw delete deny in on tun0 to any
/usr/sbin/ufw delete allow in on tun0 to any port $PORT proto udp
{% endhighlight %}

Delete all the rules we created when the tunnel opened up and go back to normal. Easy.

{% highlight bash %}
/sbin/ip route flush cache
{% endhighlight %}

Once OpenVPN is calling the `down` script, the routes have already been removed, so we only need to clear the cache to avoid using any old rules.

## Wake Up, Transmission 

We only have one thing left, and that's getting Transmission bound to the tunnel's IP address instead of the default network interface. Luckily, it has a command line option to do just that. Unluckily, though, we're not running this one in the context of the OpenVPN script and its helpful environment variables, so we have to figure that out on our own. `ifconfig tun0` will give us exactly what we're looking for, but since this needs to be jammed into a command line parameter, it requires a little bit of bash acrobatics to narrow that down to just the IP address itself:

{% highlight bash %}
ifconfig tun0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'
{% endhighlight %}

All I can say is, thank [Doug McIlroy](https://web.archive.org/web/20110430221313/https://www.cs.dartmouth.edu/~sinclair/doug/) for pipes, the literal glue that holds all our crap together.

In the world of `systemd`, we can use one command to open up the definition for any given service:

{% highlight bash %}
sudo systemctl edit --full transmission-daemon.service
{% endhighlight %}

That will open Transmission's service definition in your default editor, which will look something like this:

{% highlight ini %}
[Unit]
Description=Transmission BitTorrent Daemon
After=network.target

[Service]
User=debian-transmission
Type=notify
ExecStart=/bin/bash -c "exec /usr/bin/transmission-daemon --no-portmap -f"
ExecReload=/bin/kill -s HUP $MAINPID

[Install]
WantedBy=multi-user.target
{% endhighlight %}

Yours may look a lot different, but there's only one key line here that we need to edit, the `ExecStart` property. Transmission offers the command line option `--bind-address-ipv4` to specify the network address to bind to rather than just going with the default. We can stick our one-liner in here to provide it with the tunnel's address:

    --bind-address-ipv4 $(ifconfig tun0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')

I also add the `--log-error` flag to enable logging which is off by default for some unknown reason, in case something needs to be debugged (like, shoving all its traffic forcibly down some strange tunnel, for example). With the new options added, that means my `ExecStart` looks like this:

{% highlight ini %}
ExecStart=/bin/bash -c "exec /usr/bin/transmission-daemon --no-portmap -f --bind-address-ipv4 $(ifconfig tun0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}') --log-error"
{% endhighlight %}

## Congrats on Your Cool New Tunnel

And that's that. Now when you `sudo service openvpn start` your tunnel up, after a short delay, you should also see your Transmission daemon come back up. How can we tell whether it's working? 

#### Is the Tunnel Split?

Thanks to our custom route, the tunnel no longer takes over all your internet connections, only the ones that are explicitly meant to be sent over it, in what's called a split tunnel. So now, while OpenVPN is running, you can still expect to see your normal old external IP when you run:

{% highlight bash %}
curl ipinfo.io/ip
{% endhighlight %}

But also your exciting new tunnel exit IP from:

{% highlight bash %}
curl --interface tun0 ipinfo.io/ip
{% endhighlight %}

#### Do Torrents Connect?

This one is pretty obvious, but a good first step. When you add a download, is it able to start working, or does it instead spit out errors not being able to connect to peers or trackers? 

#### Is Traffic Using the Tunnel?

Here's where `nethogs` comes in. Make sure you have an actually active download/upload running in Transmission and kick it off (requires `sudo nethogs` to spy on your network traffic), and wait for it to collect some traffic. You should quickly see a lot of different processes using networking. The things to look for here are that the `transmission-daemon` process is *only* showing usage on the `tun0` device, and that it is the *only* process using it.

![nethogs example output](/images/nethogs-transmission.jpg "It's kinda funny to me that the only thing using network in my example is openvpn itself.")

#### Does Your Peer Address Match the VPN Exit Address

TorGuard offers an extremely helpful tool to verify exactly this: [Check My Torrent IP](https://torguard.net/checkmytorrentipaddress.php). Copy the link URL of the giant download button and add it to your Transmission downloads as a magnet address. It'll immediately throw up an error in transmission, since it's not meant to actually download anything, but within a few seconds you should see results appear in the table, showing what peers and trackers see when they connect to your Transmission daemon. This IP address should exactly match your tunnel exit IP (the one you get from `curl --interface tun0 ipinfo.io/ip`).

## Caveats

You're safe and secure, but there are a few things to know about your wondrous new setup.

**OpenVPN will take Transmission down with it**
:   Any time that the tunnel is closed, thanks to our shutdown script, `transmission-daemon` will also be shut off. That means that if you lose your network connection, or OpenVPN itself gets stopped, so will Transmission. Better safe than public.
<br />
<br />

**DNS may be leaking**
:   This configuration uses a dedicated port to differentiate between Transmission-specific traffic and all the rest, so DNS requests will most likely not be made through the tunnel. This isn't exactly critical, since it just shows your ISP and anyone else keeping an eye on you that you visited a tracker once and may be looking for how to connect to various people across the world. It's not clear evidence of anything, and all your actual traffic is still private and encrypted, but it's not ideal. I'll post a follow up someday to fix this. Probably. 
<br />
<br />

**Transmission monopolizes the tunnel**
:   Because of our firewall rules, we're making the tunnel utterly exclusive to Transmission, so if you want to use it for other things, you're either out of luck or you'll need to add some more firewall rules to your scripts. Fortunately, most VPN providers give you multiple gateways per account, so you could always set up, say `tun1` normally for other stuff to use.
<br />
<br />

**You might go mad with power**
:   Knowing that you're incredibly safe and secure and impervious to being tracked by absolutely every entity in the world\*, you may feel a sense of infallibility that only gods have known before. You may start to experience time and space differently than mere mortals and transcend beyond the point of needing to use such a primitive device as a computer anymore. In which case please @ me on twitter so I can have your stuff.

\*Completely and utterly factually inaccurate. Cannot overstate how not true that is.
{: .notice}