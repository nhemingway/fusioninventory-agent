#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::Deep;
use Test::Exception;
use Test::MockModule;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Inventory;
use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Win32::Drives;

my %tests = (
    'winxp-sp3-x86' => [
        {
            CREATEDATE  => undef,
            DESCRIPTION => 'Unidad de disco de 3 1/2 pulgadas',
            FILESYSTEM  => undef,
            FREE        => undef,
            LABEL       => undef,
            LETTER      => 'A:',
            SERIAL      => undef,
            SYSTEMDRIVE => '',
            TOTAL       => undef,
            TYPE        => 'Removable Disk',
            VOLUMN      => undef
        },
        {
            CREATEDATE  => undef,
            DESCRIPTION => 'Disco fijo local',
            FILESYSTEM  => 'NTFS',
            FREE        => 72386,
            LABEL       => undef,
            LETTER      => 'C:',
            SERIAL      => 'D8637C61',
            SYSTEMDRIVE => '1',
            TOTAL       => 122879,
            TYPE        => 'Local Disk',
            VOLUMN      => undef
        },
        {
            CREATEDATE  => undef,
            DESCRIPTION => 'Disco CD-ROM',
            FILESYSTEM  => undef,
            FREE        => undef,
            LABEL       => undef,
            LETTER      => 'D:',
            SERIAL      => undef,
            SYSTEMDRIVE => '',
            TOTAL       => undef,
            TYPE        => 'Compact Disc',
            VOLUMN      => undef
        },
        {
            CREATEDATE  => undef,
            DESCRIPTION => "Conexi\x{f3}n de red",
            FILESYSTEM  => 'CIFS',
            FREE        => 28635,
            LABEL       => 'PROGRAMS',
            LETTER      => 'N:',
            SERIAL      => '788BBA22',
            SYSTEMDRIVE => '',
            TOTAL       => 40002,
            TYPE        => 'Network Drive',
            VOLUMN      => 'PROGRAMS'
        },
        {
            CREATEDATE  => undef,
            DESCRIPTION => "Conexi\x{f3}n de red",
            FILESYSTEM  => 'CIFS',
            FREE        => 1425771,
            LABEL       => 'softstore',
            LETTER      => 'S:',
            SERIAL      => 'EC43F0AF',
            SYSTEMDRIVE => '',
            TOTAL       => 2084723,
            TYPE        => 'Network Drive',
            VOLUMN      => 'softstore'
        },
        {
            CREATEDATE  => undef,
            DESCRIPTION => "Conexi\x{f3}n de red",
            FILESYSTEM  => 'CIFS',
            FREE        => 19882,
            LABEL       => 'DATOS',
            LETTER      => 'T:',
            SERIAL      => 'B4E6D71B',
            SYSTEMDRIVE => '',
            TOTAL       => 188151,
            TYPE        => 'Network Drive',
            VOLUMN      => 'DATOS'
        },
        {
            CREATEDATE  => undef,
            DESCRIPTION => "Conexi\x{f3}n de red",
            FILESYSTEM  => 'HGFS',
            FREE        => 133793,
            LABEL       => 'Shared Folders',
            LETTER      => 'Y:',
            SERIAL      => '00000064',
            SYSTEMDRIVE => '',
            TOTAL       => 251982,
            TYPE        => 'Network Drive',
            VOLUMN      => 'Shared Folders'
        },
        {
            CREATEDATE  => undef,
            DESCRIPTION => "Conexi\x{f3}n de red",
            FILESYSTEM  => 'CIFS',
            FREE        => 270299,
            LABEL       => 'SERVICIOS',
            LETTER      => 'Z:',
            SERIAL      => '02017820',
            SYSTEMDRIVE => '',
            TOTAL       => 1572864,
            TYPE        => 'Network Drive',
            VOLUMN      => 'SERVICIOS'
        }
    ],
    'win7-sp1-x64' => [
        {
            VOLUMN      => undef,
            TYPE        => 'Removable Disk',
            DESCRIPTION => '3 1/2 Inch Floppy Drive',
            LETTER      => 'A:',
            FREE        => undef,
            CREATEDATE  => undef,
            TOTAL       => undef,
            SERIAL      => undef,
            SYSTEMDRIVE => '',
            LABEL       => undef,
            FILESYSTEM  => undef
        },
        {
            LETTER      => 'C:',
            DESCRIPTION => 'Local Fixed Disk',
            VOLUMN      => undef,
            TYPE        => 'Local Disk',
            CREATEDATE  => undef,
            FREE        => 36531,
            SYSTEMDRIVE => '1',
            TOTAL       => 61337,
            SERIAL      => '905FA321',
            FILESYSTEM  => 'NTFS',
            LABEL       => undef
        },
        {
            TOTAL       => undef,
            SERIAL      => undef,
            SYSTEMDRIVE => '',
            LABEL       => undef,
            FILESYSTEM  => undef,
            TYPE        => 'Compact Disc',
            VOLUMN      => undef,
            LETTER      => 'D:',
            DESCRIPTION => 'CD-ROM Disc',
            FREE        => undef,
            CREATEDATE  => undef
        },
        {
            CREATEDATE  => undef,
            FREE        => 791200,
            LETTER      => 'Z:',
            DESCRIPTION => 'Network Connection',
            VOLUMN      => 'Shared Folders',
            TYPE        => 'Network Drive',
            FILESYSTEM  => 'HGFS',
            LABEL       => 'Shared Folders',
            SYSTEMDRIVE => '',
            TOTAL       => 953541,
            SERIAL      => '00000064'
        },
        {
            CREATEDATE  => undef,
            FREE        => 71,
            LETTER      => 'System reserved',
            DESCRIPTION => undef,
            VOLUMN      => 'System reserved',
            TYPE        => 'Local Disk',
            FILESYSTEM  => 'NTFS',
            LABEL       => 'System reserved',
            SYSTEMDRIVE => '',
            TOTAL       => 99,
            SERIAL      => '740976057'
        },
        {
            CREATEDATE  => undef,
            FREE        => 83,
            LETTER      => 'C:\\MountedPoint\Here\\',
            DESCRIPTION => undef,
            VOLUMN      => 'MountTest',
            TYPE        => 'Local Disk',
            FILESYSTEM  => 'NTFS',
            LABEL       => 'MountTest',
            SYSTEMDRIVE => '',
            TOTAL       => 96,
            SERIAL      => '-1032061577'
        }
    ],
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = FusionInventory::Agent::Inventory->new();

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Win32::Drives'
);

foreach my $test (sort keys %tests) {
    $module->mock(
        'getWMIObjects',
        mockGetWMIObjects($test)
    );

    my @drives = FusionInventory::Agent::Task::Inventory::Win32::Drives::_getDrives();
    cmp_deeply(
        \@drives,
        $tests{$test},
        "$test: parsing"
    );
    lives_ok {
        $inventory->addEntry(section => 'DRIVES', entry => $_)
            foreach @drives;
    } "$test: registering";
}
