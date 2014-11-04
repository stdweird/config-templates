#

use strict;
use warnings;

use Test::More;
use Test::Quattor::Template;
use Cwd;

my $u = Test::Quattor::Template->new(
    basepath => getcwd()."/../metaconfig",
    service => 'logstash',
    version => '1.2',
    )->test();

done_testing();
