---
author: cjd
date: "2010-02-04T01:24:46+00:00"
title: Linux on the Portege M200
url: /laptop/toshiba-portege-m200/
summary: Details on getting Linux working on an M200
thumbnail: /projects/laptops/m200.gif
toc: false

---
# Debian Linux on the Toshiba Portege M200

## The Machine Hardware Quickstart

The Toshiba M200 is a convertable TabletPC (ie can be used as a normal laptop, but with a quick flip/turn of the screen it works as a Tablet).
It has a 12" screen, Pentium M 1.4GHz (centrino) and the main part of it is that the screen has a digitizer builtin (using the included stylus).
My configuration has 512MB memory and a 60GB harddisk.
I am running Ubuntu (7.04) with Linux kernel 2.6.20-15.

## What Works/Overview

| **CPU** | **Hard Disk** | **Memory** | **Ethernet** | **Wireless** | **Graphics Card** | **Modem** |
| -- | -- | -- | -- | -- | -- | -- |
| Pentium M 1.4GHz | 60GB | 512MB | Intel Etherexpress 100 | Intel PRO/Wireless 2100 - supported by ipw2100 driver | nVidia GeForce FX Go5200 | Software-based - supported by sl-modem or intel8x0m |
| **Screen** | **Digitizer/Tablet** | **Tablet Keys** | **SD Slot** | **ACPI** | **Sound** | **Bluetooth** |
| 12.1" LCD 1400x1050 | Wacom ISD V4 | Respond as normal keys | Doesn't even show up **but can be used to hold a boot floppy image** | Suspend to ram works | Intel 8x0 sound | Works

## Installation

Due the the machine not having any internal CD/DVD drive installation has to be done via USB-floppy or the network. I couldn't find a working floppy disk (you hardly ever need one, but once you do you can never find one :-) so I had to do the install via the network.
If you have a SD card you can boot of the SD slot by copying a floppy-disk image to the sd card (via windows or a USB->SD adaptor) as long as you name it $tosfd00.vfd
I setup a network boot server on another box (a Sun Ultra30 running Debian in my case) by following the instructions at [debian.org](http://www.debian.org/releases/stable/i386/ch-install-methods.en.html).
Sadly the standard install images didn't include the driver for the onboard ethernet so instead I used the debian-installer images. Once I figured this out all went smooth.

## CPU

Intel Pentium-M 1.4GHz (also known as Intel Centrino)
This works without issue, but to save battery you can enable speedstep so you can change the cpu speed from 600MHz to 1400MHz as needed.
I use a program called [Powernowd](http://www.deater.net/john/powernowd.html) which slows the CPU down when it is idle, but quickly puts the CPU back up (in 200MHz increments) when the CPU is being stressed.

## Hard Disk

IDE 60GB 5400rpm. Supports DMA. To get better performance make sure you use hdparm to turn on DMA and unmask the IRQ.
to do this use:

``` shell
/sbin/hdparm -d1 -u1 -m16 -c3 /dev/hda
```

Change /dev/hda to /dev/discs/disc0/disc or /dev/sda if needed

## Memory

768MB as 512MB + 256MB DIMMS
No issues here

## Ethernet

The onboard LAN port is an Intel EtherExpress100 and so supported by the e100 or eepro100 modules. I use the e100 module.

## Wireless

The builtin wireless is an Intel PRO/Wireless 2100 (as in all centrino-based machines)
Support for this is now available natively and is provided by the ipw2100 kernel module available from [http://ipw2100.sourceforge.net/](http://ipw2100.sourceforge.net/)

## Screen

The Screen is a 12.1" LCD supporting resolutions up to 1400x1050.
Mode 1400x1050 runs at a pixelclock of 162.0 MHz, HSync of 82.7 kHz and VRefresh of 75.1 Hz

## Graphics Card

The onboard GPU is a nVidia GeForce FX Go5200 which was not supported by the opensource 'nv' driver in XFree86 4.3 but is now with the 'nv' driver in xorg.
Full accelerated 2d/3d support can be provided by the closed-source nVidia driver and ACPI suspend now works with this.
If you can accept the loss of 3D acceleration (which I can put up with mostly) you can grab the driver from XFree86 4.3.99 (to be 4.4) which does work with the GPU.
I use the 'nvidia' driver and it now supports XRandR so the screen can be rotated by simply running 'xrandr -o <orientation>' where <orientation> is left, right, or normal. My xorg.conf file is [here](/files/laptop/xorg.conf).

If you want the console to be at a higher res (rather than 80x25 chars) you can use the VESA framebuffer driver which is built into most kernels.
To get it running at the screens native res (1400x1050) use _vga=840_ in your lilo.conf or grubs menu.lst.

## Modem

The modem is a software modem that works fine with either the intel8x0m driver which is part of ALSA or the sl-modem driver which supports a few more features.

## Digitizer

The Digitizer built into the screen is a Serial Wacom tablet on IO port 338.
To get this working I used to have to run but with recent system updates it is no longer needed:

``` shell
setserial /dev/tts/0 port 0x338 autoconfig
```

I used to have some problems with the wacom driver when in portrait mode but by using [this](/files/laptop/wacom_drv.o) file and putting it in /usr/X11R6/lib/modules/input replacing the standard one. This has been fixed in upstream now and is no longer needed

## Tablet Keys

There are a bunch of 3 keys that are accessable when the M200 is in tablet mode.
The top one sends 'Ctrl-Alt-Delete' (labelled as 'Lock' key)
The second one sends 'Escape'
The bottom one is actually a joystick style key that sends the arrow keys when moved or 'Enter' when pressed down.
Since they are all sent as normal keys nothing is needed to get them working.
The only issue here is that when the screen is rotated the arrows go the wrong directions. In order to get them working as rotated keys I run xmodmap as

``` shell
xmodmap ~/.xmodmaprc
```

using this .xmodmaprc sitting in my home directory

## SD Slot

The SD-slot doesn't work and from my web travels is appears that many other laptops have this same problem.
Oh well.
**NEW:** If you copy a floppy disk image (up to 2.88MB) to a SD card and name it $tosfd00.vfd you can boot off the slot. Can be used for initial installation or as a rescue device
Try my rescue image which boots with support for wireless and wired network, full X server and various recovery apps
You can download it from [Here](/files/laptop/floppy.img) just save it as $tosfd00.vfd to your sd-card

## ACPI/Suspend

ACPI S3 (suspend-to-ram) works with kernel 2.6.0+ with both the open and closed-source nVidia drivers

## Sound

The onboard soundcard works as an Intel8x0 card (same as most other intel-based laptops)

## Bluetooth

My laptop doesn't have bluetooth but I have been assured by Jens Gustedt that it works if you patch your kernel with the experimental [Toshiba\_acpi](http://memebeam.org/toys/ExperimentalToshibaAcpiDriver) patch and use a recent version of [Toshset](http://www.schwieters.org/toshset/)

## Conclusion

Sweet
