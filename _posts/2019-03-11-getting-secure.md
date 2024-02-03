---
layout: post
published: true
modified: 2019-05-03
title: Getting Secure
tagline: "Yes, \"HTTPS Everywhere\" includes your dumb server. That's what everywhere means."
tags: [blag, https, ssl, alonso, homelab, plex, let's encrypt, certbot]
comments: true
image: network.jpg
---

It's hard to pretend that privacy isn't important these days when every other day there's another story about a data breach [leaking millions of peoples' private data](https://www.theverge.com/2019/3/4/18250474/chinese-messages-millions-wechat-qq-yy-data-breach-police) into the public when they were really meant to be shipped off to a government surveillance program, or that Facebook was again lying and [selling your account security phone number](https://www.eff.org/deeplinks/2019/03/facebook-doubles-down-misusing-your-phone-number) to every company who had spare change to spend on it, or some other equally dystopian nightmare. Unfortunately there's not a lot any individual person can do to prevent that sort of stuff (except maybe deleting your Facebook, which you should definitely do), but you can limit what you do out in the open by encrypting everything. <!--more-->

## Yes, that means **everything**.

For example, this dumb blog is nothing but pre-generated files, a bunch of html, css, and javascript spit out by jekyll on the server side, hosted purely statically. There's no possible backend exploit because there's no backend. Why I care whether it's securely encrypted? Because I'm not the only one who uses it (I saw at least 4 hits in the past 3 years, okay). If there's no end-to-end encryption, that means some bad actor in between me and you could be intercepting this content and altering it. That could be as simple as changing my words to make me sound like a real dipshit (if you don't like any of my posts I promise this is what happened), or changing a post to tell you that it's a great idea to install some weird Russian software package that spy on your machine and steal your credit card numbers. Or, most likely, inject some malicious code into the page content that will mine Bitcoins in your browser, or redirect you to their phishing site, or ask to install browser extensions, or any other number of nefarious things. It also prevents an ISP or government from altering content to censor stuff they don't want you looking at, like [a post on how to use a VPN to skirt their surveillance](/transmission-tunnel/). 

> *HTTPS Everywhere* is a bit like herd immunity. If we're encrypting everything, we're protecting each other. 

Luckily, this thing is hosted on GitHub Pages, so all I had to do was check a box and update my \_config.yml, and we're good to go. 

But this isn't the only place where my precious, human form interfaces with the internet. Though in this case, it's your more classic example of absolutely not trusting anyone who comes into contact with these exposed surfaces. I've got a whole bunch of web services semi-publicly accessible to the open internet: Plex, Transmission, Sonarr, Radarr, Netdata and Ombi. Securing these is more immediately important to the cause of my cool server friend Alonso not being used by someone in China as a botnet controller again (maybe I'll write that post someday).

## Plex Can Take Care of Plex Just Fine

![Plex Network Settings](/images/alonso-plex-ssl.jpg)

In the Plex server Network settings, there's a "Secure connections" dropdown that specifies how HTTPS is enforced. Setting it to "Required" will use Plex's own `\*.plex.tv` certificate for every connection that's routed through remote access. If you want, it also provides a few options to specify your own certs and a custom domain for remote access, but I'm perfectly happy to let them manage it.

## Let's Encrypt with Certbot <br /><small>(sometimes the future does sound cool after all)</small>

