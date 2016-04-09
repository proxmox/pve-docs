#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;
use PVE::QemuServer;

my $prop = PVE::QemuServer::json_config_properties();

print PVE::RESTHandler::dump_properties($prop);
