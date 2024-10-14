---
author: cjd
tags:
  - leostick
  - arduino
date: "2012-05-21T02:26:47+00:00"
title: USB-Rubber Ducky scripts on Arduino/Leostick
url: /blog/2012/05/21/usb-rubber-ducky-scripts-on-arduinoleostick/

---
The other day I was at Jaycar and saw that they are now selling small USB sticks that are arduino compatible.
It is called the [LeoStick](http://www.freetronics.com/products/leostick "LeoStick") and is made by Freetronics down in Melbourne.
Seeing that it could pretend to be a USB HID device (ie keyboard/mouse) I wondered if I could do the sort of thing that the [USB Rubber Ducky](http://hakshop.myshopify.com/products/usb-rubber-ducky "Ducky Store") from Hak5 can do
As it turns out the answer is YES :)

Since it was possible I spent an hour or two writing a quick shell script which can convert ducky script payloads into a sketch suitable for uploading to the LeoStick (or any arduino that has USB-HID capability)Â Â  The end result is a small bash script which can be downloaded from [compile\_payload.sh](/files/leo/compile_payload.sh "Download script")

Usage is fairly simple - you run the script with two options - the first being the payload file, and the second being the arduino script output.

ie: compile\_payload lock\_prank.txt lock\_prank.ino

Various payloads can be found linked from the [USB-Rubber-Ducky wiki](https://github.com/hak5darren/USB-Rubber-Ducky/wiki "Ducky wiki")

As a bit of fun I changed the lock\_prank payload to work on Gnome/Linux and it also plays the mission impossible theme once done ;)
Grab it from [lock\_prank.ino](/files/leo/lock_prank.ino "lock_prank download")

Also note that to get this working you need to edit the arduino libraries so that the sendReport function is marked as public.

To to this edit the USBAPI.h file which can be found in ${ARDUINO\_DIR}/hardware/arduino/cores/arduino directory.
This may be /usr/share/arduino/hardware/arduino/cores/arduino/USBAPI.h or similar
If you installed the LeoStick board stuff from their website then it will be under your sketches directory as hardware/LeoStick/cores/arduino/USBAPI.h

Open that file and find

```
private:
    KeyMap* _keyMap;
    void sendReport(KeyReport* keys);
    void setKeyMap(KeyMap* keyMap);
public:
    Keyboard_();
    virtual size_t write(uint8_t);
```

Then change that to

```
private:
    KeyMap* _keyMap;
    void setKeyMap(KeyMap* keyMap);
public:
    void sendReport(KeyReport* keys);
    Keyboard_();
    virtual size_t write(uint8_t);
```

Then everything should work fine.
