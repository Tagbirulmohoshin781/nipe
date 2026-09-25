#!/usr/bin/env perl
use 5.030;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Try::Tiny;
use Nipe::Component::Engine::Stop;
use Nipe::Component::Engine::Start;
use Nipe::Network::Restart;
use Nipe::Component::Utils::Status;
use Nipe::Component::Utils::Helper;
use Nipe::Network::Install;
use English '-no_match_vars';

our $VERSION = '1.0.0';

sub main {
    my $argument = $ARGV[0] // q{};

    # Normalize flag arguments
    if ($argument eq '-h' || $argument eq '--help') {
        $argument = 'help';
    }
    elsif ($argument eq '-v' || $argument eq '--version' || $argument eq 'version') {
        print "Nipe version $VERSION\nAn engine to make Tor Network your default gateway.\n";
        return 1;
    }

    if ($argument) {
        my %privileged = (
            start   => 1,
            stop    => 1,
            restart => 1,
            install => 1,
        );

        if (exists $privileged{$argument} && $REAL_USER_ID != 0) {
            die "[!] Nipe must be run as root for '$argument'. Try: sudo perl nipe.pl $argument\n";
        }

        my $commands = {
            stop    => 'Nipe::Component::Engine::Stop',
            start   => 'Nipe::Component::Engine::Start',
            status  => 'Nipe::Component::Utils::Status',
            restart => 'Nipe::Network::Restart',
            install => 'Nipe::Network::Install',
            help    => 'Nipe::Component::Utils::Helper'
        };

        if (!exists $commands->{$argument}) {
            print "\n[!] ERROR: Unknown command '$argument'.\n\n";
            print Nipe::Component::Utils::Helper->new();
            return 0;
        }

        try {
            my $exec = $commands->{$argument}->new();

            if ($exec && $exec ne '1') {
                print $exec;
            }
        }
        catch {
            my $err = $_ // 'unknown error';
            print "\n[!] ERROR: this command could not be run: $err\n\n";
        };

        return 1;
    }

    return print Nipe::Component::Utils::Helper->new();
}

main();

