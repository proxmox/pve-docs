#!/usr/bin/perl

use lib '.';
use strict;
use warnings;

use PVE::Firewall;
use PVE::RESTHandler;

my $prop = $PVE::Firewall::vm_option_properties;

print PVE::RESTHandler::dump_properties($prop);
