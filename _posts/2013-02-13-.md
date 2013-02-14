---
layout: post
published: false
---

After dealing with Selenium testing on Internet Explorer for some time now, I've learned one thing in particular: IE is horrifically self-destructive. I don't know exactly what it is, but the more it's used for tests, the more quickly its performance degrades. I would think it has something to do with the fact that Firefox and Chrome each are started with new user profiles each time Selenium runs, a feature that IE doesn't support, but I have no real idea what the cause is or even what in particular makes it become so slow and useless. Though I have a pretty good idea.![DEVELOPERS, DEVELOPERS, DEVELOPERS, etc.](http://i.imgur.com/S6ZP6.jpg)

[SauceLabs](https://saucelabs.com/) is a fantastic solution to this problem, which they solve by spawning new Virtual Machines on demand, and then destroying them when your tests have finished. Their browsers never survive long enough to get themselves into that shitty state. But, after accidentally going over my minutes by about 600% in one month, I needed a solution that didn't cost my sum net worth to handle the insane quantity of tests I throw at it daily. I decided to create my own Sauce-inspired, half-assed VM approach. 



<script src="https://gist.github.com/pettazz/4947662.js"></script>