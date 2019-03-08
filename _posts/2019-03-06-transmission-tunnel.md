---
layout: post
published: true
title: "Tunnel Transmissions: Securing Transmission with OpenVPN"
excerpt: "I remember thinking it would take a man six hundred years to tunnel through the internet to Sweden. Old openVPN did it in less than twenty."
tags: [blag, openvpn, vpn, privacy, alonso, homelab, transmission]
comments: true
image:
  feature: tunnel.jpg
---

In this week's installment of *Extremely Justified TBH Privacy Paranoia Theater*, we'll take a look at making sure one of the most popular download tools isn't broadcasting to everyone in between your ethernet port and your peers in Estonia what kind of weird torrents you're into. It's the type of thing that is frequently used for skirting copyright law and downloading media illegally, so please don't use my knowledge to break the law.

Or do, honestly, what the fuck do I care?

There's plenty of reason not to trust anyone, including (especially) your ISP, with your private data when you don't have to even if everything you're doing is entirely above board. Comcast for example is known to use deep packet inspection to throttle different forms of content despite really, really promising they would never do anything like that. You pay for this internet pipe, it's your own damn business what you pump through it.

## Prerequisites

I did this on a Linux system running `systemd`, (that means 16.04+ if you're using Ubuntu) but it shouldn't be hard to modify to work with whatever obscure distro and/or service manager you're using. It also relies on `ufw`, but if you're using something else you probably already know how to do this anyway. As for installed versions, these were used at the time of this writing: 

- `transmission-daemon`: **2.84**
- `openvpn`: **2.3.10**

Although I've had this same setup working for well over a year before this, so it likely also works with older versions as well.

You'll also need a VPN provider. I'm using [Private Internet Access](https://www.privateinternetaccess.com/), but anything compatible with OpenVPN will work just fine.

A couple helpful tools you'll want to grab to verify that your changes are actually working:

- `nethogs`: basically `top` for network activity, see what processes are sending how much traffic over which interfaces

# snips

binary tunnel up/down?

    ip link show tun0 >/dev/null 2>/dev/null && echo 1 || echo


get tunnel exit ip

    curl --interface tun0 ipinfo.io/ip
 

details of tunnel

    ip a show tun0


get tunnel gateway ip

    ifconfig tun0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'


start transmission bound to tunnel with logging

    /usr/bin/transmission-daemon --bind-address-ipv4 $(ifconfig tun0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}') --no-portmap -f --log-error   


# openvpn files

tunnel conf

    client
    dev tun
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

    auth-user-pass
    comp-lzo
    verb 1
    reneg-sec 0
    crl-verify crl.rsa.2048.pem
    ca ca.rsa.2048.crt
    disable-occ


startup

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


shutdown

    #!/bin/bash
    
    export PORT=51413
    
    /usr/sbin/ufw delete reject out on enp7s0 from any port $PORT
    /usr/sbin/ufw delete reject in on enp7s0 to any port $PORT
    /usr/sbin/ufw delete deny in on tun0 to any
    /usr/sbin/ufw delete allow in on tun0 to any port $PORT proto udp

    /sbin/ip route flush cache