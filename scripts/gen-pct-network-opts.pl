#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::JSONSchema;
use PVE::RESTHandler;
use PVE::LXC::Config;

my $prop = PVE::LXC::Config->json_config_properties();

my $phash = $prop->{net0};

my $format = $phash->{format};

my $typetext = PVE::JSONSchema::schema_get_type_text($phash);

print "`net[n]`: `$typetext` ::\n\n";
print $phash->{description} . "\n\n";

print PVE::RESTHandler::dump_properties($format, 'asciidoc', 'config-sub');
