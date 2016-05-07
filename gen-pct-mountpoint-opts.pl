#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;
use PVE::LXC::Config;

my $prop = PVE::LXC::Config->json_config_properties();

my $rootfs_prop = $prop->{rootfs};

my $mp_prop = $prop->{mp0};

my $typetext = PVE::PodParser::schema_get_type_text($rootfs_prop);

print "`rootfs`: `$typetext`\n\n";

$typetext = PVE::PodParser::schema_get_type_text($mp_prop);

print "`mp[n]`: `$typetext`\n\n";

print PVE::RESTHandler::dump_properties($mp_prop->{format});
