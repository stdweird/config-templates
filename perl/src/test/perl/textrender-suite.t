use strict;
use warnings;

use Test::More;
use Test::Quattor::TextRender;

use Test::Quattor::TextRender::Suite;

use Test::Quattor::Panc qw(set_panc_includepath);

use Cwd qw(abs_path getcwd);

=pod

=head1 DESCRIPTION

Test the TextRender suite unittest.

=cut

# Prepare the namespacepath 
my $base = getcwd()."/src/test/resources";
my $tr = Test::Quattor::TextRender->new(
    basepath => $base,
    ttpath => 'metaconfig/testservice',
    panpath => 'metaconfig/testservice/pan',
    pannamespace => 'metaconfig/testservice',
);
$tr->make_namespace($tr->{panpath}, $tr->{pannamespace});
set_panc_includepath($tr->{namespacepath}, abs_path($ENV{QUATTOR_TEST_TEMPLATE_LIBRARY_CORE}));

diag("Start actual Suite tests");

my $st = Test::Quattor::TextRender::Suite->new(
    includepath => $base,
    testspath => "$base/metaconfig/testservice/1.0/tests",
    );

isa_ok($st, "Test::Quattor::TextRender::Suite", 
       "Returns Test::Quattor::TextRender::Suite instance for service");

my $regexps = $st->gather_regexp();
is_deeply($regexps, {
            'config' => ['config/base', 'config/value'],
            'simple' => ['simple'],
            'nopan' => ['nopan'],
            }, "Found regexps");

my $objs = $st->gather_profile();
is_deeply($objs, {
            'config'=>'config.pan', 
            'simple' => 'simple.pan',
            'nopan' => 'nopan.pan',
            }, "Found profiles");

# This is the test to run
$st->test();

done_testing();
