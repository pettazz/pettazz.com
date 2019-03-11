---
layout: post
published: true
title: Stealing My Friend's Wedding Photos
tagline: "I mean, kind of. Only the low-res versions. So low-res theft. It's like a misdemeanor at best."
tags: [blag, javascript, photographers, scrapers, bash, automation, problem solving]
comments: true
image:
  feature: photo-theft.jpg
---

The web is a wild, untamable mass of infinitely shareable information. It was designed to be entirely open; anything on it would be downloadable by anyone else with a connection. This is the reason your browser has a "Save image" menu option when you right click a photo and not even the most proprietary-focused, litigious, IP-clutching companies can do anything about it. So when I headed over to the album that my friend's wedding photographer had posted, and saw that right clicking was blocked, I was filled with the spirit of Stallman himself and a self-righteous drive to free these photos from their DRM-ish prison.<!--more-->

![Stallman is the one truth](/images/stallman.png "Just don't wear sandals around him.")

Just kidding, I wanted to share some of them and I was too lazy to pick out individual photos, so I wrote a crappy scraper and downloaded all 278 of them. 

After a little bit of prodding around the elements panel and tossing click events around, I had a pretty good idea of how the thing worked. The filenames were non-sequential, so I had to rely on the UI to get them. The full sized (not original, but better than thubnail) images were only loaded once the thumbnail was clicked, so I had to simulate that event. The site uses an alternating layer of two main image display ````div`````s to show the currently selected image, but only moves the new one to the front once its image has finished loading. So the easiest way to iterate through the album would be to actually simulate the click (which in actuality turned out to be mousedown) event on each thumbnail, wait a few seconds, and then grab the url of the image in the forefront of the main stage, until there were no more thumbnails to click.

<script src="https://gist.github.com/pettazz/5975b296fe3bbe187e856f73d7eeda67.js"></script>

All I needed to do was dump this into the console, take the dogs for a walk, and I'd have a list of all the photos to download. The next step was figuring out what to do with this list, since browsers (thank god) aren't allowed to just interact with the local filesystem. 

Conveniently, the Google Chrome console has a built in ````copy()```` function which allows you to copy arbitrary data to the system clipboard. So a simple one-liner could prepend the base URL to all of the scraped paths, and then copy the whole array to my clipboard.

{% highlight javascript %}
copy(JSON.stringify(
    urls.map(function(url){ 
        return "http://www.probably-shouldnt-mention-the-actual-website.com/" + url; 
    });
));
{% endhighlight %} 

Once I pasted the array into a real file and saved it as ````pics.json````, I could do some basic bash wizardry to parse the list and download each one, then give them each a reasonable filename.

{% highlight bash %}
arr=( $(cat pics.json | jq -r '.[]'))
mkdir pics
cd pics
for i in "${arr[@]}"; do echo $i; curl -O -s -S $i; done
for f in *.jpg*; do mv "$f" "${f/.jpg*/.jpg}"; done
{% endhighlight %} 

I'm sure there's a way to tell ````curl -O```` to actually download each file directly to the simple ````*.jpg```` filename and drop the querystring, but did I mention that I am very lazy and this works perfectly?

From here, it's a simple matter of dumping these photos into an iCloud Photos shared album and it's time to roll out the mission accomplished banner.

### The Point

By now you might be thinking "why did I just read this inanity?" And you'd be right, that's a good question. The moral of the story is that when you live in this digital world of infinite information, you should never give up on trying to make it behave the way you want. It's all out there, and you can do _anything_ you want with it. This post is as much a reminder to myself as it is a how-to for you that there's always a way. It might require a little extra thought and a sprinkling of bash one-liners, but the bits and bytes can always be reassembled in whatever way is the best for any situation. And this time, it actually helped make sharing my friend's wedding photos with all of his friends and family a little easier. 