package Nipe::Network::Restart {
    use strict;
    use warnings;
    use Nipe::Component::Engine::Stop;
    use Nipe::Component::Engine::Start;

    our $VERSION = '1.0.0';

    sub new {
        print "[*] Restarting Nipe routing and rebuilding Tor circuit...\n";
        my $stop = Nipe::Component::Engine::Stop->new();

        if ($stop) {
            sleep 1;
            my $start = Nipe::Component::Engine::Start->new();

            if ($start) {
                return 1;
            }
        }

        return 0;
    }
}

1;