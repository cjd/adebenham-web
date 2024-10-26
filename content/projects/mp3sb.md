---
author: cjd
date: "2010-02-04T01:10:24+00:00"
title: MP3SB
url: /old-stuff/mp3sb/
summary: MP3 Server Box is a perl script that acts as a network interface to the rxaudio or a patched version of mpg123 player.
thumbnail: /images/mp3sb.png

---
# MP3Box Stuff

MP3 Server Box is a perl script that acts as a network interface to the rxaudio or a patched version of mpg123 player. You can control the player via simple network socket commands from anywhere on the network. It also features support for a MySQL table containing song information such as title, artist name, album name, etc.  

Of course you can use the same program on your workstation without extra hardware and use it like a ~normal mp3 player  

It can be found at [www.mp3sb.org](http://www.mp3sb.org/)  
_mp3sb.org is down at the moment use the mirror at [www.igalaxie.com/ltt/mp3/](http://www.igalaxie.com/ltt/mp3/)_

Currently to official mp3sb uses mpg123 for it's playing, but since I want to be able to run it on a set-top box and provide full-screen visualizations I have made a drop-in replacement for mpg123 that uses xmms as its engine.  

The only thing that 'needs' to be changed in the mp3sb\_serv script is the line where $player is set. It needs to be set to _"xmms123"_ instead of _"mpg123 .\*"_

Xmms123 is provided [Here](/files/mp3sb/xmms123.txt) for viewing or in the following tar.gz  

My tidied version of mp3sb\_serv is provided [Here](/files/mp3sb/mp3sb_serv_xmms.pl.txt) for viewing or also in the tar.gz below  
[mp3sb\_serv\_xmms.tar.gz](/files/mp3sb/mp3sb_serv_xmms.tar.gz) is both files in a tar.gz
