#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::RESTHandler;
use PVE::LXC::Config;
use PVE::JSONSchema;

my $prop = PVE::LXC::Config->json_config_properties();

my $rootfs_prop = $prop->{rootfs};

my $mp_prop = $prop->{mp0};

my $typetext = PVE::JSONSchema::schema_get_type_text($rootfs_prop);

print "`rootfs`: `$typetext` ::\n\n";

print $rootfs_prop->{description} . " See below for a detailed description of all options.\n\n";

$typetext = PVE::JSONSchema::schema_get_type_text($mp_prop);

print "`mp[n]`: `$typetext` ::\n\n";
print $mp_prop->{description} . "\n\n";

print PVE::RESTHandler::dump_properties($mp_prop->{format}, 'asciidoc', 'config-sub');
