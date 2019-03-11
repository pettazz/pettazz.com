---
layout: post
published: true
pygments: true
title: "Doing Selenium Part III: Who Needs Hover Anyway?"
tags: [code, selenium, projects, bash, testing, automation, QA, IE, Ballmer, VMs]
comments: true
---

A dark cloud had surrounded me, blocking out the sun. Every move I made only seemed to make the darkness more dense and take the bright rays of hope farther from my reach. My situation was becoming more and more claustrophobic and dire every day. I knew I wouldn't be able to go much longer on in this way, and was determined that if this truly was the end, I wouldn't be going out without a fight. So I tried something. Something foolish and crazy; something dangerous and possibly indicative of a serious mental condition. I tried the only option I had left. 

I disabled nativeEvents in Internet Explorer. <!--more-->

It was easy, almost too easy. I only had to add one item to the -browser argument in my selenium node startup script:

{% highlight bash %}
java -jar selenium-server-standalone.jar -role node -hub http://my.seleniumhub.whatever:444/grid/register -browser "browserName=internet explorer,version=8,nativeEvents=false"
{% endhighlight %}

And then, just as the cloud was becoming so thick and dark that I could barely breathe, a golden ray of sunlight sliced through the darkness. Then another, and another, and still more. 

Tests were passing. 

Tests were passing, and they were passing in both IE 8 and 9 within reasonable timeframes. I couldn't believe it. This was the moment I had dreamed of for so long, and it was finally here. And, in the end, what had it truly cost me? Simulating hover events in IE was now a very flaky proposition at best. But I wouldn't end up like Marty McFly stuck over the pond in front of the Hill Valley Courthouse, because I would know my limitations ahead of time. 

![Marty McFly's hoverboard](http://i.imgur.com/SWlRoxW.png "Hey McFly, you bojo, those hover events don't work on IE! Unless you've got NATIVE EVENTS!")

Native Events in IE are "[OS-level events to perform mouse and keyboard operations in the browser](https://code.google.com/p/selenium/wiki/InternetExplorerDriver#Native_Events_and_Internet_Explorer)," as opposed to events simulated through Javascript. For the purists among us, disabling them is not ideal, especially considering the fact that using the same sandbox that your applications are running in to also perform your testing is not the greatest idea. 

But these are small sacrifices to make when the alternative is test cases that take longer to run than they did to develop and write. And in the end having tests that actually run, albeit with a few small caveats (I mean, really, how much of your UI legitimately _depends_ on :hover, and how hard is it to add a simple workaround in selenium?), better than having no tests at all?