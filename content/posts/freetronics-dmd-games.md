---
author: cjd
date: "2012-02-04T05:09:07+00:00"
tags:
  - arduino
  - dmd
title: Freetronics DMD - Games
url: /blog/2012/02/04/freetronics-dmd-games/

---
I had a little while free and so ported a bunch of games I wrote for the Peggy2 to work with a pair of DMD's
In doing so the games now run at 32x32 and are controlled by a Wii nunchuck.
The games are snake, pong, breakout and race.
The Arduino code is available at [DMD\_games.zip](/files/arduino/DMD_games.zip)
The two screens are daisy-chained but as the cable connecting them is quite short the top one is upside-down.
To get this working the modified \[intlink id="55" type="post"\]DMD library\[/intlink\] is setup to handle rows of displays where odd-numbered rows are upside down.
See this diagram for how it is laid out (for 2x2 case)

![DMD Layout](/files/arduino/multi-DMD.svg)

Playing is fairly straight-forward.   Only thing to remember is that the 'z-button' on the nunchuck is used to select and the 'c-button' is used to exit back to the menu

Have a look at the video below to see them in action.
\[youtube\_sc url="5WW9ZmvjSA4"\]
