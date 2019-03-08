---
layout: post
published: false
title: "Tunnel Transmissions: Securing Transmission with OpenVPN"
excerpt: "I remember thinking it would take a man six hundred years to tunnel through the internet to Sweden. Old openVPN did it in less than twenty."
tags: [blag, openvpn, vpn, privacy, alonso, homelab, transmission]
comments: true
image:
  feature: tunnel.jpg
---

In this week's installment of *Extremely Justified TBH Privacy Paranoia Theater*, we'll take a look at making sure one of the most popular download tools isn't broadcasting to everyone in between your ethernet port and your peers in Estonia what kind of weird torrents you're into. There are a lot of download tools out there, but Transmission is still one of the best thanks to its stability and almost unbelievably easy setup and usage. One downside is that it doesn't natively support VPNs or even binding to specific network interfaces, but luckily we can use a little bit of configuration wizardry to reach that end goal anyway. It's the type of thing that can be used for skirting copyright law and downloading media illegally, so please don't use my knowledge to break the law.

Or do; honestly, what the fuck do I care?

There's plenty of reason not to trust anyone, including (especially) your ISP, with your private data when you don't have to, even if everything you're doing is entirely above board. Comcast for example is known to use deep packet inspection to throttle different forms of content despite really, really promising they would never do anything like that. You pay for this internet pipe, it's your own damn business what you pump through it.

Essentially the plan is to force the sequence of OpenVPN and Transmission service startups so that we can make some configuration changes at the appropriate times:

1. OpenVPN Client starts up, connects, establishes the tunnel
2. Establish a network route for using the tunnel that was just created
3. Create firewall rules explicitly disallowing traffic on the normal interface using a port dedicated to Transmission
4. Create firewall rules allowing *only* traffic using Transmission's port on the tunnel
5. Start transmission using the dedicated port, bound to the tunnel's IP 

## Prerequisites

### Provider

First of all, you'll need a VPN provider. I'm using [Private Internet Access](https://www.privateinternetaccess.com/), but anything compatible with OpenVPN will work just fine. Do check out [the EFF's extremely solid guide](https://ssd.eff.org/en/module/choosing-vpn-thats-right-you) on things to consider if you're shopping.

### System Software

I did this on a Linux system running `systemd`, (that means 16.04+ if you're using Ubuntu) but it shouldn't be hard to modify to work with whatever obscure distro and/or service manager you're using. It also relies on `ufw`, but if you're using something else for your firewall you probably already know how to do this anyway. As for installed versions, these were used at the time of this writing, lthough I've had this same setup working for well over a year before this, so it likely also works with older versions as well:

- `transmission-daemon`: **2.84**
- `openvpn`: **2.3.10**

A helpful tool you'll want to grab to verify that your changes are actually working:

- `nethogs`: basically `top` for network activity, see what processes are sending how much traffic over which interfaces.

### Working Tunnel

I won't cover installing and configuring Transmission or your OpenVPN client just to get them up and running since it's fairly straightforward (`apt-get install`) and varies depending on your provider (they'll most likely give you the conf files and certs you need). 

You should have a tunnel that is alive and well at this point, which we'll assume for the rest of this is on an interface named `tun0`. If you're not sure what the interface name is, you can check the `dev` line of your conf file (probably somewhere like `/etc/openvpn/tunnel.conf`), or check the output of `ip tuntap show` for any such devices.

Found the interface, but not sure if the tunnel is active? First, check if the interface is actually up:

    ip link show up tun0 >/dev/null 2>/dev/null && echo "yup" || echo "nope"

Next, check that your public exit IP when using the tunnel interface is different than your normal one. You can expect:

    curl ipinfo.io/ip

To give you an entirely different result than:

    curl --interface tun0 ipinfo.io/ip

If not, you'll need to take another look at your OpenVPN Client.

### I Always Forget This Part

Make sure both the OpenVPN and Transmission services are not running before you make configuration changes.

## The OpenVPN Side of Things





# snips


get tunnel gateway ip

    ifconfig tun0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'



transmission startup conf to edit (systemd unit)

    sudo systemctl edit --full transmission-daemon.service

transmission systemd unit conf contents
    
    [Unit]
    Description=Transmission BitTorrent Daemon
    After=network.target

    [Service]
    User=debian-transmission
    Type=notify
    ExecStart=/bin/bash -c "exec /usr/bin/transmission-daemon --bind-address-ipv4 $(ifconfig tun0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}') --no-portmap -f --log-error
    ExecReload=/bin/kill -s HUP $MAINPID

    [Install]
    WantedBy=multi-user.target


# openvpn files

https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/

tunnel conf (/etc/openvpn/tunnel.conf)

    client
    dev tun0
    proto tcp
    remote blah.provider.com 502
    resolv-retry infinite
    nobind
    persist-key
    persist-tun
    cipher aes-128-cbc
    auth sha1
    tls-client
    remote-cert-tls server
    auth-user-pass /etc/openvpn/login.conf
    auth-nocache
    comp-lzo
    verb 1
    reneg-sec 0
    crl-verify /etc/openvpn/crl.rsa.2048.pem
    ca /etc/openvpn/ca.rsa.2048.crt
    disable-occ

    persist-tun
    script-security 2
    route-noexec

    route-up "/etc/openvpn/transmission-up.sh"
    down "/etc/openvpn/transmission-down.sh"

startup (/etc/openvpn/transmission-up.sh)

    #! /bin/bash

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


shutdown (/etc/openvpn/transmission-down.sh)

    #! /bin/bash

    export PORT=51413

    /usr/sbin/ufw delete reject out on enp7s0 from any port $PORT
    /usr/sbin/ufw delete reject in on enp7s0 to any port $PORT
    /usr/sbin/ufw delete deny in on tun0 to any
    /usr/sbin/ufw delete allow in on tun0 to any port $PORT proto udp

    /sbin/ip route flush cache