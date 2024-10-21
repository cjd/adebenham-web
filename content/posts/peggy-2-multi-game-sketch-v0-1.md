---
author: cjd
date: "2010-02-03T22:26:30+00:00"
tags:
  - arduino
  - peggy-2
title: Peggy 2 multi-game sketch v0.1
url: /blog/2010/02/04/peggy-2-multi-game-sketch-v0-1/

---
I had such fun writing the simple 'snake' game for my peggy 2 that I wrote a bunch of other games for it as well.

At the moment there is Snake, Breakout, Pong and Race.

You can download the sketch as [peggy2\_games\_0.1.zip](/files/arduino/peggy2_games_0.1.zip)

When compiled it takes up 11432 bytes (it includes the 'Tone' library as I have started adding sound to the sketch - connect speaker to ADC5 to hear it)

## Starting peggy2\_game

 [![Game menu](/posts/media/peggy/game_menu.jpg)](/posts/media/peggy/game_menu.jpg)

When you turn on the peggy2 a menu is presented displaying the available games - you can select from them using the up/down buttons and select with the 'select' or 'any' button on the left of the peggy2.   Only three game names fit on the screen at once so the entire display scrolls up/down when changing game (and highlights the current selection)   To change games press the reset button.

## Playing the games

### Snake

[![Snake](/posts/media/peggy/snake.jpg)](/posts/media/peggy/snake.jpg)[![Level select](/posts/media/peggy/level_select.jpg)](/posts/media/peggy/level_select.jpg)

When the game first starts you can choose which level to start at.   There are four different boards available - these boards are re-used in a loop just at a higher speed for later levels.

Eat the 'apples' to get points, don't hit yourself or walls

Arrow buttons control movement of the snake.

[![Score screen](/posts/media/peggy/score.jpg)](/posts/media/peggy/score.jpg)

### Pong

 [![Pong game](/posts/media/peggy/pong.jpg)](/posts/media/peggy/pong.jpg)

Hit the ball back, get a point if the AI misses, AI gets the point if you miss

Left/right buttons control movement of the bottom paddle (one player only for the moment)

### Break

 [![Breakout game](/posts/media/peggy/break.jpg)](/posts/media/peggy/break.jpg)

Not much here yet, just displays a bouncing ball + blocks to hit

Left/right buttons control movement of the paddle

### Race

 [![Race game](/posts/media/peggy/race.jpg)](/posts/media/peggy/race.jpg)

Avoid the walls.   One point every 25 blocks driven past, walls get narrower every 25 points

Left/right buttons control movement of the car.

peggy2\_games.zip
