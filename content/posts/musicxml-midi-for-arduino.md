---
author: cjd
date: "2010-02-15T00:47:49+00:00"
tags:
  - scripts
  - arduino
  - music
  - peggy-2
title: MusicXML/MIDI for Arduino
url: /blog/2010/02/15/musicxmlmidi-for-arduino/

---
For a recent project I wanted to add music.

Being that I am not musically talented in any way I figured the best way to do this was to generate the music from a midi file.

To help with this I wrote a converter that would take a MusicXML file and output an include file.

It simply reads the XML and outputs an array where each note is stored in two uint16 values - the first is the note name as a defined in pitches.h (ie NOTE\_C4), the second is the duration in milliseconds.Â  The entire array is stored in PROGMEM so as to not use up too much ram on the AVR.

The script is as follows (or download from [here](/files/arduino/convert_xml.pl))

``` perl
#!/usr/bin/perl
# Convert a single-channel musicxml file to include file for arduino
# Pass the xml filename on the commandline and a .h file will be generated
# with the same name (replacing .xml with .h)

# Needs XML::Mini perlmodule (libxml-mini-perl package in debian/ubuntu)
use XML::Mini::Document;
my $size = 0;

my $name = $ARGV[0];
$name =~ s/\.xml$//;
open(OUT, ">".$name.".h");
print OUT "PROGMEM prog_uint16_t ".$name."Tune[] = {\n";

my $xmldoc = XML::Mini::Document->new();
$xmldoc->fromFile($ARGV[0]);
my $xmlHash = $xmldoc->toHash();
my $measures = $xmlHash->{'score-partwise'}->{'part'}->{'measure'};
foreach my $measure (@$measures) {
  my $notes=$measure->{'note'};
  foreach (@$notes) {
    my $note = "";
    if ($_->{'pitch'}) {
      if (defined $_->{'accidental'}) {
        if ($_->{'accidental'} eq "sharp") {
          $_->{'pitch'}->{'step'}=$_->{'pitch'}->{'step'}."S";
        } elsif ($_->{'accidental'} eq "flat") {
          $_->{'pitch'}->{'step'} =~ tr/A-F/FA-E/;
          $_->{'pitch'}->{'step'}=$_->{'pitch'}->{'step'}."S";
        }
      }
      $note = "NOTE_".$_->{'pitch'}->{'step'}.$_->{'pitch'}->{'octave'};
    } else {
      $note = "NOTE_00";
    }
    my $duration = $_->{'duration'};
    print OUT $note.", ".$duration.", ";
    $size++;
  }
  print OUT "\n";
}
print OUT "};\n";
print OUT "byte ".$name."TuneSteps = ".$size.";\n";
print "total memory usage:".(($size*4)+1)." bytes\n";
close OUT;

```

To actually use this generated include file I created a function 'playMelody' which is called regularly during the running of a sketch.

Each time it runs it checks if it is time to play the next note, if so then it reads the next note from the array,calls 'tone' to play it and then sets a variable to say when the next note should be played.Â  If it is not yet time to play the next note then it quickly returns (there is not much latency added by calling the function so it's okay to call too often)

``` perl
boolean playMelody()
{
  boolean retVal=true;
  if (millis() > time) {
    int toneVal = 0;
    int duration = 0;
    if (tuneStep >= SmoothCriminalTuneSteps) {
      retVal=false;
      tuneStep=0;
    }
    toneVal=pgm_read_word_near(SmoothCriminalTune+(tuneStep*2));
    durationÂ =Â pgm_read_word_near(SmoothCriminalTune+(tuneStep*2)+1);
    tuneStep++;
    if (toneVal) tone(speakerPin,toneVal,duration*2);
    time=millis()+(duration*2)+5;
  }
  return retVal;
}

```

I have a sample sketch which uses this to play a short melody loop as [music.zip](/files/arduino/music.zip)
