use 5.030;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Nipe::Component::Utils::Helper;

my $help = Nipe::Component::Utils::Helper->new();

ok(defined $help, 'Helper returns defined content');
like($help, qr/Nipe/i,     'Help mentions Nipe');
like($help, qr/install/i,  'Help documents install command');
like($help, qr/start/i,    'Help documents start command');
like($help, qr/stop/i,     'Help documents stop command');
like($help, qr/restart/i,  'Help documents restart command');
like($help, qr/status/i,   'Help documents status command');
like($help, qr/--help/i,   'Help documents --help option');
like($help, qr/--version/i,'Help documents --version option');

done_testing();
