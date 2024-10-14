---
author: cjd
tags:
  - arduino
  - dmd
date: "2012-04-26T04:34:31+00:00"
title: Freetronics DMD - Screen transitions
url: /blog/2012/04/26/dmd-screen-transitions/

---
I was driving past one of those led advertising signs sitting on the side of the road the other day and thought to myself 'I can do that'
So I've hooked up 6 of the freetronics DMD modules (in a 2x3 layout) and got down to coding up a way to do it.
In the end I got it working by adding support for multiple buffers into my DMD library - [github.com/cjd/DMD](https://github.com/cjd/DMD)
Since I have the ability to have multiple buffers I can now transition between buffers presentation-style.
There are 8 transitions - wipe left/right/up/down, box in/out and cross in/out
The following video demonstrates some of the transitions
It is my sons first birthday in a few days so I thought it nice to create a moving sign for his party :)
\[youtube\_sc url="s4Qjski-WMY"\]

For the hardware I mounted the displays on a wooden frame (hold on by hot-glue) and then routed power down each side and signal was daisy-chained from bottom-right (bottom-left in photo) to each display.
[![](/wp-content/uploads/2012/04/DMD_Display_layout-1024x768.jpg)](/wp-content/uploads/2012/04/DMD_Display_layout.jpg)

Source code below:

