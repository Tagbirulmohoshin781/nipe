use 5.030;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Nipe::Component::Engine::Stop;

ok(defined $Nipe::Component::Engine::Stop::VERSION, 'Stop module has defined VERSION');
ok(defined $Nipe::Component::Engine::Start::VERSION, 'Start module has defined VERSION');

done_testing();
