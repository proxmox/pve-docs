#!/usr/bin/perl

use strict;
use warnings;

use PVE::Firewall;
use PVE::RESTHandler;

my $prop = $PVE::Firewall::host_option_properties;

print PVE::RESTHandler::dump_properties($prop);
