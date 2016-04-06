#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::Cluster;
use PVE::RESTHandler;

my $schema = PVE::Cluster::get_datacenter_schema();

print PVE::RESTHandler::dump_properties($schema->{properties});
