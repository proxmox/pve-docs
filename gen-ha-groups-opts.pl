#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;

use Data::Dumper;

use PVE::HA::Groups;

my $private = PVE::HA::Groups::private();
my $properies = $private->{propertyList};
delete $properies->{type};
delete $properies->{group};

print PVE::RESTHandler::dump_properties($properies);
