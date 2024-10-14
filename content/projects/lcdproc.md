---
author: cjd
date: "2010-02-04T01:06:39+00:00"
title: LCDproc
url: /old-stuff/lcdproc/
summary: LCDproc is a small piece of software that displays real-time system information from your machine on a LCD and is available at [http://lcdproc.org/](http://lcdproc.org/)
thumbnail: /images/lcdproc.png

---
![LCDproc Logo](/files/lcdproc/lcdproc.png)

LCDproc is a small piece of software that displays real-time system information from your machine on a LCD and is available at [http://lcdproc.org/](http://lcdproc.org/)
The server is capable of running on pretty much any posix (or-similar) system while the lcdproc client can get info for Linux, Solaris, xBSD and a few other OS's

I have written two clients for the lcdproc server, one which displays/controls [MP3Box](../mp3sb/) while the other displays your online buddies from [Gaim](http://gaim.sourceforge.net/)

## Client for MP3Box

 **Latest Version: 1.0** _released 8 Jul 2002_
This perl script sits between mp3box and lcdproc and displays the current song name, artist, status and play time.
It can also take input from a FIFO (example client [mp3lcd\_client.pl](/files/lcdproc/mp3lcd_client.pl.tgz) or just send characters to the fifo)
Input allows you to control mp3box, load songs, play/pause/skip/back, change playmode and set the volume
When loading songs you can enter the artist as numbers (like entering a word on your phone) and it searches for matching artists as you type so most of the time you don't even need to type the full name
It runs on 2,3 or 4 line screens

Download [mp3lcd\_serv.pl](/files/lcdproc/mp3lcd_serv.pl.tgz) to use, setup options are at the top of the file

## Client for GAIM

This perl script acts as a plugin to Gaim does nothing more than display a list of your buddies who are online.
When the list changes the screen is brought to the front of lcdproc

Download [gaim-lcd.pl](/files/lcdproc/gaim-lcd.tgz) to use, install by putting it somewhere nice ( ~/.gaim is good ) then selecting the perl script in Gaim as a perl plugin
