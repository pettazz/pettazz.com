---
layout: post
published: false
title: Getting Secure
tagline: "Yes, \"HTTPS Everywhere\" includes your dumb server. That's what everywhere means."
tags: [blag, https, ssl, alonso, homelab, plex, let's encrypt, certbot]
comments: true
image:
  feature: network.jpg
---

It's hard to pretend that privacy isn't important these days when every other day there's another story about a data breach [leaking millions of peoples' private data](https://www.theverge.com/2019/3/4/18250474/chinese-messages-millions-wechat-qq-yy-data-breach-police) into the public when they were really meant to be shipped off to a government surveillance program, or that Facebook was again lying and [selling your account security phone number](https://www.eff.org/deeplinks/2019/03/facebook-doubles-down-misusing-your-phone-number) to every company who had spare change to spend on it, or some other equally dystopian nightmare. Unfortunately there's not a lot any individual person can do to prevent that sort of stuff (except maybe deleting your Facebook, which you should definitely do), but you can limit what you do out in the open by encrypting everything. <!--more-->

## Yes, that means **everything**.

For example, this dumb blog is nothing but pre-generated files, a bunch of html, css, and javascript spit out by jekyll on the server side, hosted purely statically. There's no possible backend exploit because there's no backend. Why I care whether it's securely encrypted? Because I'm not the only one who uses it (I saw at least 4 hits in the past 3 years, okay). If there's no end-to-end encryption, that means some bad actor in between me and you could be intercepting this content and altering it. That could be as simple as changing my words to make me sound like a real dipshit (if you don't like any of my posts I promise this is what happened), or changing a post to tell you that it's a great idea to install some weird Russian software package that spy on your machine and steal your credit card numbers. Or, most likely, inject some malicious code into the page content that will mine Bitcoins in your browser, or redirect you to their phishing site, or ask to install browser extensions, or any other number of nefarious things. It also prevents an ISP or government from altering content to censor stuff they don't want you looking at, like [a post on how to use a VPN to skirt their surveillance](/transmission-tunnel/). 

> *HTTPS Everywhere* is a bit like herd immunity. If we're encrypting everything, we're protecting each other. 

Luckily, this thing is hosted on GitHub Pages, so all I had to do was check a box and update my \_config.yml, and we're good to go. 

But this isn't the only place where my precious, human form interfaces with the internet. Though in this case, it's your more classic example of absolutely not trusting anyone who comes into contact with these exposed surfaces. I've got a whole bunch of web services semi-publicly accessible to the open internet: Plex, Transmission, Sonarr, Radarr, Netdata and Ombi. Securing these is more immediately important to the cause of my cool server friend Alonso not being used by someone in China as a botnet controller again (maybe I'll write that post someday).

## Let's Encrypt with Certbot <br /><small style="font-size:16px">(sometimes the future does sound cool after all)</small>

[Let’s Encrypt is a free, automated, and open Certificate Authority.](https://letsencrypt.org) That means they offer SSL certificates to anyone, on demand, at no cost. Before they came along, the main gatekeeping mechanism for ensuring the legitimacy of anyone using a certificate was that they cost an absurd amount of money and could be revoked if you were caught misusing them, which left anyone without a few thousand dollars to burn on their hobby project out of luck.

[Certbot is a tool provided by the EFF](https://certbot.eff.org/) to automatically fetch and install Let's Encrypt-issued certificates on your machines. It makes this whole process infinitely easier, especially when it comes time to renew. 

Certbot's "getting started" guide does a better job of walking you through installing certs than I could ever do, so I won't try. But in my case, it was only half of what I needed. The services I wanted to host with HTTPS run their own discrete server instances, so they're not directly supported by Certbot's options.

## Reverse Proxy to the Rescue

In the way that a regular forward proxy is a middleman for your browser to hide either your requests from the local network, or your client's actual identity from the remote server, a reverse proxy is a middleman that allows the server to present a single host, obscuring what might be going on behind the scenes on the server itself to actually respond to your requests. In a lot of cases, that reverse proxy might be something like a cache or a CDN to offload traffic, but in our case this is extremely helpful because it allows us to funnel all requests to a single server, running HTTPS with our new Let's Encrypt cert, protected with authentication, which can respond to requests from whichever service is needed. Think of it like using an ATM: you have to use the single screen interface to interact with your bank, it forces you to prove you're legit with your card and PIN, you have no idea what goes on behind the wall, but it can spit out money or information. 

Apache supports running a reverse proxy pretty straightforwardly, and Certbot integrates directly with it. Sounds like a pretty good match to me.

### Domain Setup

### Certbot Install

Again, I'm not going to waste everyone's time doing a bad job replicating Certbot's guide here, so follow the Apache setup guide to get started and then head back here to create the reverse proxy.

### Add Reverse Proxy
    
    a2enmod proxy
    a2enmod proxy_http

### Update Service Apps

{% highlight apache %}
<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerName pettazz.com
        ServerAlias pettazz.com

        <Proxy *>
            Order deny,allow
            Allow from all
        </Proxy>

        <Location />
            AuthType Basic
            AuthName "Hello I am big secure server time"
            AuthUserFile /etc/apache2/.htpasswd
            Require valid-user
            Order deny,allow
            Allow from all
        </Location>

        <Location /ping>
            Satisfy Any
            Allow from all
        </Location>

        <Location /request>
            Satisfy Any
            Allow from all
        </Location>

        SSLEngine on
        SSLProxyEngine On
        RewriteEngine On

        SSLCertificateFile /etc/letsencrypt/live/pettazz.com/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/pettazz.com/privkey.pem
        Include /etc/letsencrypt/options-ssl-apache.conf

        ProxyRequests Off
        ProxyPreserveHost On

        # Transmission
        ProxyPass /transmission http://127.0.0.1:9091/transmission
        ProxyPassReverse /transmission http://127.0.0.1:9091/transmission

        #Sonarr
        ProxyPass /sonarr http://127.0.0.1:8989/sonarr
        ProxyPassReverse /sonarr http://127.0.0.1:8989/sonarr

        #Radarr
        ProxyPass /radarr http://127.0.0.1:7878/radarr
        ProxyPassReverse /radarr http://127.0.0.1:7878/radarr

        #netdata
        ProxyPass /netdata http://127.0.0.1:19999/
        ProxyPassReverse /netdata http://127.0.0.1:19999/
        RewriteRule ^/netdata$ https://%{HTTP_HOST}/netdata/ [L,R=301]

        #ombi
        ProxyPass /request http://127.0.0.1:5000/request
        ProxyPassReverse /request http://127.0.0.1:5000/request

    </VirtualHost>
</IfModule>
<IfModule mod_headers.c>
        Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
</IfModule>
{% endhighlight %}