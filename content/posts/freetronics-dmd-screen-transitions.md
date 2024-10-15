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
  Includes
  ----------------------------------------------------------------*/
#include <SPI.h>               //SPI.h must be included as DMD is written by SPI (the IDE complains otherwise)
#include <DMD.h>               //
#include <TimerOne.h>     //
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
  Interrupt handler for Timer1 (TimerOne) driven DMD refresh scanning, this gets
  called at the period set in Timer1.initialize();
  --------------------------------------------------------------------------------------*/
void ScanDMD()
{
   dmd.scanDisplayBySPI();
}

/*--------------------------------------------------------------------------------------
  setup
  Called by the Arduino architecture before the main loop begins
  --------------------------------------------------------------------------------------*/
void setup(void)
{
   randomSeed(analogRead(0));
   //initialize TimerOne's interrupt/CPU usage used to scan and refresh the display
   Timer1.initialize( 5000 );                     //period in microseconds to call ScanDMD. Anything longer than 5000 (5ms) and you can see flicker.
   Timer1.attachInterrupt( ScanDMD );     //attach the Timer1 interrupt to ScanDMD which goes to dmd.scanDisplayBySPI()
   //clear/init the DMD pixels held in RAM
   dmd.clearScreen( 0 );     //true is normal (all pixels off), false is negative (all pixels on)
   dmd.selectFont(Arial_Black_16);
   dmd.setupBuffer(3);
}

/*--------------------------------------------------------------------------------------
  loop
  Arduino architecture main loop
  --------------------------------------------------------------------------------------*/
void loop(void)
{
   lookaround();
   dmd.setBufferEdit(0);
   smile();
   dmd.setBufferDisplay(0);
   delay(1000);
   wink();
   delay(300);
   dmd.copyBuffer(2,0);
   dmd.setBufferEdit(0);
   dmd.setBufferDisplay(0);
   char stringa[]="Happy Birthday Lucas";

   dmd.drawMarquee(stringa,strlen(stringa),64,16,0xFF,0);
   while (!dmd.stepMarquee(-1,0)){delay(30);}

   dmd.setBufferEdit(1);
   dmd.clearScreen(0);
   dmd.drawString(8,0,"Happy",5,1,0);
   dmd.drawString(0,16,"Birthday",8,1,0);
   dmd.drawString(6,32,"Lucas!",6,1,0);

   dmd.copyBuffer(0,2);
   dmd.setBufferDisplay(2);  
   transition(0,1);
   delay(1000);
 
   dmd.setBufferEdit(0);
   smile();
   transition(1,0);
   delay(500);
 
   dmd.setBufferEdit(1);
   dmd.clearScreen(0);
   dmd.drawString(8,0,"Lucas",5,1,0);
   dmd.drawString(26,16,"is",2,1,0);
   dmd.drawString(16,32,"One!",4,1,0);
   dmd.copyBuffer(0,2);
   dmd.setBufferDisplay(2);

   transition(0,1);
   delay(1000);

   dmd.setBufferEdit(0);
   dmd.clearScreen(0);
   dmd.drawString(16,0,"Born",4,1,0);
   dmd.drawString(0,16,"28 April",8,1,0);
   dmd.drawString(16,32,"2011",4,1,0);

   transition(1,0);
   delay(1000);
 
   dmd.copyBuffer(1,0);
}

void transition(byte from, byte to)
{
   int i=0;
   trans=random(8);
   dmd.copyBuffer(from,2);
   while (dmd.transition(from,to,2,trans,i)) {i=i+1;}
}

