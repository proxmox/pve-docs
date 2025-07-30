#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;

use Data::Dumper;

use PVE::HA::Rules;
use PVE::HA::Rules::NodeAffinity;

my $private = PVE::HA::Rules::private();
my $node_affinity_rule_props = PVE::HA::Rules::NodeAffinity::properties();
my $properties = {
    resources => $private->{propertyList}->{resources},
    $node_affinity_rule_props->%*,
};

print PVE::RESTHandler::dump_properties($properties);
