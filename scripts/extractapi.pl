#!/usr/bin/perl

use strict;
use warnings;

use PVE::RESTHandler;
use PVE::API2;
use JSON;

my $tree = PVE::RESTHandler::api_dump_remove_refs(PVE::RESTHandler::api_dump('PVE::API2'));

print "const apiSchema = " . to_json($tree, { pretty => 1, canonical => 1 }) . ";\n\n";

exit(0);
