package Nipe::Component::Engine::Stop {
	use strict;
	use warnings;
	use Nipe::Component::Utils::Device;

	our $VERSION = '1.0.0';

	sub new {
		my %device   = Nipe::Component::Utils::Device->new();
		my @table    = qw(nat filter);
		my $stop_tor = 'systemctl stop tor > /dev/null 2>&1';

		if ($device{distribution} eq 'void') {
			$stop_tor = 'sv stop tor > /dev/null 2>&1';
		}
		elsif (-e '/etc/init.d/tor') {
			$stop_tor = '/etc/init.d/tor stop > /dev/null 2>&1';
		}

		# Flush iptables and restore default ACCEPT policy
		foreach my $table (@table) {
			system "iptables -t $table -F OUTPUT 2>/dev/null";
			system "iptables -t $table -Z OUTPUT 2>/dev/null";

			if (-d '/proc/sys/net/ipv6') {
				system "ip6tables -t $table -F OUTPUT 2>/dev/null";
				system "ip6tables -t $table -Z OUTPUT 2>/dev/null";
			}
		}

		system 'iptables -t filter -P OUTPUT ACCEPT 2>/dev/null';
		if (-d '/proc/sys/net/ipv6') {
			system 'ip6tables -t filter -P OUTPUT ACCEPT 2>/dev/null';
		}

		# Stop Tor service
		system $stop_tor;

		# Terminate any standalone Tor daemon instances created by Nipe
		my @pid_files = ('/var/run/tor/tor.pid', '/run/tor/tor.pid');
		for my $pid_file (@pid_files) {
			if (-e $pid_file && -r $pid_file) {
				if (open my $fh, '<', $pid_file) {
					my $pid = <$fh>;
					close $fh;
					if ($pid && $pid =~ /^(\d+)$/) {
						kill 'TERM', $1;
					}
				}
				unlink $pid_file;
			}
		}

		print "\n[+] Nipe stopped. Tor routing disabled and original iptables rules reset.\n\n";
		return 1;
	}
}

1;