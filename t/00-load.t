use 5.030;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More tests => 7;

BEGIN {
    use_ok('Nipe::Component::Utils::Helper')   or BAIL_OUT("Unable to load Helper");
    use_ok('Nipe::Component::Utils::Device')   or BAIL_OUT("Unable to load Device");
    use_ok('Nipe::Component::Utils::Status')   or BAIL_OUT("Unable to load Status");
    use_ok('Nipe::Component::Engine::Stop')    or BAIL_OUT("Unable to load Stop");
    use_ok('Nipe::Component::Engine::Start')   or BAIL_OUT("Unable to load Start");
    use_ok('Nipe::Network::Install')           or BAIL_OUT("Unable to load Install");
    use_ok('Nipe::Network::Restart')           or BAIL_OUT("Unable to load Restart");
}

diag("All Nipe modules compiled and loaded successfully.");
done_testing();
