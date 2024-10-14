---
author: cjd
date: "2012-02-04T04:49:27+00:00"
tags:
  - arduino
  - dmd
title: Freetronics DMD - updated library
url: /blog/2012/02/04/freetronics-dmd-updated-library/

---
I recently got two Dot Matrix Displays from Freetronics -
They are 32x16 LED panels that can be daisychained via SPI.
It came with a quick library which worked okay but could do with a few enhancements ;)
My modified library supports multiple displays (tested with 2x1 and 1x2 layout - but should work with other layouts)
It also supports multiple fonts, marquee text, scrolling the display around and grayscale (grayscale sort of works - but not well :( )
I have updated the examples included in the original library to use these new functions.

The library can be downloaded from [github.com/cjd/DMD](https://github.com/cjd/DMD)
See [freetronics forum for my DMD library](http://forum.freetronics.com/viewtopic.php?f=26&t=153)
\[youtube\_sc url="5DLmWrpV-3M"\]
