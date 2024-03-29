---
layout: post
title: TV Robot Is Best Robot
tags: [TVRobot, code, python, projects, PLEX]
comments: true
---

Once upon a time, I was the proud owner of a [PLEX](http://plexapp.com) Server, [Transmission](http://www.transmissionbt.com/) Server, and a fondness for a whole bunch of TV shows that were on at different (and sometimes the same) times and days out of any given week.

I also had a fast internet connection, but no cable TV. It was an experiment in saving money by not spending it on roughly 9001 channels that my roommate and I would never watch, just to get the total of 5 hours per week of TV we actually wanted to see. And it wasn't going well. I wouldn't say that memory skills are my strong points, so remembering to actually go look for a show on The Pirate Bay after its air time, and maybe even checking back again later if there isn't a useful candidate yet, was not going particularly well, to say nothing of the trials and suffering encountered in trying to move the completed files to the PLEX server's watched folders (also on a different physical machine) so it would pick them up for streaming. I knew there was a Transmission RPC python module, and had caught the general idea of python Fabric. There was definitely a way to make this easier. 

Thus, TVRobot was born into this world. He is a glorious python-based conglomeration of Transmission RPC calls, unzipping and unraring methods, fabric calls to transfer files, MySQL tables to store download data and show schedules, and a seriously hacked-together Google Voice library to accept schedule additions via SMS, and message the owners of downloads (both scheduled and manually added) when finished and available in PLEX. He is very probably my favorite robot at the moment (apologies to Mr. Butlertron, my Roomba, but it's the hard truth).

You can see/fork him in his [GitHub home](https://github.com/pettazz/TvRobot), though documentation is severely lacking for now. Manually adding torrents is only doable via command line options, and adding schedules only via SMS. The Google Voice library has a habit of not playing nice with new accounts, and there is no way to manage users or any data within TVRobot without directly handling the MySQL tables. These are all things I plan on fixing (a shiny Django + Bootstrap web UI could go a long way) eventually, and maybe even packaging him neatly on something like a Raspberry Pi or Panda Board. It's hard to say what exactly the future of my Robot friend is, but I know for a fact it will be goddammned fantastic.

And obviously, he should only be used to acquire things that it's legal for you to download from TPB. Otherwise the cyber police will come kick in your door and say mean things to you.