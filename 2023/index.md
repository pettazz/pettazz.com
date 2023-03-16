---
layout: timeline
title: "2023: A Busy Year"
comments: false
share: false
image:
  feature: 2023.jpg
---

The official Year of Making Stuff Live Tracker™ is finally here, sort of. Still in progress so expect changes, but I suppose this is the rough shape of my accountability death pact page. <a href="/year-of-stuff/">I did a <strike>better</strike> job of explaining what this is all about here</a>.

<div class="timeline current">

  <h1><small>March</small></h1>

  <p>Don't tell anyone but while I release software into the wild I doodle nonsense on my iPad. Today I drew a toilet. And some other things. But mostly toilet. You can see it in the background on the home page of known web site <a href="https://fartdepot.biz/" target="_blank">Fart Depot dot Biz</a>. I'm thrilled with how it turned out, it's exactly the kind of chaotic nonsense I was hoping for, and I'm sure will only get better as it expands and I can start scrolling it.</p>

  <p>Shocking news: I appear to have broken the Raspberry Pi I intend to use for Delphi yet again. It seems to keep losing its network connection or maybe just the IP lease for some reason. I can reset it but then it just fails again after a while. I think I have to just get a newer 4, but I also don't remember like 90% of what I did to set this thing up in the first place so that should be fun.</p>

  <p>Poking around with the <code>recurring-ical-events</code> library seems pretty good at first look, but the issues with <code>ics</code> weren't apparent until it was left running for a while anwyay, so we'll see how it goes.</p>

  <p><a href="https://fartdepot.biz/wrote/2023/03/11/" target="_blank">This one was kind of an experiment</a> in writing more dialogue-heavy, which is pretty outside my usual style of aggressive exposition. Don't get any ideas, this is not based on any particular real experience.</p>

  <p>Doodles during meetings is all I have to offer you today I'm afraid.</p>

  <p>Calendar events still elude me on Delphi. I'm using <a href="https://pypi.org/project/ics/" target="_blank">ics</a> to fetch my personal calendars and recurring events are coming to me in an absolutely inscrutable order/timing. Since the last time I worked on this years ago it looks like there's <a href="https://pypi.org/project/recurring-ical-events/" target="_blank">a promising new library</a> that aims to solve exactly my problems. But I've done enough harm to my brain for one day.</p>

  <p>I still feel <em>unwell</em> but I did some more of that big doodle today. It's nearly big enough to test out so I can't wait to find that it looks like dog shit and that I wasted all this time on it.</p>

  <p class="skipped">I don't like how colds seem to work these days, I can tell you that much for sure.</p>

  <p class="skipped">I remain sick!</p>

  <p class="skipped">I got sick!</p>

  <p>Well at least I've decided on the basics of a color scheme for Slike, but I think I need to take a bit of a break from beating my head against a blank Pixelmator document. So instead it's back to Delphi again, rewriting the big nasty weather module from the old version with the new API and better design.</p>

  <p>I am determined to make some kinda website design here. I have been messing around with the idea of "weather faces" and I realize exactly how silly that sounds but I did say I wanted to do something weird and different here! And yes, one of them is a cloud with sunglasses on, obviously.</p>

  <p><a href="https://fartdepot.biz/wrote/2023/03/02/" target="_blank">I'm cheating a little on this one</a>; I started this a long time ago so it's actually sort of a rewrite of some existing stuff I never did anything with. Will it go anywhere, who knows! Knowing me, probably not.</p>

  <p>I am doodlin' all over the place, trying to get a workable background scribble and/or another attempt for Slike. Does anybody remember how to have new ideas? I think I forgot.</p>

</div>

