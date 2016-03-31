#!/usr/bin/perl

use strict;
use warnings;

use PVE::RESTHandler;
use PVE::Firewall;

my $prop = {};
PVE::Firewall::add_rule_properties($prop);

my $skip = {
    action => 1,
    enable => 1,
    type => 1,
    digest => 1,
    macro => 1,
    pos => 1,
    comment => 1,
};

my $filterFn = sub {
    my ($k, $phash) = @_;

    return $skip->{$k} || 0;
};

print PVE::RESTHandler::dump_properties($prop, 'asciidoc', 'arg', $filterFn);
