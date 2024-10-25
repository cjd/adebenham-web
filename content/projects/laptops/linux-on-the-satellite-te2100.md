---
author: cjd
date: "2010-02-04T01:28:15+00:00"
title: Linux on the Satellite TE2100
summary: Details on getting Linux working on a TE2100
url: /laptop/linux-on-the-toshiba-satellite-te2100/
thumbnail: /projects/laptops/te2100.jpg
toc: false

---
# Linux on the Toshiba Satellite TE2100

## Preface

This is a survey about Linux related hardware features of the Toshiba Satellite TE2100.

## Installation

On my TE2100 I have installed the **[Debian](http://www.debian.org/)** Linux distribution.
Currently I am using _sid/unstable_
I initially installed Mandrake 8.2 (had some cd's handy) and it booted/installed first time, no problems

## General Hardware Data

General system information:

``` shell
Linux debianham 2.4.20-ck6 #10 Mon May 5 18:15:58 EST 2003 i686 unknown unknown GNU/Linux
```

``` shell
processor   : 0
vendor_id   : GenuineIntel
cpu family  : 15
model       : 2
model name  : Intel(R) Pentium(R) 4 Mobile CPU 1.60GHz
stepping    : 4
cpu MHz     : 1594.858
cache size  : 512 KB
fdiv_bug    : no
hlt_bug     : no
f00f_bug    : no
coma_bug    : no
fpu     : yes
fpu_exception   : yes
cpuid level : 2
wp      : yes
flags       : fpu vme de pse tsc msr pae mce cx8 sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm
bogomips    : 3185.04

```

### Hard Disk/DVD-ROM

30GB IDE with the unmask\_irq, dma and 32-bit I/O support turned on. Use the following command to set this up

``` shell
hdparm -d1 -u1 -c1 -m16 -X66 /dev/discs/disc0/disc

```

By doing this I went from 3.11MB/s to 22.15MB/s transfer speed

The DVD supports dma, unmask\_irq and 32-bit I/O as well

``` shell
hdparm -d1 -u1 -c1 /dev/cdroms/cdrom0

```

Note: the above commands are for people using devfs, other wise you use /dev/hda for the HD and /dev/hdc for the DVD

### Ethernet

Intel Ethernet Pro 100
Supported by the eepro100 or e100 kernel module, I use eepro100 since has less licensing 'difficulties'

### PCMCIA

Works wonderfully, I have a Avaya silver 802.11b card (11Mbps) that is supported by the orinoco\_cs module.
'cardmgr' recognizes the card straight off and starts it up automatically (DHCP to the rescue)

### Graphic-Chip

Nvidia GeForce4 420 Go chipset
Supported well by the binary Nvidia drivers, supported by standard XFree86 _nv_ driver since 4.3.0 (2D only) but for earlier versions you may need to use vesa driver for the initial install. My XF86Config-4 is available [here](/files/laptop/XF86Config-4)
If you are having problems with there being a black border down the right side of the screen add the following lines to your /etc/modules.conf (some may already exist)

``` shell
    alias /dev/nvidia* nvidia
    alias char-major-195 nvidia
    options nvidia NVreg_SoftEDIDs=0 NVreg_Mobile=2
```

### Keyboard

Originally I had problems with the keyboard in XFree86 in that when I typed quickly it would recognize each key twice. This is fixed by adding the following line to your XF86Config-4 file into the ServerFlags section

``` shell
Option          "XkbDisable"    "true"
```

### APM

APM suspend works fine if you are not running X, but if you need to suspend from X you will need to modify the nvidia kernel module as below

1. Grab the sources to the latest nvidia driver (modification works for older versions as well) and search for a file named nv.c once they are extracted. Go to the directory containing that file.
1. Open nv.c in your favourite editor and search for "APM"
1. In the lines following this look for "return 1;" in that subroutine (anywhere up to the second #endif)
1. Change each instance to "return 0;"
1. Save the file, exit then run "make install" and watch the magic

Note: This works for me even with AGP turned on YMMV

Example:

Before

``` shell
default:
    nv_printf(NV_DBG_INFO, "NVRM: received unknown PM event: 0x%x\n", rqst);
    return 0;
```

After

``` shell
default:
    nv_printf(NV_DBG_INFO, "NVRM: received unknown PM event: 0x%x\n", rqst);
    return 0;
```

### Sound

Intel 810 Audio
Supported by kernel OSS driver but the kernel driver (as of 2.4.20) doesn't support multiple sample rates (causing some audio to play double speed etc.) so use the ALSA 0.9 drivers as they work perfectly.

### Infrared Port - IrDA(TM)

I don't have any IrDA devices so unsure if this works

### Floppydrive

USB floppy drive provided and worked beautifully.

### Modem

The modem appears to be a Lucent AMR soft modem and I haven't managed to get it working, so far no drivers found.

### Useful Utilities

There are two main utilities that come in handy.
The first and most important is Toshutils available from [http://www.buzzard.org.uk/toshiba/](http://www.buzzard.org.uk/toshiba/)
The second contains utils to set the cpu speed/lcd brightness to particular settings (good for getting that last bit of battery life) [5005utils](http://rooster.stanford.edu/%7Eben/toshiba/utility.php)

## Survey PCI Devices

Output from `lspci`:

``` shell
00:00.0 Host bridge: Intel Corp. 82845 845 (Brookdale) Chipset Host Bridge (rev 04)
00:01.0 PCI bridge: Intel Corp. 82845 845 (Brookdale) Chipset AGP Bridge (rev 04)
00:1d.0 USB Controller: Intel Corp. 82801CA/CAM USB (Hub &num;1) (rev 02)
00:1d.1 USB Controller: Intel Corp. 82801CA/CAM USB (Hub &num;2) (rev 02)
00:1d.2 USB Controller: Intel Corp. 82801CA/CAM USB (Hub &num;3) (rev 02)
00:1e.0 PCI bridge: Intel Corp. 82801BAM/CAM PCI Bridge (rev 42)
00:1f.0 ISA bridge: Intel Corp. 82801CAM ISA Bridge (LPC) (rev 02)
00:1f.1 IDE interface: Intel Corp. 82801CAM IDE U100 (rev 02)
00:1f.5 Multimedia audio controller: Intel Corp. 82801CA/CAM AC'97 Audio (rev 02)
00:1f.6 Modem: Intel Corp. 82801CA/CAM AC'97 Modem (rev 02)
01:00.0 VGA compatible controller: nVidia Corporation NV17 [GeForce4 420 Go] (rev a3)
02:08.0 Ethernet controller: Intel Corp. 82801CAM (ICH3) Chipset Ethernet Controller (rev 42)
02:0b.0 CardBus bridge: Toshiba America Info Systems ToPIC95 PCI to Cardbus Bridge with ZV Support (rev 32)
02:0b.1 CardBus bridge: Toshiba America Info Systems ToPIC95 PCI to Cardbus Bridge with ZV Support (rev 32)

```

## Credits

- [MobiliX](http://mobilix.org/)

* * *

This report was made by modifying the output of `lanoche` v0.6 Thu Aug 1 10:18:37 EST 2002.

The latest version of `lanoche` is available at [MobiliX - Software](http://mobilix.org/software.html).
