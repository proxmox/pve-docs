#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::JSONSchema;
use PVE::RESTHandler;
use PVE::QemuServer;

my $prop = PVE::QemuServer::cloudinit_config_properties();

my $data = PVE::RESTHandler::dump_properties($prop, 'asciidoc', 'config');

$data =~ s/cloud-init: //g;

print $data;
