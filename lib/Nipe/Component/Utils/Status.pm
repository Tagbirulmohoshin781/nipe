package Nipe::Component::Utils::Status {
	use strict;
	use warnings;
	use JSON;
	use HTTP::Tiny;
	use Try::Tiny;

	our $VERSION = '1.0.0';

	sub new {
		my $client = HTTP::Tiny->new(
			timeout    => 8,
			verify_SSL => 1,
			agent      => 'Nipe/1.0.0 (Linux; Tor Gateway Engine)',
		);

		# Primary Tor project check API
		my $primary_api = 'https://check.torproject.org/api/ip';
		my $response;

		try {
			$response = $client->get($primary_api);
		}
		catch {
			# Primary call failed or timed out
		};

		if ($response && $response->{success} && $response->{status} == 200) {
			my $data;
			eval {
				$data = decode_json($response->{content});
			};

			if ($data && ref $data eq 'HASH') {
				my $ip     = $data->{'IP'} // 'Unknown';
				my $is_tor = $data->{'IsTor'} ? 'true' : 'false';
				my $state  = $data->{'IsTor'} ? '[+] Status: true (Tor Network Active)' : '[-] Status: false (Tor Network Inactive)';

				return "\n$state\n[+] Ip: $ip\n\n";
			}
		}

		# Fallback check via public IP API if Tor Check was unreachable
		my $fallback_api = 'https://api.ipify.org?format=json';
		my $fallback_resp;

		try {
			$fallback_resp = $client->get($fallback_api);
		}
		catch {
			# Fallback also unreachable
		};

		if ($fallback_resp && $fallback_resp->{success} && $fallback_resp->{status} == 200) {
			my $data;
			eval {
				$data = decode_json($fallback_resp->{content});
			};

			if ($data && ref $data eq 'HASH' && $data->{'ip'}) {
				return "\n[-] Status: false (Tor check failed, reachable via clearnet)\n[+] Ip: $data->{ip}\n\n";
			}
		}

		return "\n[!] ERROR: sorry, it was not possible to establish a connection to the server.\n[!] Verify internet connectivity or Tor circuit status.\n\n";
	}
}

1;

