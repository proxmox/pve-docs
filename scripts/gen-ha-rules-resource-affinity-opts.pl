#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;

use Data::Dumper;

use PVE::HA::Rules;
use PVE::HA::Rules::ResourceAffinity;

my $private = PVE::HA::Rules::private();
my $resource_affinity_rule_props = PVE::HA::Rules::ResourceAffinity::properties();
my $properties = {
    resources => $private->{propertyList}->{resources},
    $resource_affinity_rule_props->%*,
};

print PVE::RESTHandler::dump_properties($properties);
