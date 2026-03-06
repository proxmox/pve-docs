#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;
use PVE::QemuServer;

my $prop = PVE::QemuServer::json_config_properties();

# cdrom is just an alias, so we do not want to print details
delete $prop->{cdrom}->{format};

print PVE::RESTHandler::dump_properties($prop);
