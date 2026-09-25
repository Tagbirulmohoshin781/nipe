use 5.030;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use JSON;
use Nipe::Component::Utils::Status;

# Test Status object creation and error safety
my $status = Nipe::Component::Utils::Status->new();
ok(defined $status, 'Status object produces defined output');
like($status, qr/(?:Status:|ERROR:)/, 'Output contains either status report or network diagnostic');

done_testing();
