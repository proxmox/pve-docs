#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

my $installer_images = {
    'pve-grub-menu.png' => 1,
    'pve-installation.png' => 1,
    'pve-select-location.png' => 1,
    'pve-select-target-disk.png' => 1,
    'pve-set-password.png' => 1,
    'pve-setup-network.png' => 1,
};

my $infile = shift
    || die "no input file specified\n";

my $basename = basename($infile);

my $dpcm = $installer_images->{$basename} ? 72 : 58; # expected

my $tmp = `identify -units PixelsPerCentimeter -format '%x x %y' $infile`;

die "$infile: got unexpected density '$tmp' (fix with png-cleanup.pl)\n"
    if $tmp ne "$dpcm x $dpcm";

exit 0;