void wink()
{
   dmd.setBufferEdit(0);
   dmd.clearScreen(0);
   dmd.setBufferDisplay(2);  
   head();
   eyes();
   mouth_smile();
   dmd.drawFilledBox(centreX-8,centreY-7,centreX-6,centreY-5,1);
   dmd.copyBuffer(0,2);

   int winkspeed=100;  

   dmd.setBufferEdit(1);
   for (int i=0;i<=8;i++) {
       dmd.copyBuffer(0,1);
       if (i<=4) {
           dmd.drawFilledBox(centreX+6,centreY-7,centreX+8,centreY-5,1);
       } else if(i==5) {
           dmd.drawFilledBox(centreX+6,centreY-6,centreX+8,centreY-5,1);
       }
       int width=0;
       if (i==0 || i==8) {
           dmd.drawLine(centreX+7-1,centreY-11+i,centreX+7+1,centreY-11+i,1);
       } else if(i<=2 || i>=6) {
           dmd.drawLine(centreX+7-3,centreY-11+i,centreX+7+3,centreY-11+i,1);
       } else {
           dmd.drawLine(centreX+7-4,centreY-11+i,centreX+7+4,centreY-11+i,1);
       }
       dmd.copyBuffer(1,2);
       delay(50);
   }
   for (int i=8;i>=0;i--) {
       dmd.copyBuffer(0,1);
       if (i<=4) {
           dmd.drawFilledBox(centreX+6,centreY-7,centreX+8,centreY-5,1);
       } else if(i==5) {
           dmd.drawFilledBox(centreX+6,centreY-6,centreX+8,centreY-5,1);
       }
       int width=0;
       if (i==0 || i==8) {
           dmd.drawLine(centreX+7-1,centreY-11+i,centreX+7+1,centreY-11+i,1);
       } else if(i<=2 || i>=6) {
           dmd.drawLine(centreX+7-3,centreY-11+i,centreX+7+3,centreY-11+i,1);
       } else {
           dmd.drawLine(centreX+7-4,centreY-11+i,centreX+7+4,centreY-11+i,1);
       }
       dmd.copyBuffer(1,2);
       delay(50);
   }
   dmd.setBufferEdit(2);
}

void lookaround()
{
   //head
   dmd.setBufferEdit(0);
   dmd.clearScreen(0);
   dmd.setBufferDisplay(2);  
   head();
   eyes();
   mouth_flat();
   dmd.copyBuffer(0,2);
 
   // eyelids
   dmd.drawLine(centreX-5,centreY-10,centreX-10,centreY-10,1);
   dmd.drawLine(centreX+5,centreY-10,centreX+10,centreY-10,1);

   dmd.setBufferEdit(1);
   for (int i=0;i<=2;i++) {
       dmd.copyBuffer(0,1);
       dmd.drawFilledBox(centreX-8+i,centreY-7,centreX-6+i,centreY-5,1);
       dmd.drawFilledBox(centreX+6+i,centreY-7,centreX+8+i,centreY-5,1);
       dmd.copyBuffer(1,2);
       delay(100);
   }
   for (int i=2;i>=-2;i--) {
       dmd.copyBuffer(0,1);
       dmd.drawFilledBox(centreX-8+i,centreY-7,centreX-6+i,centreY-5,1);
       dmd.drawFilledBox(centreX+6+i,centreY-7,centreX+8+i,centreY-5,1);
       dmd.copyBuffer(1,2);
       delay(100);
   }
   for (int i=-2;i<=0;i++) {
       dmd.copyBuffer(0,1);
       dmd.drawFilledBox(centreX-8+i,centreY-7,centreX-6+i,centreY-5,1);
       dmd.drawFilledBox(centreX+6+i,centreY-7,centreX+8+i,centreY-5,1);
       dmd.copyBuffer(1,2);
       delay(100);
   }
   dmd.setBufferEdit(2);
}

void smile()
{
   dmd.clearScreen(0);
   head();
   eyes();
   mouth_smile();
   dmd.drawFilledBox(centreX-8,centreY-7,centreX-6,centreY-5,1);
   dmd.drawFilledBox(centreX+6,centreY-7,centreX+8,centreY-5,1);
}

void head()
{
   dmd.drawCircle(centreX,centreY,20,1);
}

void eyes()
{
   dmd.drawCircle(centreX-7,centreY-7,5,1);
   dmd.drawCircle(centreX+7,centreY-7,5,1);
}

void mouth_flat()
{
   dmd.drawLine(centreX-12,centreY+8,centreX+12,centreY+8,1);
}

void mouth_smile()
{
   dmd.drawLine(centreX-12,centreY+6,centreX-4,centreY+11,1);
   dmd.drawLine(centreX-4,centreY+11,centreX,centreY+11,1);
   dmd.drawLine(centreX+4,centreY+11,centreX,centreY+11,1);
   dmd.drawLine(centreX+12,centreY+6,centreX+4,centreY+11,1);
}

```
