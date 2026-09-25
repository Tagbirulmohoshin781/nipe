use 5.030;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;

# Test script existence and permissions
my $script = "$FindBin::Bin/../nipe.pl";
ok(-f $script, 'nipe.pl script file exists');
ok(-r $script, 'nipe.pl is readable');

# Test file content properties
open my $fh, '<', $script or die "Cannot open $script: $!";
my $content = do { local $/; <$fh> };
close $fh;

like($content, qr/our \$VERSION = '1\.0\.0'/, 'nipe.pl has version 1.0.0');
like($content, qr/use FindBin/,                'nipe.pl uses FindBin for portability');
like($content, qr/sub main/,                   'nipe.pl defines main routine');

done_testing();
