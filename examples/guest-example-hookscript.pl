#!/usr/bin/perl

# Example hook script for PVE guests (hookscript config option)
# You can set this via pct/qm with
# pct set <vmid> --hookscript <volume-id>
# qm set <vmid> --hookscript <volume-id>
# where <volume-id> has to be an executable file in the snippets folder
# of any storage with directories e.g.:
# qm set 100 --hookscript local:snippets/hookscript.pl

use strict;
use warnings;

print "GUEST HOOK: " . join(' ', @ARGV). "\n";

# First argument is the vmid

my $vmid = shift;

# Second argument is the phase

my $phase = shift;

if ($phase eq 'pre-start') {

    # First phase 'pre-start' will be executed before the guest
    # is started. Exiting with a code != 0 will abort the start

    print "$vmid is starting, doing preparations.\n";

    # print "preparations failed, aborting."
    # exit(1);

} elsif ($phase eq 'post-pci-prepare') {

    # Only called for virtual machines, not containers.
    #
    # This phase will be called for each pci device that is passed through,
    # after it was prepared by the Proxmox VE stack. In other words when either
    # * the mdev/vGPU was created
    # * the driver was changed to vfio-pci and the device was reset
    #
    # This phase can be useful to do additional preparation that the Proxmox VE
    # stack does not do, like setting vgpu_params for NVIDIA vGPU.
    #
    # This phase has 3 additional parameters (one optional) given via the environment:

    # the id from the config, e.g. 'hostpci0'
    my $hostpci_id = $ENV{PVE_HOOK_ID};

    # the pciid of the passed through device or the underlying device in case of an mdev/vGPU
    # e.g. '0000:01:00.0'
    my $pciid = $ENV{PVE_HOOK_PCIID};

    # the uuid of the mediated device if it was one,
    # e.g. '00000001-0000-0000-0000-000000008006'
    # This is not set if the pci device is not an mdev.
    my $mdev_uuid = $ENV{PVE_HOOK_MDEV_UUID};

    print "Prepared PCI device for $hostpci_id with pciid: $pciid.\n";
    print "It is a mediated device with UUID: $mdev_uuid\n" if $mdev_uuid;

} elsif ($phase eq 'post-start') {

    # Second phase 'post-start' will be executed after the guest
    # successfully started.

    print "$vmid started successfully.\n";

} elsif ($phase eq 'pre-stop') {

    # Third phase 'pre-stop' will be executed before stopping the guest
    # via the API. Will not be executed if the guest is stopped from
    # within e.g., with a 'poweroff'

    print "$vmid will be stopped.\n";

} elsif ($phase eq 'post-stop') {

    # Last phase 'post-stop' will be executed after the guest stopped.
    # This should even be executed in case the guest crashes or stopped
    # unexpectedly.

    print "$vmid stopped. Doing cleanup.\n";

} else {
    warn "got unknown phase '$phase'\n";
}

exit(0);
