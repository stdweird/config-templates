#

use strict;
use warnings;

use Test::More;
use Test::Quattor::TextRender::Metaconfig;
use Cwd;

my $u = Test::Quattor::TextRender::Metaconfig->new(
    service => 'logstash',
    version => '1.2',
    )->test();

done_testing();
