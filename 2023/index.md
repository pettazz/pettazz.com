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

  <h1><small>January</small></h1>

  <p>Took a break from websiting to do some actual creative content, what a nice change of pace that was. You still ca 't see it though, not until I *finish the damn website*.</p>

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