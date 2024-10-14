---
author: cjd
date: "2010-01-30T03:32:30+00:00"
tags:
  - arduino
  - peggy-2
title: Peggy 2 Snake
url: /blog/2010/01/30/peggy-2-snake/

---
For Christmas my wife gave me a [peggy 2](http://evilmadscience.com/tinykitlist/75) and I finally got around to building it.

\[caption id="attachment\_14" align="aligncenter" width="199" caption="Peggy 2 running Snake"\] [![Peggy 2 running Snake](/wp-content/uploads/2010/01/Peggy2_snake-199x300.jpg)](/wp-content/uploads/2010/01/Peggy2_snake.jpg)\[/caption\]

It has 24x25 White LEDs with a row of 25 Red LEDs across the bottom.

By having that bottom row a different colour I can use that section for displaying score or other information

The first application I wrote for it the good old game of 'Snake'.Â  After writing a quick version of the game I realised it needed a bit more 'flair' and so added the ability to display an intro screen and score screen.Â  To make this easier I wrote a bunch of utility functions to display characters that are stored in an array. I'll describe how this works in a separate post as \[intlink id="15" type="post"\]Peggy 2 Character display\[/intlink\].

The game has multiple levels (where walls are put up in different spots and the speed is increased).Â  All up the program takes up 5258 bytes so fits on an atmega168 with room to spare.

Source code is available as [peggy2\_snake.zip](/files/arduino/peggy2_snake.zip)

If you don't have all the leds soldered on you can change gameMinX, gameMaxX, gameMinY, gameMaxY and score\* to set the area used to play/display score
