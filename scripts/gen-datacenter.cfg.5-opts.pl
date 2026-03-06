#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::DataCenterConfig;
use PVE::RESTHandler;

my $schema = PVE::DataCenterConfig::get_datacenter_schema();

print PVE::RESTHandler::dump_properties($schema->{properties});
