#!/bin/bash
INFILE=$1
OUTFILE=$2

echo "#define KEY_A           0x04  // A key on keyboard, 'a' or 'A'
#define KEY_B           0x05
#define KEY_C           0x06
#define KEY_D           0x07
#define KEY_E           0x08
#define KEY_F           0x09
#define KEY_G           0x0A
#define KEY_H           0x0B
#define KEY_I           0x0C
#define KEY_J           0x0D
#define KEY_K           0x0E
#define KEY_L           0x0F
#define KEY_M           0x10
#define KEY_N           0x11
#define KEY_O           0x12
#define KEY_P           0x13
#define KEY_Q           0x14
#define KEY_R           0x15
#define KEY_S           0x16
#define KEY_T           0x17
#define KEY_U           0x18
#define KEY_V           0x19
#define KEY_W           0x1A
#define KEY_X           0x1B
#define KEY_Y           0x1C
#define KEY_Z           0x1D
#define KEY_1           0x1E  // 1 key on keyboard, '1' or '!'
#define KEY_2           0x1F  // 2 key on keyboard, '2' or '@'
#define KEY_3           0x20  // 3 key on keyboard, '3' or '#'
#define KEY_4           0x21  // 4 key on keyboard, '4' or '$'
#define KEY_5           0x22  // 5 key on keyboard, '5' or '%'
#define KEY_6           0x23  // 6 key on keyboard, '6' or '^'
#define KEY_7           0x24  // 7 key on keyboard, '7' or '&'
#define KEY_8           0x25  // 8 key on keyboard, '8' or '*'
#define KEY_9           0x26  // 9 key on keyboard, '(' or '('
#define KEY_0           0x27  // 0 key on keyboard, '0' or ')'
#define	KEY_ENTER       0x28  // Keyboard Enter key, different from Keypad enter
#define	KEY_ESC	        0x29  // Escape
#define	KEY_BACKSPACE   0x2A  // Backspace
#define	KEY_TAB	        0x2B  // Tab
#define	KEY_SPACE       0x2C  // Spacebar
#define	KEY_MINUS       0x2D  // Minus key, '-' or '_'
#define	KEY_EQUAL	0x2E  // Equals key, '=' or '+'
#define	KEY_LEFTBRACE	0x2F  // Left brace, '[' or '{'
#define	KEY_RIGHTBRACE	0x30  // Right brace, ']' or '}'
#define	KEY_BACKSLASH	0x31  // Backslash key, '\' or '|'
#define	KEY_NONUSHASH	0x32  // Non-US '#' and '~'
#define	KEY_SEMICOLON	0x33  // Semicolon key, ';' or ':'
#define	KEY_APOSTROPHE	0x34  // Apostrophe key, ''' or double-quotes
#define	KEY_GRAVE	0x35  // Grave accent key, '' or '~'
#define	KEY_COMMA	0x36  // Comma key, ',' or '<'
#define	KEY_DOT	        0x37  // Dot key, '.' or '>'
#define	KEY_SLASH	0x38  // Forward slash key, '/' or '?'
#define	KEY_CAPSLOCK	0x39  // Caps Lock key, 
#define	KEY_F1	        0x3A  // Keyboard F1 key
#define	KEY_F2	        0x3B  // Keyboard F2 key
#define	KEY_F3	        0x3C
#define	KEY_F4	        0x3D
#define	KEY_F5	        0x3E
#define	KEY_F6	        0x3F
#define	KEY_F7	        0x40
#define	KEY_F8	        0x41
#define	KEY_F9	        0x42
#define	KEY_F10	        0x43
#define	KEY_F11	        0x44
#define	KEY_F12	        0x45
#define	KEY_SYSRQ	0x46  // PrintScreen Key
#define	KEY_SCROLLLOCK	0x47  // Scroll Lock key
#define	KEY_PAUSE	0x48  // Pause key
#define	KEY_INSERT	0x49  // Insert key
#define	KEY_HOME	0x4A  // Home key
#define	KEY_PAGEUP	0x4B  // Page up key
#define	KEY_DELETE	0x4C  // Delete Forward key
#define	KEY_END	        0x4D  // End key
#define	KEY_PAGEDOWN	0x4E  // Page down key
#define	KEY_RIGHT	0x4F  // Right arrow
#define	KEY_LEFT	0x50  // Left arrow
#define	KEY_DOWN	0x51  // Down arrow
#define	KEY_UP	        0x52  // Up arrow
#define	KEY_NUMLOCK	0x53  // Num Lock and clear
#define	KEY_KPSLASH	0x54  // Keypad Forward slash (/)
#define	KEY_KPASTERISK	0x55  // Keypad asterisk (*)
#define	KEY_KPMINUS	0x56  // Keypad minus (-)
#define	KEY_KPPLUS	0x57  // Keypad plus (+)
#define	KEY_KPENTER	0x58  // Keypad Enter, different from keyboard enter
#define	KEY_KP1	        0x59  // Keypad 1 and End
#define	KEY_KP2	        0x5A  // Keypad 2 and Down arrow
#define	KEY_KP3	        0x5B  // Keypad 3 and Page Down
#define	KEY_KP4	        0x5C  // Keypad 4 and Left arrow
#define	KEY_KP5	        0x5D  // Keypad 5
#define	KEY_KP6	        0x5E  // Keypad 6 and Right arrow
#define	KEY_KP7	        0x5F  // Keypad 7 and Home
#define	KEY_KP8	        0x60  // Keypad 8 and Up arrow
#define	KEY_KP9	        0x61  // Keypad 9 and Page up
#define	KEY_KP0	        0x62  // Keypad 0 and Insert
#define	KEY_KPDOT	0x63  // Keypad . and Delete
#define	KEY_102ND	0x64  // Keyboard Non-US \ and |
#define	KEY_COMPOSE	0x65  // Keyboard application, right click-ish 'compose' key
#define	KEY_POWER	0x66  // Keyboard Power, not usually a phsyical key
#define	KEY_KPEQUAL	0x67  // Keypad =
#define	KEY_F13	        0x68  // Keyboard F13
#define	KEY_F14	        0x69
#define	KEY_F15	        0x6A
#define	KEY_F16	        0x6B
#define	KEY_F17	        0x6C
#define	KEY_F18	        0x6D
#define	KEY_F19	        0x6E
#define	KEY_F20	        0x6F
#define	KEY_F21	        0x70
#define	KEY_F22	        0x71
#define	KEY_F23	        0x72
#define	KEY_F24	        0x73  // Keyboard F24
#define	KEY_OPEN	0x74  // Keyboard Execute
#define	KEY_HELP	0x75  // Keyboard Help
#define	KEY_PROPS	0x76  // Keyboard Menu
#define	KEY_FRONT	0x77  // Keyboard Select
#define	KEY_STOP	0x78  // Keyboard Stop
#define	KEY_AGAIN	0x79  // Keyboard Again
#define	KEY_UNDO	0x7A  // Keyboard Undo
#define	KEY_CUT	        0x7B  // Keyboard Cut
#define	KEY_COPY	0x7C  // Keyboard Copy
#define	KEY_PASTE	0x7D  // Keyboard Paste
#define	KEY_FIND	0x7E  // Keyboard Find
#define	KEY_MUTE	0x7F  // Keyboard Mute
#define	KEY_VOLUMEUP	0x80  // Keyboard Volume Up
#define	KEY_VOLUMEDOWN	0x81  // Keyboard Volume Down
#define KEY_RETURN      0x9E  // Keyboard Return
#define	KEY_LEFTCTRL	0xE0  // Keyboard Left Control
#define	KEY_LEFTSHIFT	0xE1  // Keyboard Left Shift
#define	KEY_LEFTALT	0xE2  // Keyboard Left Alt
#define	KEY_LEFTGUI	0xE3  // Keyboard Left GUI, windows key
#define	KEY_RIGHTCTRL	0xE4  // Keyboard Right control
#define	KEY_RIGHTSHIFT	0xE5  // Keyboard Right Shift
#define	KEY_RIGHTALT	0xE6  // Keyboard Right alt
#define	KEY_RIGHTGUI	0xE7  // Keyboard Right GUI, windows key
#define	KEY_PLAYPAUSE	0xE8  // Reserved? ...\/
#define	KEY_STOPCD	0xE9
#define	KEY_PREVIOUSSONG  0xEA
#define	KEY_NEXTSONG	0xEB
#define	KEY_EJECTCD	0xEC
#define	KEY_WWW	        0xF0
#define	KEY_BACK	0xF1
#define	KEY_FORWARD	0xF2
#define	KEY_SCROLLUP	0xF5
#define	KEY_SCROLLDOWN	0xF6
#define	KEY_EDIT	0xF7 

