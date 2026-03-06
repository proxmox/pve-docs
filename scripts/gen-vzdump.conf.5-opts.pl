#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;
use PVE::VZDump::Common;

my $prop = PVE::VZDump::Common::json_config_properties();
my $skip = {
    all => 1,
    exclude => 1,
    vmid => 1,
    node => 1,
    quiet => 1,
    size => 1,
    stop => 1,
};

my $filterFn = sub {
    my ($k, $phash) = @_;

    return $skip->{$k} || 0;
};

print PVE::RESTHandler::dump_properties($prop, 'asciidoc', 'config', $filterFn);