<div class="timeline full-28">

  <h1><small>February</small></h1>

  <p>I'm really not keeping up my end of the bargain about posting these things when I make 'em, huh? Oh well! too bad! I guess I should hook FD up to IFTTT or whatever for posting on socials too but I am finding it incredibly difficult to give a shit about those. Anyway, <a href="https://fartdepot.biz/wrote/2023/02/28/">I made this one today</a>.</p>

  <p>It's back to scribbling during meetings for me today. It's getting bigger but still needs to be a lot larger to convincingly fill in that huge forehead I built into the site.</p>

  <p>I am intentionally holding off on starting any backend-type work for Slike because I know I will immediately fall down that rabbit hole and be so tired of the whole project that I just crank out the most generic Bootstrap UI ever seen and call it a day. Instead I made a prototype (incredibly liberal use of that word) UI based on a doodle I drew earlier and I'm glad I didn't spend too long on it, because it looks like ass. I don't like it! Back to the literal drawing board (medieval English term for iPad).</p>

  <p>I got the idea in my head to use section colors for the <code>&lt;meta name="theme-color"&gt;</code> on <a href="https://warrantynowvoid.com">WNV</a> posts which I thought would be a very simple update. Obviously, I was wrong and in the time since we've stopped posting, the build has gone to hell. I guess maybe using an EOL version of Ruby does have at least one drawback after all! Who knew? Anyway, seems like I'm stuck here, I would have to upgrade all the Ruby stuff and I think use a custom AWS build image with newer versions and that all sounds exhausting. So it looks like this will be a bigger project and these static html files will stay exactly as they were on July 21, 2022 until then. Fuck! Oops! It's fine the colors didn't actually look that great anyway.</p>

  <p>To look halfway decent it's gotta be huge though so even though I've made a pretty good chunk of silliness, it's probably only like a tenth of what I need. Wild! Maybe once it's big enough to fill the space I'll just start using it and make it progressively larger as I add more.</p>

  <p>Like, a lot.</p>

  <p>I mean, I've had a lot of meetings.</p>

  <p>It's been a busy couple days at my <code>normie day job</code> so I have spent a lot of time in meetings idly doodlin' on the big nonsense thing for the FD header.</p>

  <p>Sort of a cop-out again but I copied a bunch of old stuff (including the as yet unposted things mentioned below) into posts on Fart Depot dot Biz. Now it has real content instead of weird test posts! And from today on I'll post there whenever I make new stuff.</p>

  <p>Small tweaks for not looking like dog shit on mobile (small) screens. I really need to learn to do this as I go because tacking it on after is way more annoying.</p>

  <p>I done the dang footer, finally, okay? Isn't it incredible?</p>

  <p>From all the way back on Jan 27, I finally actually redid the hidden menu to use the accessible pattern from that blog post. It looks the same but it works better so that's cool.</p>

  <p>Now that I have a domain for it, I'll say that the new site is going to be called Slike. Yeah it's weird but it'll make sense eventually, I swear. The most important thing this backend needs to be able to do is quantify the "niceness" of weather at any particular time on a few different axes like temperature, precipitation chance/amount, wind, etc. The plan is basically count each measurement's difference from "good" (70°F, no rain, etc) then multiply by two coefficients for each: one to "normalize" it to the same scale as the others (a difference of 10 units of precipitation [inches] and 10 units of temperature [degrees] are pretty massively different) and one for weighting its importance, which combined will give us a kind of score for that set of readings. To start off I'm using a spreadsheet to see if any of these numbers actually make sense before I write any kind of code about it.</p>

  <p>After doing a little more reading on I2C and the Flipper tools I'll put that one on hold for a bit, not because it seems overly complicated (the Flipper tools are really great actually) but because I already have too many things going on and I should probably finish one of them once in a while. For now it can just be a part of the delphi display.</p>

  <p>I suppose now that the site actually works aside from a few purely aesthetic issues I could start actually posting stuff like what I wrote today, but it turns out I am physically incapable of using it before it is 100% done and perfect because of how good and regular my brain is!</p>

  <p>While I <em>ruminate</em> on what the new site should look like, I've been poking around different frameworks for actually making it. It's going to be a fairly straightforward single page app that makes requests to a backend caching proxy so I don't overdo my limited requests to the actual API, something <a href="https://pettazz.com/stonks/">I've already done</a> a few times before. But once again, I want to do something new and interesting here, so I've decided to double down on my Fly usage with <a href="https://fresh.deno.dev" target="_blank">Deno's Fresh</a> on top. It looks totally different from anything I've worked with before, and that's kind of the selling point for me here! Of course reading the docs and digging through some of the examples will probably be most of what I do here for the time being.</p>

  <p>CO<sub>2</sub> sensor update: I put together a dumb little python script to read it and print directly to stdout every few seconds. Of course, it's using Adafruit's own CircuitPython library which abstracts almost all of the actual I2C communication away, so I didn't exactly learn much here except that the sensor does in fact work and that I have a new mysterious issue with my Raspi constantly disconnecting itself from Wi-Fi. It's great and all that there are so, so many tutorials and libraries and people messing around with this kind of electronics stuff these days, it can become a real nightmare to search for stuff; just looking for a basic explanation/tutorial of the I2C protocol gives you pages and pages of fun Raspberry Pi projects using the same libraries and not much in the way of learning how it actually works. So I'll be doing a lot more research here it looks like.</p>

  <p>I wrote another short one today; I worry that maybe I'm trying too hard to have a little M. Night Shyamalan twist to every one of these, but this one was fun so I regret nothing.</p>

  <p>Back to the previous detour: I've settled on a name with some help from my local clever naming savant, got a fancy domain and started doing some vague sketches of what it'll look like. I could always just follow the Dark Sky (RIP) template that everyone does but I want to do something interesting here, so at the moment no idea is too wild 'n wacky. I have an idea of the basic functionality so it's just a matter of having fun with how it will be displayed. More brainstorming to come, I suppose.</p>

  <p>Okay so I realized after I already had it that I could hook this thing up to my <a href="https://docs.flipperzero.one/gpio-and-modules" target="_blank">Flipper Zero's GPIO pins</a> and have a mobile gas testing experience. Seeing that the built in app for GPIO seems to only be about outputting to addresses, and this <a href="https://github.com/NaejEL/flipperzero-i2ctools" target="_blank">I2C tools app</a> is pretty basic, I figure this is likely a "build my own specific app" situation. It's about the same time that I realize I don't actually know how I2C works practically and haven't written C in nearly 15 years. Uh oh!</p>

  <p>Detour Detour: I decided to get a CO<sub>2</sub> sensor. Why? Well, you see I read <a href="https://www.theatlantic.com/health/archive/2023/02/carbon-dioxide-monitor-indoor-air-pollution-gas-stoves/672923/" target="_blank">an article about a lady who got one and it ruined her life</a>. So I instantly, without a moment's hesitation, decided, "Cool! Me next!" Of course, being the way that I am, I won't spend $80 to buy one that already works, but I will end up spending probably three times as much and infinitely more of my limited time on this earth to hack one together instead! I decided to go with the <a href="https://www.adafruit.com/product/4867" target="_blank">the Adafruit SCD-30 here</a> and hook it up to my Raspberry Pi, using their demo scripts to get it working. Lucky for me it turns out I don't have cognitively impairing levels of CO<sub>2</sub> in my house, so I guess I have to find another excuse for... all this.</p>

  <p>Detour: I have an idea for another simple one-off website that shows you one important thing, but this time it's actually useful. I won't write out the full idea here in case Intellectual Property Thieves are looking for easy targets (this will obviously make me fantastically wealthy, somehow), but I will still talk about the details of each step as I go like anything else. I don't intend to actually do it until I finish with Fart Depot dot Biz, but I did some poking around today to see if it's even possible and pick out a name and domain and all that stuff.</p>

  <p>I drew a few more menu elements today with the intention of replacing some or maybe all of the Font Awesome icons with my hand drawn ones, and boy! Did that look like shit! Wow! Nevermind! Yikes!</p>

  <p>Slightly better homepage, still doesn't really do it for me but I can't figure out why so I suppose it'll be fine for now.</p>

  <p>I have this completely abstract idea in my head for a wild doodle behind the logo on the home page, so I've started working on that and also started realizing that it's going to take a while to become what I want it to! But it's really just mindless intricate doodlin' so it's a nice way to spend some time, actually.</p>

  <p>Basic page template for the about and license pages, also the silly text to fill them in. Incredibly lazy today. No more brain for me, thanks.</p>

  <p>This is certainly a home page, you cannot argue that. I do not like it. But at the same time I don't know how to make it something I do like. It feels half-assed and put together out of other page pieces as an afterthought, probably because it is. I think I'm gonna be pondering this one for a while.</p>

  <p>Welcome to month two of Doing Stuff, today I have added the post indices, the basic listing of all posts in each category. It's fine for what it is, but I think it's gonna need a little more attention before I can use the same template to fill the home page with recent posts.</p>

</div>

<div class="timeline full-31">

  <h1><small>January</small></h1>

  <p>Last day in January seems like a good time to do something more creative so I drew a bunch of awful, ugly faces and immediately deleted it. To be fair, the intention here wasn't to invent The Perfect Face Design or anything but just to practice doing anything at all and to get weird to see if anything came out in a way I liked. It didn't.</p>

  <p>Share links, I hate them! I only added them because <code>navigator.share()</code> makes it incredibly easy and I already have the "copy to clipboard" hack has a fallback from WNV. Otherwise I would simply not care, I say lying to myself knowing full well I still would have spent as much time making sure the Open Graph tags were carefully correct for every page because I'm a horrendous perfectionist.</p>

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