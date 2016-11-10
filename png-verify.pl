#!/usr/bin/perl

use strict;
use warnings;

my $infile = shift ||
    die "no input file specified\n";

my $dpcm = 58; # expected

my $tmp = `identify -units PixelsPerCentimeter -format '%x x %y' $infile`;

die "got unexpected density '$tmp' (fix with png-cleanup.pl)\n"
    if $tmp ne "$dpcm x $dpcm";

exit 0;
