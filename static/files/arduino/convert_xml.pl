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
