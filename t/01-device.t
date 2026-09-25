use 5.030;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Nipe::Component::Utils::Device;

my %device = Nipe::Component::Utils::Device->new();

ok(exists $device{distribution}, 'Device returns distribution key');
ok(exists $device{username},     'Device returns username key');
ok(exists $device{uid},          'Device returns uid key');

like($device{distribution}, qr/^(?:debian|fedora|centos|arch|void|opensuse)$/, 'Distribution is a recognized OS family');
like($device{username}, qr/^(?:debian-tor|toranon|tor)$/, 'Username is a recognized Tor system user');

done_testing();
