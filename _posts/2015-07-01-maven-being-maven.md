---
layout: post
published: true
title: Maven Being Maven
tagline: "Maven? Adding totally unnecessary complexity to what should otherwise be a very simple task? No way!"
tags: [blag, maven, java, Jenkins, build, mvn]
comments: true
image:
  feature: maven.png
---

In my real job, we use Jenkins to build our junk. Actually, two instances of Jenkins (don't ask). Actually, two instances of Jenkins that write artifacts to a Maven repository and also to a special location in Perforce (seriously, don't ask). We live in a strange world somewhere between a number of build tools and processes standardized within the company and usually end up using some combination of them that we duct tape together with some python code, shell scripts, and happy thoughts. <!--more-->

So we often find ourselves in truly disgusting situations, like having to do the actual build on one Jenkins server which triggers a different job on a different Jenkins server that actually handles the artifacts from the other build, putting them somewhere that they can actually be used. How do we get an artifact? We could just build one with the source that we conveniently have available to us, that is if we want to spend half a day building the same thing over and over. We already built one and uploaded it to the repo from a different Jenkins server, so let's just grab that one. Enter [dependency:get](https://maven.apache.org/plugins/maven-dependency-plugin/get-mojo.html). Sounds great, we can even parameterize the mvn command to get a jar of a specific version.

{% highlight bash %}
mvn org.apache.maven.plugins:maven-dependency-plugin:2.8:get -Dartifact=com.pettazz:some-stupid-robot-thing:$MAVEN_VERSION -Dpackaging=jar -Ddest=./my-dumb-project.jar
{% endhighlight %}

It's also important to note that the only method of communication we have between Jenkins and Other Jenkins is a simple HTTP POST from the first to the second to /buildWithParams, and the only useful variable we can send over in that request is a very generic ``$VERSION``, which does not necessarily match up with the version in our pom file. For example, if we're building version 1.7 of our app, our pom usually looks like this:

{% highlight xml %}
<version>1.7-SNAPSHOT</version>
{% endhighlight %}

But due to the fact that we have multiple versions building at any given time and we can only interact with _this_ Jenkins instance via a json configuration file with very specific properties, Jenkins' ``$VERSION`` is just ``1.7``, while the actual pom version is ``1.7-SNAPSHOT`` or, within the repo as ``1.7-20150624.171502-17.jar``. Suddenly, ``$MAVEN_VERSION`` is a lot more complicated.

And so we come to the entire reason for this post. How the hell do you tell mvn to just use the version that's _right there in the goddamned pom file_? After several hours of googling, apparently some options include: 

- installing Groovy on the system and the Groovy Jenkins plugin, then writing a Groovy script to load and parse the pom and the Jenkins API to set the variables
- writing a separate Jenkins job that only contains a python script to parse the xml file and trigger the actual job, passing the parsed values as build parameters 
- blood magicks

Links redacted to protect the innocent on StackOverflow, but I swear these are all real things people actually proposed as solutions.
{: .notice}

Deeply unwilling to try any of these options (I mean, seriously, _Groovy_? Gross.), we developed a somewhat less sophisticated method:

{% highlight bash %}
MAVEN_VERSION=`head pom.xml | grep \<version | cut -d\> -f 2 | cut -d\< -f 1`
{% endhighlight %}

> Fuck it, we'll do it in bash

Hopefully this post will show up in some Google results above the other suggestions and save some poor lost soul from spilling any more blood or Groovy into their precious server.