void sendKey(byte key, byte key2, byte modifiers)
{
  KeyReport report = {0};  // Create an empty KeyReport
  
  /* First send a report with the keys and modifiers pressed */
  report.keys[0] = key;  // set the KeyReport to key
  report.keys[1] = key2;
  report.modifiers = modifiers;  // set the KeyReport's modifiers
  report.reserved = 1;
  Keyboard.sendReport(&report);  // send the KeyReport
  
  /* Now we've got to send a report with nothing pressed */
  for (int i=0; i<6; i++)
    report.keys[i] = 0;  // clear out the keys
  report.modifiers = 0x00;  // clear out the modifires
  report.reserved = 0;
  Keyboard.sendReport(&report);  // send the empty key report
}


void loop(){
}

void setup(){
  delay(1000);
" > $OUTFILE
while read -r
do
  COMMAND=`echo -E "$REPLY" | sed -e 's/ .*$//g'`
  OPTIONS=`echo -E "$REPLY" | sed -s 's/^[^ ]* //g'`
  MODIFIERS="0";
  KEY1="0";
  KEY2="0";

  if [ "$COMMAND" = "REM" ] 
  then echo "  // $OPTIONS" >> $OUTFILE
  elif [ "$COMMAND" = "STRING" ] 
  then 
    OPTIONS=`echo "$OPTIONS" | sed -e 's/\\\\/\\\\\\\\/g' -e 's/"/\\\"/g'`
    IFS=" "
    echo "  Keyboard.print(\"$OPTIONS\");" >> $OUTFILE
  elif [ "$COMMAND" = "DELAY" ]
  then DELAY=$(( $OPTIONS * 10 )); echo "  delay(${DELAY});" >> $OUTFILE
  else
    for TOKEN in $REPLY
    do KEY=""
      if [ "$TOKEN" = "GUI" -o "$TOKEN" = "WINDOWS" ]
        then MODIFIERS="$MODIFIERS | KEY_MODIFIER_LEFT_GUI";
      elif [ "$TOKEN" = "SHIFT" ]
        then MODIFIERS="$MODIFIERS | KEY_MODIFIER_LEFT_SHIFT";
      elif [ "$TOKEN" = "ALT" ]
        then MODIFIERS="$MODIFIERS | KEY_MODIFIER_LEFT_ALT";
      elif [ "$TOKEN" = "CONTROL" -o "$TOKEN" = "CTRL" ]
        then MODIFIERS="$MODIFIERS | KEY_MODIFIER_LEFT_CTRL";
      elif [ "$TOKEN" = "MENU" -o "$TOKEN" = "APP" ]
        then KEY="PROPS"
      elif [ "$TOKEN" = "LEFTARROW" ]
        then KEY="LEFT"
      elif [ "$TOKEN" = "RIGHTARROW" ]
        then KEY="RIGHT"
      elif [ "$TOKEN" = "UPARROW" ]
        then KEY="UP"
      elif [ "$TOKEN" = "DOWNARROW" ]
        then KEY="DOWN"
      elif [ "$TOKEN" = "ESCAPE" ]
        then KEY="ESC"
      else KEY=$TOKEN
      fi
      if [ "$KEY" != "" ]
      then KEY=`echo $KEY | tr [a-z] [A-Z]`
        if [ "$KEY1" = "0" ]
        then KEY1="KEY_$KEY";
        else KEY2="KEY_$KEY";
        fi
      fi
    done
    echo "  sendKey(${KEY1}, ${KEY2}, ${MODIFIERS});" >> $OUTFILE
  fi
done < $INFILE

echo "}" >> $OUTFILE