```
/*---------------------------------------------------------------
Â Includes
Â ----------------------------------------------------------------*/
#include <SPI.h>Â Â Â Â Â Â Â  //SPI.h must be included as DMD is written by SPI (the IDE complains otherwise)
#include <DMD.h>Â Â Â Â Â Â Â  //
#include <TimerOne.h>Â Â  //
#include "Arial_black_16.h"
//Fire up the DMD library as dmd
DMD dmd(2,3,1);

long mDelay=30;
long timer=-1;
long oldtimer=-1;
int centreX=32;
int centreY=24;
int trans=0;
int i=0;

/*--------------------------------------------------------------------------------------
Â Interrupt handler for Timer1 (TimerOne) driven DMD refresh scanning, this gets
Â called at the period set in Timer1.initialize();
Â --------------------------------------------------------------------------------------*/
void ScanDMD()
{
Â  dmd.scanDisplayBySPI();
}

/*--------------------------------------------------------------------------------------
Â setup
Â Called by the Arduino architecture before the main loop begins
Â --------------------------------------------------------------------------------------*/
void setup(void)
{
Â  randomSeed(analogRead(0));
Â  //initialize TimerOne's interrupt/CPU usage used to scan and refresh the display
Â  Timer1.initialize( 5000 );Â Â Â Â Â Â Â Â Â Â  //period in microseconds to call ScanDMD. Anything longer than 5000 (5ms) and you can see flicker.
Â  Timer1.attachInterrupt( ScanDMD );Â Â  //attach the Timer1 interrupt to ScanDMD which goes to dmd.scanDisplayBySPI()
Â  //clear/init the DMD pixels held in RAM
Â  dmd.clearScreen( 0 );Â Â  //true is normal (all pixels off), false is negative (all pixels on)
Â  dmd.selectFont(Arial_Black_16);
Â  dmd.setupBuffer(3);
}

/*--------------------------------------------------------------------------------------
Â loop
Â Arduino architecture main loop
Â --------------------------------------------------------------------------------------*/
void loop(void)
{
Â  lookaround();
Â  dmd.setBufferEdit(0);
Â  smile();
Â  dmd.setBufferDisplay(0);
Â  delay(1000);
Â  wink();
Â  delay(300);
Â  dmd.copyBuffer(2,0);
Â  dmd.setBufferEdit(0);
Â  dmd.setBufferDisplay(0);
Â  char stringa[]="Happy Birthday Lucas";

Â  dmd.drawMarquee(stringa,strlen(stringa),64,16,0xFF,0);
Â  while (!dmd.stepMarquee(-1,0)){delay(30);}

Â  dmd.setBufferEdit(1);
Â  dmd.clearScreen(0);
Â  dmd.drawString(8,0,"Happy",5,1,0);
Â  dmd.drawString(0,16,"Birthday",8,1,0);
Â  dmd.drawString(6,32,"Lucas!",6,1,0);

Â  dmd.copyBuffer(0,2);
Â  dmd.setBufferDisplay(2); Â
Â  transition(0,1);
Â  delay(1000);
Â
Â  dmd.setBufferEdit(0);
Â  smile();
Â  transition(1,0);
Â  delay(500);
Â
Â  dmd.setBufferEdit(1);
Â  dmd.clearScreen(0);
Â  dmd.drawString(8,0,"Lucas",5,1,0);
Â  dmd.drawString(26,16,"is",2,1,0);
Â  dmd.drawString(16,32,"One!",4,1,0);
Â  dmd.copyBuffer(0,2);
Â  dmd.setBufferDisplay(2);

Â  transition(0,1);
Â  delay(1000);

Â  dmd.setBufferEdit(0);
Â  dmd.clearScreen(0);
Â  dmd.drawString(16,0,"Born",4,1,0);
Â  dmd.drawString(0,16,"28 April",8,1,0);
Â  dmd.drawString(16,32,"2011",4,1,0);

Â  transition(1,0);
Â  delay(1000);
Â
Â  dmd.copyBuffer(1,0);
}

void transition(byte from, byte to)
{
Â  int i=0;
Â  trans=random(8);
Â  dmd.copyBuffer(from,2);
Â  while (dmd.transition(from,to,2,trans,i)) {i=i+1;}
}

void wink()
{
Â  dmd.setBufferEdit(0);
Â  dmd.clearScreen(0);
Â  dmd.setBufferDisplay(2); Â
Â  head();
Â  eyes();
Â  mouth_smile();
Â  dmd.drawFilledBox(centreX-8,centreY-7,centreX-6,centreY-5,1);
Â  dmd.copyBuffer(0,2);

Â  int winkspeed=100; Â

Â  dmd.setBufferEdit(1);
Â  for (int i=0;i<=8;i++) {
Â Â Â  dmd.copyBuffer(0,1);
Â Â Â  if (i<=4) {
Â Â Â Â Â  dmd.drawFilledBox(centreX+6,centreY-7,centreX+8,centreY-5,1);
Â Â Â  } else if(i==5) {
Â Â Â Â Â  dmd.drawFilledBox(centreX+6,centreY-6,centreX+8,centreY-5,1);
Â Â Â  }
Â Â Â  int width=0;
Â Â Â  if (i==0 || i==8) {
Â Â Â Â Â  dmd.drawLine(centreX+7-1,centreY-11+i,centreX+7+1,centreY-11+i,1);
Â Â Â  } else if(i<=2 || i>=6) {
Â Â Â Â Â  dmd.drawLine(centreX+7-3,centreY-11+i,centreX+7+3,centreY-11+i,1);
Â Â Â  } else {
Â Â Â Â Â  dmd.drawLine(centreX+7-4,centreY-11+i,centreX+7+4,centreY-11+i,1);
Â Â Â  }
Â Â Â  dmd.copyBuffer(1,2);
Â Â Â  delay(50);
Â  }
Â  for (int i=8;i>=0;i--) {
Â Â Â  dmd.copyBuffer(0,1);
Â Â Â  if (i<=4) {
Â Â Â Â Â  dmd.drawFilledBox(centreX+6,centreY-7,centreX+8,centreY-5,1);
Â Â Â  } else if(i==5) {
Â Â Â Â Â  dmd.drawFilledBox(centreX+6,centreY-6,centreX+8,centreY-5,1);
Â Â Â  }
Â Â Â  int width=0;
Â Â Â  if (i==0 || i==8) {
Â Â Â Â Â  dmd.drawLine(centreX+7-1,centreY-11+i,centreX+7+1,centreY-11+i,1);
Â Â Â  } else if(i<=2 || i>=6) {
Â Â Â Â Â  dmd.drawLine(centreX+7-3,centreY-11+i,centreX+7+3,centreY-11+i,1);
Â Â Â  } else {
Â Â Â Â Â  dmd.drawLine(centreX+7-4,centreY-11+i,centreX+7+4,centreY-11+i,1);
Â Â Â  }
Â Â Â  dmd.copyBuffer(1,2);
Â Â Â  delay(50);
Â  }
Â  dmd.setBufferEdit(2);
}

void lookaround()
{
Â  //head
Â  dmd.setBufferEdit(0);
Â  dmd.clearScreen(0);
Â  dmd.setBufferDisplay(2); Â
Â  head();
Â  eyes();
Â  mouth_flat();
Â  dmd.copyBuffer(0,2);
Â
Â  // eyelids
Â  dmd.drawLine(centreX-5,centreY-10,centreX-10,centreY-10,1);
Â  dmd.drawLine(centreX+5,centreY-10,centreX+10,centreY-10,1);

Â  dmd.setBufferEdit(1);
Â  for (int i=0;i<=2;i++) {
Â Â Â  dmd.copyBuffer(0,1);
Â Â Â  dmd.drawFilledBox(centreX-8+i,centreY-7,centreX-6+i,centreY-5,1);
Â Â Â  dmd.drawFilledBox(centreX+6+i,centreY-7,centreX+8+i,centreY-5,1);
Â Â Â  dmd.copyBuffer(1,2);
Â Â Â  delay(100);
Â  }
Â  for (int i=2;i>=-2;i--) {
Â Â Â  dmd.copyBuffer(0,1);
Â Â Â  dmd.drawFilledBox(centreX-8+i,centreY-7,centreX-6+i,centreY-5,1);
Â Â Â  dmd.drawFilledBox(centreX+6+i,centreY-7,centreX+8+i,centreY-5,1);
Â Â Â  dmd.copyBuffer(1,2);
Â Â Â  delay(100);
Â  }
Â  for (int i=-2;i<=0;i++) {
Â Â Â  dmd.copyBuffer(0,1);
Â Â Â  dmd.drawFilledBox(centreX-8+i,centreY-7,centreX-6+i,centreY-5,1);
Â Â Â  dmd.drawFilledBox(centreX+6+i,centreY-7,centreX+8+i,centreY-5,1);
Â Â Â  dmd.copyBuffer(1,2);
Â Â Â  delay(100);
Â  }
Â  dmd.setBufferEdit(2);
}

void smile()
{
Â  dmd.clearScreen(0);
Â  head();
Â  eyes();
Â  mouth_smile();
Â  dmd.drawFilledBox(centreX-8,centreY-7,centreX-6,centreY-5,1);
Â  dmd.drawFilledBox(centreX+6,centreY-7,centreX+8,centreY-5,1);
}

void head()
{
Â  dmd.drawCircle(centreX,centreY,20,1);
}

void eyes()
{
Â  dmd.drawCircle(centreX-7,centreY-7,5,1);
Â  dmd.drawCircle(centreX+7,centreY-7,5,1);
}

void mouth_flat()
{
Â  dmd.drawLine(centreX-12,centreY+8,centreX+12,centreY+8,1);
}

void mouth_smile()
{
Â  dmd.drawLine(centreX-12,centreY+6,centreX-4,centreY+11,1);
Â  dmd.drawLine(centreX-4,centreY+11,centreX,centreY+11,1);
Â  dmd.drawLine(centreX+4,centreY+11,centreX,centreY+11,1);
Â  dmd.drawLine(centreX+12,centreY+6,centreX+4,centreY+11,1);
}

```
