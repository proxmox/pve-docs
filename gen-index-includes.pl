#!/usr/bin/perl

use strict;
use warnings;
use JSON;
use IO::File;
use Data::Dumper;

my $fh = IO::File->new("link-refs.json", "r") ||
    die "unable to open 'link-refs.json' - $!\n";

my $data_str = "";
while (<$fh>) { $data_str .= $_; }
my $fileinfo = decode_json($data_str);

my $cmd = shift;

die "missing command name" if !$cmd;
die "too many arguments" if scalar(@ARGV);


#print Dumper($fileinfo);

if ($cmd eq 'chapter-table') {
    print '[width="100%",options="header"]' . "\n";
    print "|====\n";
    print "|Title|Link\n";
    my $filelist = $fileinfo->{outfile}->{default};
    foreach my $sourcefile (sort keys %$filelist) {
	my $target = $filelist->{$sourcefile};
	next if $target eq 'pve-admin-guide.html';
	my $title = $fileinfo->{titles}->{default}->{$sourcefile} ||
	    die "not title for '$sourcefile'";
	print "|$title|link:$target\[\]\n";
    }
    print "|====\n";

} elsif ($cmd =~ m/^man([158])page-table$/) {
    my $section = $1;
    print '[width="100%",cols="5*d",options="header"]' . "\n";
    print "|====\n";
    print "|Name 3+|Title|Link\n";
    my $filelist = $fileinfo->{outfile}->{manvolnum};
    foreach my $manpage (sort keys %$filelist) {
	next if $section ne $fileinfo->{mansection}->{manvolnum}->{$manpage};
	my $mantitle = $fileinfo->{titles}->{manvolnum}->{$manpage} ||
	    die "not manual title for '$manpage'";
	my $title = $fileinfo->{titles}->{default}->{$manpage} ||
	    die "not title for '$manpage'";

	# hack - remove command name prefix from titles
	$title =~ s/^[a-z]+\s*-\s*//;
	
	my $target = $filelist->{$manpage};
	print "|$mantitle 3+|$title|link:$target.html\[$target\]\n\n";
    }  
    print "|====\n";
} else {
    die "unknown command '$cmd'\n";
}
