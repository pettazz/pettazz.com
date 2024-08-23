---
layout: post
published: true
title: "jekyll-darkvisitors"
tagline: "Keep your robot hands off my stuff"
tags: [blag, api, jekyll, dark visitors, rubygems]
comments: true
category: projects
permalink: /jekyll-darkvisitors/
image: huhbot.jpg
imageCredit:
  link: https://unsplash.com/@rocknrollmonkey?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash
  display: Originals by Rock'n Roll Monkey
---

I don't think it would be a huge surprise for anyone glancing at this site that I'm not a fan of the "AI" (even the name is bullshit) industry we currently live with. Every model needs [increasingly, impossibly large amounts of data](https://www.sciencealert.com/the-world-is-running-out-of-data-to-feed-ai-experts-warn) to train on, and the "synthetic data" idea of feeding AI-generated slop into the slop machine [seems to only produce sloppier slop](https://futurism.com/ai-trained-ai-generated-data-interview). The companies looking to prop up this hype cycle are desperately scraping every word and pixel from every site they can find with their crawlers, whether the people actually creating it like it or not, and making it hard to block or even track that scraping by [constantly cycling different bots in and out of use](https://www.404media.co/websites-are-blocking-the-wrong-ai-scrapers-because-ai-companies-keep-making-new-ones/). 

That's what led me to [Dark Visitors](https://darkvisitors.com), a service that provides live monitoring for automated User Agents and sources that information to maintain a list of known AI scrapers and crawlers. They offer a WordPress plugin to handle all of this, including actually blocking bots from accessing your content, and several APIs to fetch this data and use it in your own way, including a robots.txt generator. This is part one of how I've implemented their excellent service [here](/robots.txt) and on the many Jekyll static sites I am compulsively building.

But first a little context.

## robots dot text

The robots.txt file has been around for decades, and is more of a code of conduct than anything else. Site owners can specify some useful information to bots about the structure and layout of the site, making crawling it much easier and accurate for them, and in exchange we get to ask for certain parts of the site to be excluded from the bot's exploration and, ultimately, index. This is an example of a robots.txt file:

````
User-agent: *
Sitemap: https://pettazz.com/sitemap.xml

User-agent: Googlebot
Disallow: /private/
````

It's a series of directives organized by the User Agents to which the rules should apply. In this case, we tell anyone asking where the sitemap is, and we ask Googlebot to stay out of anything in the `/private/` path. It can do more complicated stuff, but this is basically all it's used for today. When this first became a nice handshake agreement sort of non-standard standard in the 90s, the main focus was on the web crawlers feeding the growing search engine indices like AltaVista and AskJeeves.

> Funny enough, this thing was just widely used and accepted for decades and never had a formal standard proposal until Google submitted one in 2019: <https://datatracker.ietf.org/doc/html/rfc9309>
{: .notice .author-note}

Back then it was in everyones' best interest to play nice. It wasn't a guarantee that your site's `/private/tax_returns.pdf` would *never* end up on Google, but it was largely respected. The AI bots have no such incentive to respect or even care about these nice requests to avoid certain paths; in fact their goals specifically push them to ignore any "no bots allowed" signs posted on the door and shove every scrap human-generated content they can find into their gaping maws. This is a problem that robots.txt cannot solve, but we'll deal with that in Part 2 later. 

> **//TODO**: link it! Also, write it!
{: .notice .author-note}

On the off chance that a bot does still respect the sanctity of robots.txt, we'll need an up-to-date list of User Agents to politely ask not to steal our stuff, which is exactly what Dark Visitors provides.

## Plug it into Jekyll

Static sites don't have the luxury of updating in real time (unless we hook it up via some frontend logic, but that exposes our process and API keys, and scrapers can simply choose not to even execute JavaScript in the pages they fetch), so we need to put together our robots.txt at build time, something we can do in Jekyll very easily with a plugin:

> [The jekyll-darkvisitors Plugin](https://github.com/pettazz/jekyll-darkvisitors), available [on RubyGems.org](https://rubygems.org/gems/jekyll-darkvisitors)

Using [the Dark Visitors robots.txt API](https://darkvisitors.com/docs/robots-txt) we simply have to make a request with our access token and a few details, and they will provide us with a complete and up to date robots.txt. The plugin provides a Jekyll Generator that handles all of this.

### Params

Via `_config.yml` we can get the required information. The only required key is `access_token`, while the others all have reasonable defaults, all of which are listed here:

```yaml
darkvisitors:
  access_token: 1234-dead-beef
  append_existing: false
  agent_types:
    - AI Data Scraper
    - Undocumented AI Agent
  disallow: /
```

#### `access_token` 

The token is of course, your secret access token to make requests to the API, as provided by the project page. This is a secret token and shouldn't be exposed by committing it to a public repo, so you'll need to use some sort of secrets management to keep it out of view. 

> **//TODO**: another post about the flying-jekyll skeleton project that implements this coming soon.
{: .notice .author-note}

#### `append_existing`

A boolean that tells the plugin how to handle an existing robots.txt file in your site. If there is no robots.txt either in the static files or being generated, this won't affect anything. But if there is one found and this is set to `false`, the plugin will show you a nice yellow warning and not touch it. If set to `true`, it will instead copy the content of the existing robots.txt, fetch our Dark Visitors content, merge them together, and use that to replace a new robots.txt into the generated site. This is done a little bit hackily, by actually deleting any matched 'robots.txt' files in Jekyll's generated `pages` or `static_files` and then re-adding our own, but it seems unlikely that there would be anything else operating on this file, so setting this plugin to a very low priority to run late in the process is probably fine for any case.

#### `agent_types`

This is a list of agent types to request from Dark Visitors. You might want to try to block only scrapers that will feed your content into the machine while allowing searches and assistants to still have access, or any other combination.
 
#### `disallow`

This path will be used to generate the `Disallow` directive for each agent, so if you want to block their access to the whole site, leave it as-is with a simple `/`, or get more speciifc as needed.

### Jekyll Cache

In Jekyll 4, a caching API was added to help speed up builds by caching function outputs that haven't changed across builds. This means while running a `jekyll serve` demo server to preview your posts as you work on them, for example, you won't have to wait for every tag relation to be regenerated if you only changed the body of a page. This is helpfully also exposed to plugins with [a simple API](https://jekyllrb.com/tutorials/cache-api/), and jekyll-darkvisitors takes full advantage of it. The cache key itself is the static string `'robotsdottxt'` because we actually only want to rely on the built in busting behavior, which is whenever `_config.yml` is changed (or if your build environment has no existing cache, of course, because it's run on some ephemeral cloud instance which is how the majority of production Jekyll sites are built). This means that you won't be hammering the Dark Visitors API every time you reflexively press Ctrl+s while editing a post.

## End Result

Check it out yourself, this site uses the plugin to append the live list of all Agent types onto its robots.txt, so we go from [the static source file](https://github.com/pettazz/pettazz.com/blob/main/robots.txt):

````
User-agent: *
Sitemap: https://pettazz.com/sitemap.xml
Disallow: /p/

# AI crawlers go to hell
````

to [a fully generated list](https://pettazz.com/robots.txt):

````
User-agent: *
Sitemap: https://pettazz.com/sitemap.xml
Disallow: /p/

# AI crawlers go to hell

# Undocumented AI Agent
# https://darkvisitors.com/agents/anthropic-ai

User-agent: anthropic-ai
Disallow: /

# AI Data Scraper
# https://darkvisitors.com/agents/applebot-extended

User-agent: Applebot-Extended
Disallow: /

# AI Data Scraper
# https://darkvisitors.com/agents/bytespider

User-agent: Bytespider
Disallow: /

...truncated example, click the live link if you want to see the whole thing!
````

As mentioned above, this only gets us to the stage of nicely asking these bots to respect our privacy, which in many cases they rudely will not. We also can't help with Dark Visitor's noble work of monitoring the agents in use because we don't send them back any data about bots accessing our site. We'll address these with a more aggressive approach soon. 

> Sneak preview: we're going to use nginx to serve the static site and explicitly throw HTTP errors to the bots. Let them eat 403s.
{: .notice .author-note}