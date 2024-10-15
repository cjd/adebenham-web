---
author: cjd
date: "2010-01-30T03:48:31+00:00"
tags:
  - arduino
  - peggy-2
title: Peggy 2 Character display
url: /blog/2010/01/30/peggy-2-character-display/

---
As mentioned in the  \[intlink id="13" type="post"\]Peggy 2 Snake\[/intlink\] post I wrote a bunch of small utility functions to display a string on the peggy 2.

Each character is stored as a 24-bit number (held in a 32bit uint32) where each 4 bits indicates the on/off status for a row of 4 pixels. This results in allowing for a 4x6 pixel character

For example the character for the number '0' is stored as 0x699996 which when spread out looks like:

```
0110
1001
1001
1001
1001
0110
```

By doing this I can store 0-9 and A-Z in only 144bytes.
To save RAM I put this in program memory using: PROGMEM prog\_uint32\_t chars\[37\] ï»¿

To write a character to the display I use a function "show\_char" (note I use a special function 'setPixel' to set the individual pixels to a certain brightness level - but if you are not using grayscale then the call can be replaced by standard frame.SetPixel calls)

```
void show_char(char Character, byte x, byte y)
{
  byte charNum = 36;
  if ((Character >= '0') && (Character <= '9')) {
    charNum=Character-48;
  }
  if ((Character >= 'A') && (Character <= 'Z')) {
    charNum=Character-55;
  }
  unsigned long w;
  w = pgm_read_dword_near(chars + charNum);
  for (byte i=0; i<6; i++) {
    byte offset = 4*(5-i);
    byte b = w >> offset; // get four bits
    b=b & 0xF;
    if (b & B1000) setPixel(x,y+i,7);
    if (b & B0100) setPixel(x+1,y+i,7);
    if (b & B0010) setPixel(x+2,y+i,7);
    if (b & B0001) setPixel(x+3,y+i,7);
  }
}

```

To make things a bit easier to display a string I also created a quick wrapper function 'write\_string'

```
void write_string(char string[], byte x, byte y)
{
  byte i=0;
  while (string[i] != '\0') {
    show_char(string[i], x+(5*i), y);
    i++;
  }
}

```

Full usage/source can be found in the peggy 2 snake code
