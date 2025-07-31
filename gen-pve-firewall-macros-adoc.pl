#!/usr/bin/perl

use lib '.';
use strict;
use warnings;

use PVE::Firewall;

my ($pve_fw_parsed_macros, $pve_fw_macro_descr) = PVE::Firewall::get_macros();

#use Data::Dumper;
#print Dumper($pve_fw_macro_descr);
#print Dumper($pve_fw_parsed_macros);

foreach my $name (sort keys %$pve_fw_parsed_macros) {
    my $descr = $pve_fw_macro_descr->{$name};
    die "no description for macro '$name'" if !defined($descr);
    print "[horizontal]\n'$name':: $descr\n\n";

    print "[width=\"100%\",options=\"header\"]\n"
        . "|===========================================================\n"
        . "|Action|proto|dport|sport\n";

    my $rules = $pve_fw_parsed_macros->{$name};

    foreach my $rule (@$rules) {
        print "|$rule->{action}|";
        print(($rule->{proto} || '') . '|');
        print(($rule->{dport} || '') . '|');
        print(($rule->{sport} || '') . "\n");
    }

    print "|===========================================================\n";

    print "\n";
}
