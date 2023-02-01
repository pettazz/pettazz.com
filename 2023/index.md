---
layout: timeline
title: "2023: A Busy Year"
comments: false
share: false
image:
  feature: 2023.jpg
---

The official Year of Making Stuff Live Tracker™ is finally here, sort of. Still in progress so expect changes, but I suppose this is the rough shape of my accountability death pact page. <a href="/year-of-stuff/">I did a <strike>better</strike> job of explaining what this is all about here</a>.

<div class="timeline">

  <h1><small>February</small></h1>

  <p>Welcome to month two of Doing Stuff, today I have added the post indices, the basic listing of all posts in each category. It's fine for what it is, but I think it's gonna need a little more attention before I can use the same template to fill the home page with recent posts.</p>

</div>

<div class="timeline full-31">

  <h1><small>January</small></h1>

  <p>Last day in January seems like a good time to do something more creative so I drew a bunch of awful, ugly faces and immediately deleted it. To be fair, the intention here wasn't to invent The Perfect Face Design or anything but just to practice doing anything at all and to get weird to see if anything came out in a way I liked. It didn't.</p>

  <p>Share links! I only added them because <code>navigator.share()</code> makes it incredibly easy and I already have the "copy to clipboard" hack has a fallback from WNV. Otherwise I would simply not care, I say lying to myself knowing full well I still would have spent as much time making sure the Open Graph tags were carefully correct for every page because I'm a horrendous perfectionist.</p>

  <p>And there you have it, a post page for both categories: drawn and written. I actually cannot think of anything left bugging me to be fixed here, which is probably a first for me. They do break quite badly on narrow mobile screens but I think that's best saved for after the whole site is done, because who knows what else I'm gonna change in the meantime.</p>

  <p>Turns out we definitely need a little bit of a scrim over header images and post previews to make sure the text is readable, a pretty quick and easy fix with <code>:after</code>, but I'm really tired today so that's all you're getting!</p>

  <p>This <a href="https://www.pausly.app/blog/accessible-hamburger-buttons-without-javascript" target="_blank">blog post about accessible hamburger menus that don't rely on Javascript</a> outlines the exact thing I was trying to do for Fart Depot and even as far back as the latest version of WNV. If you inspect the W icon on any post page you'll see that it's actually a <code>&lt;label&gt;</code> for a non-displaying checkbox, and the Javascript for hiding/showing the sidebar menu relies on that checkbox state being changed. I wanted to just use the CSS <code>has()</code> pseudo-class but even now that's <a href="https://caniuse.com/#feat=css-has" target="_blank">still not available in lots of browsers</a>, so I quit and used the JS. But they've found a pretty clever way to make it work in pure CSS. So obviously I tore apart the menu toggle I had already written for Fart Depot and started trying to implement it this way, only to find that I set it up a little differently and it won't work out of the box. So negative progress is today's creative endeavor, I guess. A website that's slightly more broken than yesterday, enjoy!</p>

  <p>I found a very nice writing app that lets you edit directly in markdown with live preview and some helpful library organization features. The best part though, that's the focus assist. The cursor's line is always at the center of the page, and as you type sentences the previous text is dimmed slightly, keeping your focus on the current one. It's subtle but surprisingly effective! <a href="https://ia.net/writer" target="_blank">It's called iA Writer</a> and I must have bought it a long time ago because it was already sitting unopened on my Mac and I cannot imagine I would have paid fifty dollars for it. Anyway, I wrote some more nonsense today!</p>

  <p>This one I might not post, actually. This feels like I'm courting disaster like in the 5th grade when I tried to write a Goosebumps knockoff in English class and my parents got called to talk about the "disturbing violent imagery" of the scene where a ghost or something chopped the narrator's head off. It's fine, it was a dream, he was fine! Anyway, it's not to say that this is necessarily violent or disturbing, but it would definitely get me kicked of Twitter today and that's as detailed as I'm gonna get.</p>

  <p>*i drew it* posts are going to be a little bit trickier it seems. I like the idea of essentially keeping the written page design and just applying the same body with a light shadow on the images themselves with no padding around them. But I am once again puzzled by varying dimensions. I could decide that everything will be a standard size and design the page around that expectation, but that feels like it doesn't really fit the vibe of posts being anything at all on this website. So I think I will have to decide on a max-width for the displayed images and just scale down if it's ever any bigger. I feel like click to zoom tools are almost always anoying and clunky, so maybe it'll just be a link directly to the plain image itself for you to view however works for you.</p>

  <p>I've added the "similar posts" stuff which I like but I'm not sure it fits with the theme very well. I'll just leave it as is until I start messing with these types of post preview box things on the home page; that's where I'll really have to decide on their style.</p>

  <p>Now that's what I call a hidden menu. There's a small version of the logo (a "logomark") fixed floating in the corner all the time and no other real website chrome to speak of, it's all <strong><em>content</em></strong>.</p>

  <p>I always had a suspicion but I can now confirm that I do enjoy writing these little stories. Whether that could ever translate into anything bigger there's no way to know, but coming up with a tiny narrative is fun and wrapping it all up at the end is incredibly satisfying.</p>

  <p>Blobs are hard, it turns out. Also pretty ugly! Forget blobs, although I had a fun time splashing them around the page like I was accomplishing something.</p>

  <p>Blobs. We're all about blobs now. The menu will be a big stinky ink blob that gets splashed onto the page when you click the mini-logo on content pages. I want all the *stuff* to be at an absolute minimum and for the actual content to be the focus, so we'll just have a smaller version of the hand drawn font logo floating in the corner, which will blob the menu blob so you can go to a different page or whatever, but that's all. And the footer. I should clean that up the busted WNV copypasta looks like dogshit.</p>

  <p>Sometimes you spend a bunch of time making an animated menu that slides up and down out of view like the hidden taskbar in Windows 95 and then you look at it for about 30 seconds and realize you hate it. We've all been there, man. It'll be just fine.</p>

  <p>We now have, if I do say so myself, a very nice page template for written content. I don't love the header/menu so the next step will be some kind of hidden menu that reveals itself when you click the logo or whatever. A very new concept for me that I don't remember ever seeing before.</p>

  <p>Took a break from websiting to do some actual creative content, what a nice change of pace that was. You still can't see it though, not until I *finish the damn website*.</p>

  <p>Very possible that I spent too long on making a menu and remembering anything about CSS, but hey now they got a <code>image-set</code> CSS function (still neeeds a <code>-webkit-</code> prefix but hey pobody's nerfect) that makes @2x images a lot easier, so that's neat.</p>

  <p>Standing up an actual website now, finally, at <a href="https://fartdepot.biz" target="_blank">fartdepot.biz</a>! I remember absolutely nothing about how to use Bootstrap so maybe reusing it as the CSS framework isn't the best move. Oh well, too late, there's already a coming soon page!</p>
  
  <p>Say hello to <a href="https://github.com/pettazz/flying-jekyll" target="_blank">Flying Jekyll</a>, a skeleton for getting a Jekyll site automatically building and deploying on every commit via <a href="https://fly.io" target="_blank">Fly.io</a>. This is what the new website will be using, and this is a handy base for anyone to use, including myself because I clearly cannot stop making Jekyll sites.</p>

  <p>The amount of time I have spent just drawing random garbage only to land on "hand drawing the domain name in a nice font" as the "logo" such as it is, is truly disgusting. But hey at least I have something I like now, so that's progress. Why does this stupid website that's just a dumping ground for content need a "logo" anyway? Because I simply cannot help myself and get a perverse joy out of obsessing over truly meaningless details. Obviously.</p>

  <p>What do you know, we have the total package here for a automatic build and deploy. It's honestly amazing how much incredible functionality you can get for free from places like GitHub (until you need a lot of resources, I suppose). It probably costs Microsoft the equivalent of the six dollars in quarters I dropped behind the washing machine one time, but it's still nice. Now I just have to make it look like something and start dumping all my content into it.</p>

  <p>I've got a nice little build and deploy machine working here, using <a href="https://fly.io" target="_blank">Fly.io</a> to run remote builds and deploy on their network, which they make really easy with their <code>flyctl</code> tool and a multi-stage Docker build. Next steps are to make a semi-CI/CD setup with GitHub actions and then make it a generic "base repo" that can be forked to create your own site making use of this stuff with a minimal amount of setup (fart depot dot biz will be one such site).</p>

  <p>The Occluded Website continues to come together. You'll love it when you finally get to see it. Or maybe you won't but I don't care because I like it quite a bit.</p>

  <p>It's been a tough few days realizing that I don't know how to design websites that are fun and not what you might generously call "businesslike" these days. The last time I did it was for WNV in 2019, and before that who knows. Anyway expect some incredible silliness and probably a fair amount of feeling like you're back in the heights of 2013 style.</p>

  <p>Now this may come as a shock but I intended to start putting together the new website but got absolutely bogged down in the design details. I'm talking picking out colors and making some "branding" for this hypothetical website, not even what kind of layout it's gonna have. But I'm pretty happy with how it came out, basically hand drawing a nice font I didn't pay for and doodling some lines to build a website out of. You'll love it too when you see it, eventually, I'm sure.</p>

  <p>As promised, started working on the <em>other</em> place to put creative type stuff because it just doesn't fit the vibe here on nerd blag. Fart Depot dot biz will be made up of two sections, "I wrote it" and "I drew it" and of course be another highly automated Jekyll site. Today's <em>thing</em> in particular was mucking around with a design for it which is pretty simple but incredibly silly (if I can actually write the code to make it work).</p>

  <p>It's another written bit that you'll just have to believe me on for the time being. I promise I'll get this stuff sorted soon. Probably.</p>

  <p>Why, this very page you see before you! Still needs a fair amount of help, specifically templatizing it so I don't have to do so much manual editing each day and can use markdown in these little blurbs. I'd also like to add a little graphic for "type of thing" to indicate whether it was writing or a doodle or some coding nonsense, but it's off to a good start if you ask me. Original cool timeline thing taken from <a href="https://codepen.io/letsbleachthis/pen/YJgNpv" target="_blank">this CodePen</a>; I feel like I learn ten new things about CSS every time I do anything with it these days.</p>

  <p>500 words in the creative style that I don't have a place to post just yet, so you'll just have to take my word for it until I get that figured out, so <code>//TODO</code></p>

  <p>This was some work on the project I've been calling Delphi, a Raspberry Pi desk clock display sort of thing. I had an incredibly poorly written prototype years ago and am now trying to turn it into something usable and stable. This latest commit is actually a massive one including a ton of rewriting I had already been poking at for the past few months, but importantly today's changes were starting to write the weather modules using one API and then immediately giving up on it and switching to another that works better for what I need (<a href="https://pirateweather.net" target="_blank">Pirate Weather</a>). <a href="https://github.com/pettazz/delphi/commit/8295ab14a8961591cdddccb01901d8fd45cd182a">Check it out here</a>.</p>

  <p><a href="/year-of-stuff/">The blog post about what I'm doing here</a>. I understand that you may well consider this a sort of a cop out but I think 500 words are 500 words and as that is the totally arbitrary goal number I've set for this type of thing, it counts. So I simply don't know what else to tell you.</p>

</div>

Header photo by <a href="https://unsplash.com/@planetvolumes?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Planet Volumes</a> on <a href="https://unsplash.com/photos/v_CQ10cps_Y?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
{: .notice}