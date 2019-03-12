---
layout: post
published: false
title: Uptime Monitoring
tagline: "You gotta know it"
tags: [blag, alonso, homelab, apache]
comments: true
image:
  feature: network.jpg
---



    <Location /ping>
        Satisfy Any
        Allow from all
    </Location>