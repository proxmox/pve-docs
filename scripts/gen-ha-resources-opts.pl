#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;

use Data::Dumper;

use PVE::HA::Resources;

my $private = PVE::HA::Resources::private();
my $properies = $private->{propertyList};
delete $properies->{type};
delete $properies->{sid};

print PVE::RESTHandler::dump_properties($properies);
