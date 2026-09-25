package Nipe::Component::Utils::Device {
	use strict;
	use warnings;
	use Try::Tiny;

	our $VERSION = '1.0.0';

	sub _read_os_release {
		my @paths = ('/etc/os-release', '/usr/lib/os-release');
		my %params;

		for my $path (@paths) {
			if (-e $path && -r $path) {
				if (open my $fh, '<', $path) {
					while (my $line = <$fh>) {
						chomp $line;
						# Match KEY=VALUE or KEY="VALUE"
						if ($line =~ /^\s*([A-Za-z0-9_]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^#\s]+))?/sm) {
							my $key = $1;
							my $val = $2 // $3 // $4 // q{};
							$params{$key} //= $val;
						}
					}
					close $fh;
					last if keys %params;
				}
			}
		}

		return \%params;
	}

	sub new {
		my $os_info   = _read_os_release();
		my $id_like   = $os_info->{'ID_LIKE'} // q{};
		my $id_distro = $os_info->{'ID'} // q{};

		my %device = (
			'username'     => 'debian-tor',
			'distribution' => 'debian',
			'uid'          => 'debian-tor'
		);

		my @distributions = (
			{
				pattern      => qr/fedora|rhel/ism,
				username     => 'toranon',
				distribution => 'fedora',
			},
			{
				pattern      => qr/centos|rocky|alma/ism,
				username     => 'tor',
				distribution => 'centos',
			},
			{
				pattern      => qr/arch|manjaro|endeavouros|artix/ism,
				username     => 'tor',
				distribution => 'arch',
			},
			{
				pattern      => qr/void/ism,
				username     => 'tor',
				distribution => 'void',
			},
			{
				pattern      => qr/suse|opensuse/ism,
				username     => 'tor',
				distribution => 'opensuse',
			},
			{
				pattern      => qr/debian|ubuntu|kali|parrot|mint|pop/ism,
				username     => 'debian-tor',
				distribution => 'debian',
			},
		);

		for my $distro (@distributions) {
			if (($id_like =~ $distro->{pattern}) || ($id_distro =~ $distro->{pattern})) {
				$device{username}     = $distro->{username};
				$device{distribution} = $distro->{distribution};
				last;
			}
		}

		# Attempt to resolve numeric UID if user exists
		my $uid = getpwnam($device{username});
		if (defined $uid) {
			$device{uid} = $uid;
		}
		else {
			$device{uid} = $device{username};
		}

		return %device;
	}
}

1;