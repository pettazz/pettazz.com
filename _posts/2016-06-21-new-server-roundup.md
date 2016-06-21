---
layout: post
published: false
title: New Server Stuff
excerpt: ""
tags: [blag, plex, ubuntu, nfs, homelab, networking, osto]
comments: true
image:
  feature: spaghetti.png
---

apparently in 16.04 every entry in fstab gets a systemd unit created
you need to add some special shit to your options for nfs mounts:

https://wiki.archlinux.org/index.php/NFS#Mount_using_.2Fetc.2Ffstab_with_systemd