---
layout: post
published: true
title: "Russian Roulette as a Service"
tagline: "GitHub Pages was a great place for hosting a site, until it wasn't."
tags: [blag, jekyll, fly.io, github, hosting, platforms, flying-jekyll]
image: servercage.jpg
imageCredit:
  link: https://unsplash.com/@tvick?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash
  display: Taylor Vick
  
---

For years this blog was published on [GitHub Pages](https://pages.github.com), the set it and forget it Jekyll static site building, deploying, and hosting service offered 100% free of charge. It's integrated with GitHub where you're presumably already dumping all your code, and it completely shelters you from any of that nasty build process or its dependencies. What's not to love?

Well, when it stops working with your code because of changes they made on the platform side, that's what. 

I won't get into too much detail on the actual bug that kicked all this off, since there's plenty of discussion about it and people trying to find workarounds for Pages build failures on the [Jekyll repository issue](https://github.com/jekyll/jekyll/issues/9544), and that's not really what my gripe is about. In a nutshell: a change was made to a plugin that's used in the GitHub Pages build that causes an error when it tries to get an `excerpt` on page types that don't have that field, and depending on how you've configured your particular site and theme it may prevent your whole site from building. This means you might not notice anything at all and keep `git push`ing your way to happiness, or, like me, you might just suddenly not be able to publish any of your vitally important content.

Now, there are plenty of workarounds for this: you could switch to GitHub Actions and specify the versions of the gems you want to use, or you could just make changes across your site to make sure it doesn't trigger the bad excerpt code. But the whole point of using GitHub Pages was, as I understood it, that I didn't have to do any of that stuff. It's supposed to be a platform that imposes hard limits on what it will allow you to do so that it can keep things simple and stable within the confines of those limits. If we're still getting bugs introduced into that mix, breaking the *stable* part of it which we then have to do a bunch of work to fix, killing the *simple* part of it, then what am I living with these limitations for?

If a surprise change on the platform suddenly means I am completely blocked from making changes until I revamp my code to solve some mystery error, then the tradeoff of letting someone else manage all the dependencies seems to hardly be worth it. I don't think I want to sign up for Russian Roulette as a Service: yeah it'll *probably* be totally fine most of the time until it suddenly catasrophically is not. 

GitHub Pages is for the most part a pretty low-stakes example of this sort of thing; most people are not running critical parts of their infrastructure on there, but just because something isn't *critical* doesn't mean it's not valuable. I like posting my silly little posts and when I can't do it, it frustrates me. Many, many projects publish their documentation via Pages, so they may be incorrect or outdated after a release. Everything is some amount of important to someone, otherwise we wouldn't bother putting it up on the internet in the first place.

This mess is an object lesson in two things: 

1. Letting someone else take full control over your build, deploy, and host pipeline is always a dangerous proposition. They have to maintain their platform and that means it can't languish away. Security updates and EOLs are a fact of life, and they're not going to risk running some exploitable old code just because you've depended on it since 2012. 

2. You can't put off untangling the Gordian Knot of dependency hell forever, eventually the price will come due. Tools and platforms that promise to keep all that messiness off your plate are not doing you a favor, they're just obscuring it from you like a second grader who's hiding the fact that his hamster died a week ago. It's still all there, rotting away, and it's only going to get worse to clean up the longer you ignore it. 

## So How'd You Post This Then?

Thanks for asking. Astute readers may have caught that the first sentence says that this *was* published on GitHub Pages. I've moved it to hosting on [Fly.io](https://fly.io) instead, using [a skeleton that I put together last year](https://github.com/pettazz/flying-jekyll) for exactly this purpose. It's set up to specify useing [Fly's remote builders](https://fly.io/docs/reference/builders/) to launch a Docker container where it can install all the dependencies and run the Jekyll build, then copy the generated static site files to another container running a simple Nginx server to host it. It's got some preconfigured settings to get you set up with running this produced image as a basic app, a GitHub Actions workflow to automatically trigger it on commits, and in the Readme I've tried to capture the straightforward steps to setting up a domain and HTTPS certificates. It's as painless as I can possibly make it, and I can confirm this with the evidence that I used it to port this site from GitHub Pages to Fly in about an hour (most of which was waiting for my old domain DNS records to time out).

Sure, Fly is not free, but hosting a static site is relatively cheap unless you have a massive audience, in which case you got kicked off the free GitHub Pages a long time ago. But most importantly, you're back in control of your own dependencies from the ground up. When something breaks or needs updating (you can still take full advantage of [GitHub's Dependabot](https://github.com/dependabot) on your repo!) the timeline and implementation of it is up to you. No surprises. 