[Let’s Encrypt is a free, automated, and open Certificate Authority.](https://letsencrypt.org) That means they offer SSL certificates to anyone, on demand, at no cost. Before they came along, the main gatekeeping mechanism for ensuring the legitimacy of anyone using a certificate was that they cost an absurd amount of money and could be revoked if you were caught misusing them, which left anyone without a few thousand dollars to burn on their hobby project out of luck.

[Certbot is a tool provided by the EFF](https://certbot.eff.org/) to automatically fetch and install Let's Encrypt-issued certificates on your machines. It makes this whole process infinitely easier, especially when it comes time to renew. 

Certbot's "getting started" guide does a better job of walking you through installing certs than I could ever do, so I won't try. But in my case, it was only half of what I needed. The services I wanted to host with HTTPS run their own discrete server instances, so they're not directly supported by Certbot's options.

## Reverse Proxy to the Rescue

In the way that a regular forward proxy is a middleman for your browser to hide either your requests from the local network, or your client's actual identity from the remote server, a reverse proxy is a middleman that allows the server to present a single host, obscuring what might be going on behind the scenes on the server itself to actually respond to your requests. In a lot of cases, that reverse proxy might be something like a cache or a CDN to offload traffic, but in our case this is extremely helpful because it allows us to funnel all requests to a single server, running HTTPS with our new Let's Encrypt cert, protected with authentication, which can respond to requests from whichever service is needed. Think of it like using an ATM: you have to use the single screen interface to interact with your bank, it forces you to prove you're legit with your card and PIN, you have no idea what goes on behind the wall, but it can spit out money or information. 

This offers another bonus feature in that you no longer need to forward ports to expose the services directly outside of your network. The reverse proxy will pass all requests through your single external web server port (443 for HTTPS), and communicate with the services inside the network. No more opening up `:8080` and `:8989` and trying to remember which port is which service, and leaving them vulnerable to the whims of the open web.

Apache supports running a reverse proxy pretty straightforwardly, and Certbot integrates directly with it. Sounds like a pretty good match to me. Nginx also fits the bill but I happened to already have Apache 2.4 running for no good reason, and that's enough of an excuse for me. 

### Domain Setup

The whole point here is to have a single point of entry for all your hosted stuff, so a domain would be a great idea. There isn't much in the way of special configuration that's required to prepare it for HTTPS, but I'm anticipating your initial Apache virtual host conf to look about as basic as this (substituting my site for your actual domain of course):

{% highlight apache %}
<VirtualHost *:80>
    ServerName pettazz.com
    ServerAlias pettazz.com

    <Location />
        DocumentRoot /var/www/
        Satisfy Any
        Allow from all
    </Location>

</VirtualHost>
{% endhighlight %}

### Optional: Authentication

My collection of services has both servers that provide their own custom authentication mechanisms and some that don't, as well as a combination of things I want to allow "public" access to via user-specific accounts, and most that I just want to lock to a general "admin" user account and password. Combining them all into a single point of access also gives us an opportunity to simplify that. HTTP Basic Authentication is extremely straightforward and when combined with SSL, perfectly secure to use. This allows me to turn off the custom user login settings for things like Sonarr and Radarr, and wrap even services like Transmission and Netdata which don't have any authentication in the warm hug of a single admin login. 

First things first, we'll need to create this new admin user and store the credentials using `htpasswd`, in this example, creating an account named "mycooladmin":

    sudo htpasswd -c /etc/apache2/.htpasswd mycooladmin

It will ask you twice to enter the new password for "mycooladmin", and then write the encrypted credentials to the file. Using `sudo` means it will be private to the root user, which is good for security, but we'll also need to make sure Apache can read it, so we'll also need to `chmod 644` it.

You may also need to activate the `auth_basic_module` module if it wasn't already. You can do that simply:

    sudo a2enmod auth_basic

And then restart Apache (probably `sudo apache2ctl restart`).

Using the example of the extremely basic virtual host conf from above, we need to add a few directives to the main rule:

{% highlight apache %}
<VirtualHost *:80>
    ServerName pettazz.com
    ServerAlias pettazz.com

    <Location />
        DocumentRoot /var/www/
        AuthType Basic
        AuthName "Hello I am big secure server time"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
        Order deny,allow
        Allow from all
    </Location>

</VirtualHost>
{% endhighlight %}

- `AuthType`: specify that we're using Basic auth for all requests to `/` and any further paths on our host, so, everything
- `AuthName`: provide a helpful message for users trying to access it
- `AuthUserFile`: point to the credentials file we created with `htpasswd`
- `Require valid-user`: does exactly what it says, reject requests with invalid logins
- `Order deny,allow`: tells Apache that by default we're denying access from any hosts unless otherwise specified (this is not necessarily needed here unless you plan to add access restrictions by host or IP address for this or other `Location`s)
- `Allow from all`: immediately contradict our last statement allowing access to this location from any host. They'll still need to authenticate properly, but we don't block any addresses from getting that far, so essentailly the login page is publicly accessible.

This locks down everything under our new admin user, but what if we have a few services we don't want to include? In my case, I have one specific path that's used by an external service to monitor whether the server and/or network is up or down, so I want it to be totally accessible. We can add a `Location` that overrides our newly added settings for that specific path:

{% highlight apache %}
<Location /ping>
    Satisfy Any
    Allow from all
</Location>
{% endhighlight %}

We'll come back to this later to use the same strategy to open up a service which you *do* want to maintain its own authentication so that we're not adding an extra password on top of another login.

### Certbot Install

Again, I'm not going to waste everyone's time by doing a bad job replicating Certbot's guide here, so follow the Apache setup guide to get started and then head back here to create the reverse proxy.

### Add Some SSL

Now we'll update our virtual host to support SSL. Certbot may have made some or all of these changes on its own, so I'll just show what a working SSL config looks like:

{% highlight apache %}
<VirtualHost *:443>
    ServerName pettazz.com
    ServerAlias pettazz.com

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

    SSLEngine on
    SSLProxyEngine On

    SSLCertificateFile /etc/letsencrypt/live/pettazz.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/pettazz.com/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf

    Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"

</VirtualHost>
{% endhighlight %}

> Certbot may wrap your whole configuration in an `<IfModule mod_ssl.c>` block just to avoid startup issues on servers where it's not fully supported, but since the goal here is SSL or bust, I think it's fine to make Apache fail to even start up if SSL is not properly supported.
{: .notice}

The main things to note here are that our VirtualHost is now listening on `*:443` for HTTPS, rather than HTTP's port 80, and we've added a few top level directives that enable SSL, and point it to our certificates. 

At the end, we also now always set [the Strict-Transport-Security header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security), which strictly enforces to clients that this domain is always to be accessed via HTTPS only. If you're also hosting insecure stuff on this domain (what part of HTTPS *EVERYWHERE* are you not getting?) then you'll need to remove this or they'll be blocked. If you keep it, you may also need to enable Apache's headers module which is sometimes not enabled by default. You can check to see if it is with: 
    
    sudo apache2ctl -M | grep headers

If `"headers_module"` isn't listed, you'll need to enable it:

    sudo a2enmod headers
    sudo apache2ctl restart

Your configuration may vary on this part depending on Certbot's infinite wisdom, so don't worry about conforming identically to someone else's example SSL settings. 

### Add Some Reverse Proxy

Finally, we're ready to create the proxy. We need a few more Apache modules enabled before we can get this up and running:
    
    sudo a2enmod proxy
    sudo a2enmod proxy_http
    sudo a2enmod rewrite
    sudo apache2ctl restart

We turn on the SSL proxy engine (and RewriteEngine which may be used later) and the in our config by adding:

{% highlight apache %}
SSLEngine on
SSLProxyEngine On
RewriteEngine On
{% endhighlight %}

Then add directives to disable forward-proxying (we only want reverse), and to preserve the `Host:` header through the proxy so that the services can still behave as if they're being accessed directly:

{% highlight apache %}
ProxyRequests Off
ProxyPreserveHost On 
{% endhighlight %}

And now we're ready to add some proxy rules. 

For Sonarr, Ombi, and others, the URL path can be set in their own settings tabs. For Transmission, you will need to edit your `/etc/transmission-daemon/settings.json` file (make sure the service is stopped while editing this file) to update the `"rpc-url"` key, setting it to something like `"/transmission/"`. Once the path is changed, we only need to set two directives:

{% highlight apache %}
ProxyPass /transmission http://127.0.0.1:9091/transmission
ProxyPassReverse /transmission http://127.0.0.1:9091/transmission
{% endhighlight %}

We essentially tell Apache that for requests to `/transmission`, we actually want to proxy them to an internal server location `http://127.0.0.1:9091/transmission`. These paths can of course be anything you want them to, I just find that naming it after the service it points to is oddly intuitive for some reason.

For services that are strict about path matching like Netdata, we can use Apache's `mod_rewrite` to take care of it:

{% highlight apache %}
ProxyPass /netdata http://127.0.0.1:19999/
ProxyPassReverse /netdata http://127.0.0.1:19999/
RewriteRule ^/netdata$ https://%{HTTP_HOST}/netdata/ [L,R=301]
{% endhighlight %}

The `RewriteRule` will invisibly rewrite any URLs that are missing the trailing `/` to include it. So even though Netdata only works when you directly visit `https://yourdomain.biz/netdata/`, it will now also work just fine on `https://yourdomain.biz/netdata`. It's a seemingly trivial thing but it can save you a lot of confusion later on. 

After these changes, this is my complete example Apache virtual host conf:

{% highlight apache %}
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

    SSLEngine on
    SSLProxyEngine On

    RewriteEngine On

    SSLCertificateFile /etc/letsencrypt/live/pettazz.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/pettazz.com/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf

    Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"

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
{% endhighlight %}

Note that for Ombi, I want it to be publicly available and manage authentication on its own, not using my `htpasswd` admin login, so I also added a `<Location /ombi>` block to exclude it from basic auth.

> Remember to restart Apache after any config changes (`sudo apache2ctl restart`)! The number of combined hours I've wasted trying to figure out why my new config change doesn't work when it's just because Apache hasn't reloaded it is truly embarrassing.
{: .notice}

## Safe and Secure

This is by no means a complete and exhaustive guide, but it's hopefully at least a starting point for most other homelab nerds out there just trying to make progress in the direction of HTTPS everywhere. Someday our dreams will come true and we can work together to decide on a new use for all those now unused port 80s out there.