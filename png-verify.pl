#!/usr/bin/perl

use strict;
use warnings;

my $infile = shift ||
    die "no input file specified\n";

my $dpi = 146; # expected

my $tmp = `identify -units PixelsPerInch -format '%x x %y' $infile`;

die "got unexpected DPI density '$tmp' (fix with png-cleanup.pl)\n"
    if $tmp ne "$dpi x $dpi";

exit 0;
