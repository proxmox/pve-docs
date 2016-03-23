#!/usr/bin/perl

use strict;
use warnings;
use PVE::RESTHandler;
use PVE::LXC::Config;

my $prop = PVE::LXC::Config->json_config_properties();

print PVE::RESTHandler::dump_properties($prop);
