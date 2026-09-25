package Nipe::Network::Install {
	use strict;
	use warnings;
	use Nipe::Component::Utils::Device;
	use Nipe::Component::Engine::Stop;

	our $VERSION = '1.0.0';

	sub new {
		my %device = Nipe::Component::Utils::Device->new();

		my %install = (
			debian   => 'apt-get update && apt-get install -y tor iptables curl ca-certificates',
			fedora   => 'dnf install -y tor iptables curl ca-certificates',
			centos   => 'yum -y install epel-release tor iptables curl ca-certificates',
			void     => 'xbps-install -y tor iptables curl ca-certificates',
			arch     => 'pacman -S --noconfirm tor iptables curl ca-certificates',
			opensuse => 'zypper install -y tor iptables curl ca-certificates',
		);

		my $distro = $device{distribution} // 'debian';
		my $cmd    = $install{$distro} // $install{debian};

		print "[*] Installing required system dependencies for $distro...\n";
		system $cmd;

		my $stop = Nipe::Component::Engine::Stop->new();

		print "[+] Dependencies successfully configured.\n";
		return 1;
	}
}

1;