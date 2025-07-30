#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;

use Data::Dumper;

use PVE::HA::Rules;

my $private = PVE::HA::Rules::private();
my $properties = $private->{propertyList};
delete $properties->{type};
delete $properties->{rule};

print PVE::RESTHandler::dump_properties($properties);
