#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;
use PVE::QemuServer::CPUConfig;

my $prop = PVE::QemuServer::CPUConfig::add_cpu_json_properties({});

# cputype is given as section header and explained seperately
delete $prop->{cputype};

print PVE::RESTHandler::dump_properties($prop);
