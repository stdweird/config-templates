use strict;
use warnings;

use Test::More;
use Test::Quattor::TextRender::Suite;
use Cwd;

=pod

=head1 DESCRIPTION

Test the TextRender suite unittest.

=cut

my $st = Test::Quattor::TextRender::Suite->new(
    testspath => getcwd()."/../resources/metaconfig/testservice/1.0/tests",
    );

isa_ok($st, "Test::Quattor::TextRender::Suite", 
       "Returns Test::Quattor::TextRender::Suite instance for service");

my $regexps = $st->gather_regexp();
is_deeply($regexps, {
            'config' => ['config/base', 'config/value'],
            'simple' => ['simple'],
            }, "Found regexps");

my $objs = $st->gather_profile();
is_deeply($objs, {
            'config'=>'config.pan', 
            'simple' => 'simple.pan',
            }, "Found profiles");

# This is the test to run
$st->test();

done_testing();
