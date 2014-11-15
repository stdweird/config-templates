use strict;
use warnings;

use Test::More;
use Test::MockModule;
use Test::Quattor::TextRender::RegexpTest;

use Test::Quattor::ProfileCache qw(prepare_profile_cache set_profile_cache_options);
use Cwd qw(abs_path getcwd);

use Readonly;

Readonly my $EXPECTED_RENDERTEXT => <<EOF;
default_simple
EXTRA more_simple

EOF


my $basepath = getcwd()."/src/test/resources";
my $testpath = "$basepath/metaconfig/testservice/1.0/tests";
set_profile_cache_options(resources => "$testpath/profiles");

my $cfg = prepare_profile_cache("$testpath/profiles/nopan.pan");

my $tr = Test::Quattor::TextRender::RegexpTest->new(
    config => $cfg,
    regexp => "$testpath/regexps/nopan",
    includepath => $basepath, # metaconfig is default relpath
);

$tr->parse();

is($tr->{description}, "Nopan", "Description found from block");

is_deeply($tr->{flags}, {
    casesensitive =>1,
    ordered => 1,
    singleline => 0,
    multiline => 1,
    renderpath => "/metaconfig2",
    }, "Flags found from block and defaults");

is_deeply($tr->{tests}, [
    {reg => qr{(?m:^default$)} },
    {reg => qr{(?m:^EXTRA more$)} },
    ], "Regexptests found");

my $srv = $tr->{config}->getElement($tr->{flags}->{renderpath})->getTree();
is_deeply($srv, {
    module => 'testservice/1.0/main',
    contents => {extra => 'more_simple', data => 'default_simple'},
    }, "Correct service subtree of config found");

$tr->render;
isa_ok($tr->{trd}, "CAF::TextRender", "CAF::TextRender instance saved"); 

ok(! exists($tr->{trd}->{fail}), "No failure (fail: ".($tr->{trd}->{fail} || "").")");

is($tr->{trd}->{module}, $srv->{module}, "Correct module set");


is($tr->{rendertext}, $EXPECTED_RENDERTEXT, "Text rendered correctly");

done_testing();
