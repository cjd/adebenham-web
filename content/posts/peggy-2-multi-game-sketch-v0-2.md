---
author: cjd
date: "2010-02-15T00:28:23+00:00"
tags:
  - arduino
  - peggy-2
title: Peggy 2 multi-game sketch v0.2
url: /blog/2010/02/15/peggy-2-multi-game-sketch-v0-2/

---
I've done a lot more work on the multi-game sketch for my Peggy2 - mostly to add functionality and fix up a few 'issues'
See the original post \[intlink id="17" type="post"\]here\[/intlink\] for more details on what is included
Download it from [here](/files/arduino/peggy2_games_0.2.zip) When compiled it uses 13808 bytes so there only a bit of room to spare.
I've added a two player version of pong (use up/down buttons to control player two - I've made a separate plug-in controller for player two to make things easier to use)
I've fixed up the 'breakout' clone so it actually can be considered a 'game' :-)
I also added a 'demo' game which just lights up all leds with a nice grayscale pattern than can be moved around via the direction buttons (press select to stop the motion)
The other main thing is that it now has sound!
With the release of arduino-0018 they added a function 'tone' to generate square waves on a digital pin. I connected a piezo speaker (from a headphone) to ADC5 and generated the tones on that pin.
There is intro music at the game select screen, music when displaying the score and various bips and beeps while playing the games.
To make the music I wrote a small perl script to convert MusicXML files to a suitable include file (will be documented in a separate post)
Adding the music and extra games meant I was hitting the space limits in the AVR so there is a bit of 'dodgyness' in the code so that it would fit.

See the original post \[intlink id="17" type="post"\]here\[/intlink\] for more details on what is included
