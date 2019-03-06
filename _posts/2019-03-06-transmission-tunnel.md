---
layout: post
published: false
title: Transmission Tunnel
excerpt: "I remember thinking it would take a man six hundred years to tunnel through the internet. Old openVPN did it in less than twenty."
tags: [blag, vpn, alonso, homelab, transmission]
comments: true
image:
  feature: 
---

In this week's installment of Completely Justified Privacy/Security Paranoia Theater, we'll take a look at using a VPN tunnel to encrypt Transmission traffic.



#snips

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


#openvpn files

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