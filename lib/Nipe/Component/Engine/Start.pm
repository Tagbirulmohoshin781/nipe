package Nipe::Component::Engine::Start {
	use strict;
	use warnings;
	use FindBin;
	use Nipe::Component::Utils::Device;
	use Nipe::Component::Utils::Status;
	use Nipe::Component::Engine::Stop;

	our $VERSION = '1.0.0';

	sub new {
		# Flush any existing rules and prepare network state
		my $stop          = Nipe::Component::Engine::Stop->new();
		my %device        = Nipe::Component::Utils::Device->new();
		my $dns_port      = '9061';
		my $transfer_port = '9051';
		my @table         = qw(nat filter);
		my $network       = '10.66.0.0/255.255.0.0';
		my $network_ipv6  = 'fd00::/8';
		my $start_tor     = 'systemctl start tor > /dev/null 2>&1';

		# Prepare tor runtime directories
		system 'mkdir -p /run/tor /var/run/tor /var/log/tor /var/lib/tor > /dev/null 2>&1';
		if ($device{username}) {
			system "chown -R $device{username} /run/tor /var/run/tor /var/log/tor /var/lib/tor > /dev/null 2>&1";
		}

		# Locate appropriate torrc config
		my $config_file = q{};
		my @search_dirs = (
			$FindBin::Bin ? "$FindBin::Bin/.configs" : q{},
			'.configs',
			'../.configs',
			'/etc/nipe',
		);
		for my $dir (@search_dirs) {
			next unless $dir;
			my $cand = "$dir/$device{distribution}-torrc";
			if (-f $cand) {
				$config_file = $cand;
				last;
			}
		}

		# Launch Tor with custom config if found, otherwise start Tor service
		if ($config_file && -f $config_file) {
			system "tor -f $config_file --RunAsDaemon 1 > /dev/null 2>&1";
		}

		if ($device{distribution} eq 'void') {
			$start_tor = 'sv start tor > /dev/null 2>&1';
		}
		elsif (-e '/etc/init.d/tor') {
			$start_tor = '/etc/init.d/tor start > /dev/null 2>&1';
		}

		system $start_tor;

		# Apply IPv4 iptables routing rules
		foreach my $table (@table) {
			my $target = 'ACCEPT';

			if ($table eq 'nat') {
				$target = 'RETURN';
			}

			system "iptables -t $table -F OUTPUT";
			system "iptables -t $table -A OUTPUT -m state --state ESTABLISHED -j $target";

			# Tor process owner bypass (supports numeric UID or username)
			my $owner_id = $device{uid} // $device{username};
			system "iptables -t $table -A OUTPUT -m owner --uid-owner $owner_id -j $target 2>/dev/null || iptables -t $table -A OUTPUT -m owner --uid $device{username} -j $target";

			my $match_dns_port = $dns_port;

			if ($table eq 'nat') {
				$target = "REDIRECT --to-ports $dns_port";
				$match_dns_port = '53';
			}

			system "iptables -t $table -A OUTPUT -p udp --dport $match_dns_port -j $target";
			system "iptables -t $table -A OUTPUT -p tcp --dport $match_dns_port -j $target";

			if ($table eq 'nat') {
				$target = "REDIRECT --to-ports $transfer_port";
			}

			system "iptables -t $table -A OUTPUT -d $network -p tcp -j $target";

			if ($table eq 'nat') {
				$target = 'RETURN';
			}

			system "iptables -t $table -A OUTPUT -d 127.0.0.1/8    -j $target";
			system "iptables -t $table -A OUTPUT -d 192.168.0.0/16 -j $target";
			system "iptables -t $table -A OUTPUT -d 172.16.0.0/12  -j $target";
			system "iptables -t $table -A OUTPUT -d 10.0.0.0/8     -j $target";

			if ($table eq 'nat') {
				$target = "REDIRECT --to-ports $transfer_port";
			}

			system "iptables -t $table -A OUTPUT -p tcp -j $target";
		}

		# Allow loopback interface explicitly
		system 'iptables -t filter -A OUTPUT -o lo -j ACCEPT';

		# Drop non-TCP leaks
		system 'iptables -t filter -A OUTPUT -p udp -j REJECT';
		system 'iptables -t filter -A OUTPUT -p icmp -j REJECT';

		# Apply IPv6 ip6tables routing rules if IPv6 is supported
		if (-d '/proc/sys/net/ipv6') {
			my $has_ip6_nat = (system('ip6tables -t nat -L -n >/dev/null 2>&1') == 0);

			foreach my $table (@table) {
				next if ($table eq 'nat' && !$has_ip6_nat);

				my $target = 'ACCEPT';

				if ($table eq 'nat') {
					$target = 'RETURN';
				}

				system "ip6tables -t $table -F OUTPUT";
				system "ip6tables -t $table -A OUTPUT -m state --state ESTABLISHED -j $target";

				my $owner_id = $device{uid} // $device{username};
				system "ip6tables -t $table -A OUTPUT -m owner --uid-owner $owner_id -j $target 2>/dev/null || ip6tables -t $table -A OUTPUT -m owner --uid $device{username} -j $target";

				my $match_dns_port = $dns_port;

				if ($table eq 'nat') {
					$target = "REDIRECT --to-ports $dns_port";
					$match_dns_port = '53';
				}

				system "ip6tables -t $table -A OUTPUT -p udp --dport $match_dns_port -j $target";
				system "ip6tables -t $table -A OUTPUT -p tcp --dport $match_dns_port -j $target";

				if ($table eq 'nat') {
					$target = "REDIRECT --to-ports $transfer_port";
				}

				system "ip6tables -t $table -A OUTPUT -d $network_ipv6 -p tcp -j $target";

				if ($table eq 'nat') {
					$target = 'RETURN';
				}

				system "ip6tables -t $table -A OUTPUT -d ::1/128      -j $target";
				system "ip6tables -t $table -A OUTPUT -d fc00::/7     -j $target";
				system "ip6tables -t $table -A OUTPUT -d fe80::/10    -j $target";

				if ($table eq 'nat') {
					$target = "REDIRECT --to-ports $transfer_port";
				}

				system "ip6tables -t $table -A OUTPUT -p tcp -j $target";
			}

			system 'ip6tables -t filter -A OUTPUT -o lo -j ACCEPT';
			system 'ip6tables -t filter -A OUTPUT -p udp -j REJECT';
			system 'ip6tables -t filter -A OUTPUT -p icmpv6 -j REJECT';
		}

		# Allow a brief moment for circuits to negotiate
		sleep 1;

		my $status = Nipe::Component::Utils::Status->new();

		if ($status =~ /true/sm) {
			print "\n[+] Nipe started successfully. All network traffic is routed through Tor.\n";
			return $status;
		}

		return $status;
	}
}

1;

