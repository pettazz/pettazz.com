---
layout: post
published: true
title: "Flying Jekyll"
tagline: "Call me Van de Graaff the way I'm generating static sites over here"
tags: [blag, jekyll, fly.io, github, hosting, platforms, flying-jekyll, lua, nginx, docker]
comments: true
category: projects
permalink: /flying-jekyll/
image: flying-jekyll.jpg
---

[I mentioned a little while ago](/goodbye-gh-pages/) that I had bailed on GitHub Pages for hosting this site and switched to my own custom setup hosted on [Fly.io](https://fly.io) instead, more or less templating the process into a helpful little skeleton that I cleverly named Flying Jekyll. So I figured it was about time I explained that in more detail.

> [Flying Jekyll](https://github.com/pettazz/flying-jekyll) on GitHub, the aforementioned skeleton project, ready for your cloning needs.

I make a lot of Jekyll sites for some reason. I'm really into the idea of pregenerating everything statically so it's as fast and snappy as humanly possible, and I find the majority of stuff I have been presenting[^1] to the internet these days doesn't require any backend component. I'm talking about this site, [Fart Depot dot Biz](https://fartdepot.biz), [Warranty Now Void](https://warrantynowvoid.com), and other places that exist just to serve up inherently static things like text and images. I also have friends[^2] who occasionally want to post their own blogs or the like but don't share my perverse enthusiasm for things like building an entire site from scratch. I know, I know, it's hard to imagine not getting a thrill from setting up a valid SSL certificate but there are people like that living among us. 

It's for all these reasons that I wanted an easily reproducible way to bootstrap a live Jekyll site.

![Picard from the TNG episode "The Measure of A Man" pointing and saying "well there it sits!"](/images/there-it-sits.jpg)

### Fly.io

Let's start with the hosting. [Fly.io](https://fly.io) is a great private cloud service that's really geared towards developers and making their lives easier. It's also super cheap if you don't have a ton of traffic. It's all Docker based, so you can simply provide an image and deploy it to run on a scalable set of machines in the cloud, or use their [Remote Builders](https://fly.io/docs/reference/builders/) to also use your Dockerfile to produce the image on a cloud server rather than your local machine. Since the ultimate goal here is to replace the GitHub Pages experience, turning git commits into deployed websites with no concern for building or transporting artifacts, this is exactly what we want to do.

I won't walk through the entire setup, since it's fairly well-documented (both by [Fly themselves](https://fly.io/docs/launch/create/) and in the flying-jekyll Readme), but we essentially create the deployment and generate a `fly.toml` file that contains its settings and we're ready to go.

### Building 

Jekyll has few dependencies, but if you use a lot of plugins, the gems can get a little complicated to manage directly. I (and basically everyone else) like to use bundler for this, which also helps us to create reproducible builds from a checked in Gemfile. So we can start with a Dockerfile that looks like this:

```Dockerfile
FROM ruby:3.1.3

WORKDIR /build-zone

COPY . .
    
RUN gem install jekyll bundler
RUN bundle install 
RUN bundle exec jekyll build
````

All we're doing here is copying the source to a work directory, installing the Gem dependencies with bundler, and running the Jekyll build. Very straightforward. 

### Running

The ultimate product of a Jekyll build is a bunch of static HTML and assets compiled in the `_site/` directory, which simply needs to be served statically. For reasons that will become clear later, I decided to go with [nginx](https://nginx.org/), a famously extremely fast and easy to configure HTTP server. It uses a single file `nginx.conf` to define the server and all the routes that it will handle. Here's a very truncated version:

```conf
http {
    server {
        listen 8080;
        listen [::]:8080;
        port_in_redirect off;

        root /app;
        gzip_static on;
    }
}
```

We set the port to listen on and the root directory (and enable gzip for static files, which is everything). All we have to do to run this in a Docker container is move our site files into that root directory and expose the port (we are using 8080 just to be obviously explicit, you can use anything as long as it's the same in all the config files).

```Dockerfile
FROM nginx:alpine

WORKDIR /app

COPY _site/ ./
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080
```

The `nginx:alpine` image is a very lightweight Linux container running nginx with your config, so far so good!

### Building *and* Running

Now we want to do both of these things at once, which we can do as a [multi-stage build](https://fly.io/docs/python/the-basics/multi-stage-builds/) in the same Dockerfile. We'll need to define each of the images as `builder` and `runner`, and make sure we copy our files from the `builder` into the `runner` by adding the `--from` param to the `COPY` command.

```Dockerfile
# build it
FROM ruby:3.1.3 AS builder

WORKDIR /build-zone

COPY . .
    
RUN gem install jekyll bundler
RUN bundle install 
RUN bundle exec jekyll build

# run it
FROM nginx:alpine AS runner

WORKDIR /app

COPY --from=builder /build-zone/_site/ ./
COPY --from=builder /build-zone/nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080
```

Now to tell Fly what image to actually *use* when deploying and what port it runs on we just add a few lines to our `fly.toml`:

```toml
[build]
  build-target = "runner"

[http_service]
  internal_port = 8080
````

From here using the `flyctl deploy` command you should already have a perfectly functioning build, deployment, and live site! But that's not quite our goal yet, we want this done automatically whenever commits are pushed. Luckily, Fly also provides a [prebuilt GitHub Action](https://fly.io/docs/launch/continuous-deployment-with-github-actions/) to handle everything automatically.

## That was too easy, let's complicate it

This is where the original flying-jekyll skeleton ended in a nice, neat package. But obviously that won't do, we need to make it messier somehow. Worse, even. Let's jam some more stuff in there.

### Secrets

Let's say we are using [some sort of Jekyll plugin](/jekyll-darkvisitors) that requires an API token in a config file that we can't check into the codebase. GitHub Actions provides a Secrets mechanism to inject these into a build as environment variables, but your plugin needs that in `_config.yml`, *inside the Docker container* at build time. Let's interpolate[^3] them!

First we need to get the secrets that GitHub Actions provides into our Docker `builder`. [Fly lets us pipe secrets](https://fly.io/docs/apps/build-secrets/) into an image via Docker Secrets with a `--build-secret` param to the `flyctl deploy` command. We could edit our Actions workflow to explicitly define each individual secret and pass it through, but that's fragile and will require keeping the definitions in sync whenever a secret is added or removed. We want this skeleton to be generic and resilient!

Taking some inspiration from the Fly documentation, the easiest way to do this in bulk with any arbitrary number of secret variables is going to be dumping them as declarations into a single base64 encoded blob that gets treated as the secret itself, which we can then unpack and read inside the container for whatever use we need. 

> Yeah, I realize calling this series of acrobatics "easiest" is very silly but believe me, of the available options this is the least difficult.
{: .notice .author-note}

Let's look at each of the pieces before we put it all together. 

#### Get 'em 

GitHub Actions [provides a few functions](https://docs.github.com/en/enterprise-cloud@latest/actions/writing-workflows/choosing-what-your-workflow-does/evaluate-expressions-in-workflows-and-actions) we can make use of here, specifically `toJson()` to dump all the secrets into an easy to parse JSON object like:

```json
{
  "SECRET_ONE": "mysecretvalue1",
  "SECOND_SECRET": "eyes off!"
}
```

#### Format 'em

Now that they're in a JSON format we can use the ever-versatile `jq` tool to loop through the JSON and build a string that is essentially a little bash script for defining each of them as environment variables, i.e. `export VAR=value`:

```bash
jq -r "to_entries[] | \"export \(.key)='\(.value)'\n\"";
```

The output of passing our secrets JSON into this should be something like this:

```bash
export SECRET_ONE='mysecretvalue1'
export SECOND_SECRET='eyes off!'
```

#### Pipe 'em

What do you do when you have an arbitrarily long string that you want to stuff into a single value? You base64 encode it, of course! Say we have stored the output from `jq` above in a variable named `ENV_SECRETS`, our next step is to stuff them into the `flyctl` command as a single build secret:

```bash
ALL_SECRETS=$(echo "$ENV_SECRETS" | base64 --wrap=0)
flyctl deploy --remote-only --build-secret "ALL_SECRETS=$ALL_SECRETS"
```

#### Unpack 'em

Now inside the Docker container we have an environment variable called `ALL_SECRETS` which is a base64 encoded list of variable definitions. Let's unpack them and make them a part of the local environment using the Docker Secrets mount. Remember that our secret value is actually a series of `export` commands setting the secrets as variables, so we simply need to `eval` that to make it happen:

```Dockerfile
RUN --mount=type=secret,id=ALL_SECRETS \
    eval "$(base64 -d /run/secrets/ALL_SECRETS)"
```

#### Fit 'em in there

At this point if all we need is environment variables, we're set. But remember we need our secret token interpolated into the `_config.yml` file, so we can make use of the `envsubst` tool (part of the `gettext` Debian package): 

```Dockerfile
RUN apt-get update && apt-get install gettext -y

RUN envsubst < _config.yml > tmp.yml && mv tmp.yml _config.yml
```

We can refine this a little bit to make sure the `envsubst` tool *only* interpolates variable names that exist by giving it a list from the `env`:

```Dockerfile
RUN apt-get update && apt-get install gettext -y

RUN export VARS="$(env | cut -d= -f1 | sed -e 's/^/$/')" && \
    envsubst "$VARS" < _config.yml > tmp.yml && mv tmp.yml _config.yml
```

This way if a secret isn't set, or if some other similarly formatted string (i.e. nginx's `$http_upgrade`) is used in a config file, we won't touch it. 

#### Put it all together

Our GitHub Actions workflow definition `fly.yaml`:

```yaml
name: Fly Deploy
on:
  push:
    branches:
      - main
env:
  FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
  SECRETS_CONTEXT: ${{ toJson(secrets) }}
jobs:
  deploy:
      name: Deploy app
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - uses: superfly/flyctl-actions/setup-flyctl@master
        - run: |
            format_env() { jq -r "to_entries[] | \"export \(.key)='\(.value)'\n\""; }
            [[ "$SECRETS_CONTEXT" != "null" ]] && ENV_SECRETS="$(echo $SECRETS_CONTEXT | format_env)"
            ALL_SECRETS=$(echo "$ENV_SECRETS" | base64 --wrap=0)
            flyctl deploy --remote-only --build-secret "ALL_SECRETS=$ALL_SECRETS"
```

The `builder` portion of our Dockerfile:

```Dockerfile
# build it
FROM ruby:3.1.3 AS builder

RUN apt-get update && apt-get install gettext -y

WORKDIR /build-zone

COPY . .

# interpolate secrets
RUN --mount=type=secret,id=ALL_SECRETS \
    eval "$(base64 -d /run/secrets/ALL_SECRETS)" && \
    export VARS="$(env | cut -d= -f1 | sed -e 's/^/$/')" && \
    envsubst "$VARS" < _config.yml > tmp.yml && mv tmp.yml _config.yml && \
    envsubst "$VARS" < nginx.conf > tmp.conf && mv tmp.conf nginx.conf
```

> Keep reading to see why I've included `nginx.conf` here, but you could reuse this for any list of files as needed.
{: .notice .author-note}

All to make this `_config.yml`:

```yml
my_plugin_api_key: ${COOL_API_TOKEN}
```

Look like this during the build:

```yml
my_plugin_api_key: 123-dead-beef
```

See, easy! 

What's that you say, not messy enough? More complication? Well, who am I to deny my audience what they want.

### Dark Visitors integration

I've posted about Dark Visitors before, and making full use of it has become sort of an obsession lately. I don't want any AI scrapers consuming my stuff, and it's a great tool to help prevent that. Unfortunately for me, it's geared mostly towards WordPress users, since `robots.txt` files are largely ignored and bots are simply not going to execute Javascript I stick into the page, it requires some kind of server-side intervention. The two things I want to do here are:

1. Send visit event info to the [Dark Vistors Agent Analytics API](https://darkvisitors.com/docs/analytics) to help them keep track of all the bots out there
2. Block AI scrapers with an HTTP 403

Nginx has some extensibility built in, but by far the easiest way to write some middleware I found was using [OpenResty](https://openresty.org) which essentially bolts a Lua runtime onto it with [lots and lots of hooks](https://github.com/openresty/lua-nginx-module?tab=readme-ov-file#directives) exposed directly in `nginx.conf` as directives. I've never written Lua code before but hey aren't projects all about learning new things?

> While I've never written it myself I have of course been exposed to a lot of Lua code thanks to wasting about a quarter of my high school life in [Garry's Mod installing SWEPS](https://wiki.facepunch.com/gmod/Structures/SWEP) that made my computer smell like burning hair. I still miss it to this day.
{: .notice .author-note}

To start using OpenResty we can just swap the base image in our Dockerfile, and change our target for copying `nginx.conf` accordingly:

```Dockerfile
FROM openresty/openresty:alpine AS runner
...
COPY --from=builder /build-zone/nginx.conf /etc/nginx/conf.d/site.conf
```

The two goals I listed above can both be handled for all requests in an `access_by_lua_block` directive[^4] which allows us to execute some Lua code when handling a request and only affect the response if we choose to. We'll also need to set up a proxy to make requests to the Dark Visitors API to send our event and retrieve a list of known bots. Luckily for us we already have a way to interpolate our API token, and we can use a check against `ngx.req.is_internal()` to prevent anything but subrequests from our Lua code itself from using these proxy endpoints. 

```conf
    location /darkvisitors-proxy {
        access_by_lua_block {
            if not ngx.req.is_internal() then
                ngx.log(ngx.ERR, 'internal only!')
                ngx.exit(ngx.HTTP_FORBIDDEN)
            end
        }

        proxy_pass_request_headers off;
        proxy_set_header Authorization "Bearer ${DARK_VISITORS_TOKEN}";
        proxy_set_header Content-Type "application/json";
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';

        location = /darkvisitors-proxy/visits {
            proxy_pass https://api.darkvisitors.com/visits;
        }

        location = /darkvisitors-proxy/robots {
            proxy_pass https://api.darkvisitors.com/robots-txts;
        }
    }
```

The [full `nginx.conf` with Dark Visitors integration](https://github.com/pettazz/flying-jekyll/blob/main/nginx-darkvisitors.conf) is included in flying-jekyll if you choose to use it, so I won't go over it in detail here. The gist is that we send off info about the request (mainly its user agent) to Dark Visitors for tracking, then we fetch the current `robots.txt`, caching it for 24 hours, and parse it into a list of user agents to validate our current visitor against. If they are on the naughty list, they get a 403, otherwise the request continues like nothing happened.

> Lua is interesting, with little quirks like using `:` instead of `.` to call a function on an object with itself as the first argument, like `botlist:find("useragent")` as opposed to the static `string.find(botlist, "useragent")`. Though I have no idea who decided `~=` was preferable to `!=`, a decision that kind of makes me nervous about the whole language.
{: .notice .author-note}

## Wrapped up

At this point we've completed our objective and a few side missions along the way, so I think it's safe to end this extremely long post here. I'm sure in the future I'll find more things to stuff into this skeleton, but for now it's solid and infinitely reusable, happy flying!

[^1]: Much in the same way that Alex is "presented" with all that "content" in A Clockwork Orange
[^2]: Citation needed
[^3]: Basically, replacing variable names in a file with their real values at runtime
[^4]: I kept it in the `nginx.conf` as a block rather than the same `access_by_lua_file` to keep the number of files we have to pass around and then exclude from our site build to a minimum.
