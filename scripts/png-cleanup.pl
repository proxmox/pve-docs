#!/usr/bin/perl

use strict;
use warnings;

my $infile = shift
    || die "no input file specified\n";

my $outfile = shift
    || die "no outpu file specified\n";

# use the following to verify image attributes
# identify -verbose <filename>

# set PixelsPerCentimeter to 58, so that we can display 1024
# pixels (page width)

my $dpcm = 58;

system("convert -units PixelsPerCentimeter $infile -density $dpcm $outfile");

# identify should return the same value
# system("identify -units PixelsPerCentimeter -format '%x x %y' $outfile");
