#!/usr/bin/perl

use strict;
use warnings;

my $infile = shift ||
    die "no input file specified\n";

my $outfile = shift ||
    die "no outpu file specified\n";

# use the following to verify image attributes
# identify -verbose <filename>

# set DPI to 146, so that we can display 1024 pixels (page width)

my $dpi = 146;

system("convert -units PixelsPerInch $infile -density $dpi $outfile");

# identify should return the same value
# system("identify -units PixelsPerInch -format '%x x %y' $outfile");
