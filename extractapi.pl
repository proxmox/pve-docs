#!/usr/bin/perl -w

use strict;
use PVE::RESTHandler;
use PVE::API2;
use JSON;

sub cleanup_tree {
    my ($h) = @_;

    my $class = ref($h);
    return $h if !$class;

    if ($class eq 'ARRAY') {
	my $res = [];
	foreach my $el (@$h) {
	    push @$res, cleanup_tree($el);
	}
	return $res;
    } elsif ($class eq 'HASH') {
	my $res = {};
	foreach my $k (keys %$h) {
	    if (my $class = ref($h->{$k})) {
		if ($class eq 'CODE') {
		    next if $k eq 'completion';
		}
		$res->{$k} = cleanup_tree($h->{$k});
	    } else {
		$res->{$k} = $h->{$k};
	    }
	}
	return $res;
    } elsif ($class eq 'Regexp') {
	return "$h"; # return string representation
    } else {
	die "unknown class '$class'\n";
    }
}

my $tree = cleanup_tree(PVE::RESTHandler::api_dump('PVE::API2'));

print "var pveapi = " . to_json($tree, {pretty => 1}) . ";\n\n";

exit(0);
