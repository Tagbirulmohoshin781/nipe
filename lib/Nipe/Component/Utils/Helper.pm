package Nipe::Component::Utils::Helper {
	use strict;
	use warnings;

	our $VERSION = '1.0.0';

	sub new {
		return <<~'END_HELP';

    Nipe - An Engine to make Tor Network your default gateway
    ==========================================================

    Usage:
        perl nipe.pl <command> [options]

    Core Commands:
        Command       Description
        -------       -----------
        install       Install dependencies and system packages (tor, iptables)
        start         Start transparent routing through Tor network
        stop          Stop routing and restore standard direct connection
        restart       Restart the routing rules and rebuild Tor circuits
        status        Display current connection status and public IP
        help          Display this help documentation

    Options / Flags:
        -h, --help    Show help message
        -v, --version Show Nipe version information

    Examples:
        perl nipe.pl status
        sudo perl nipe.pl start
        sudo perl nipe.pl stop
        sudo perl nipe.pl restart

END_HELP
	}
}

1;