#!/usr/bin/perl
open(IN,"header.html");
while (<IN>) {
    print $_;
}
close IN;

open (IN,"gifts.list");
while (<IN>) {
  my @line = split(/;/);
  if ($line[0] > 0 ) {
    print "<option>".$line[1]."\n";
    }
}
close IN;

open(IN,"footer.html");
while (<IN>) {
    print $_;
}
close IN;
