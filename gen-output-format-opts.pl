#!/usr/bin/perl

use lib '.';
use strict;
use warnings;
use PVE::JSONSchema;
use PVE::RESTHandler;

my $prop = $PVE::RESTHandler::standard_output_options;

my $data = PVE::RESTHandler::dump_properties($prop, 'asciidoc', 'arg');

print $data;
