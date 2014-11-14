use strict;
use warnings;

use Test::More;
use Test::MockModule;
use Test::Quattor::TextRender::RegexpTest;

use Test::Quattor::ProfileCache qw(prepare_profile_cache set_profile_cache_options);
use Cwd qw(abs_path getcwd);

my $testpath = getcwd()."/src/test/resources/metaconfig/testservice/1.0/tests";
set_profile_cache_options(resources => "$testpath/profiles");

my $cfg = prepare_profile_cache("$testpath/profiles/nopan.pan");

my $tr = Test::Quattor::TextRender::RegexpTest->new(
    config => $cfg,
    regexp => "$testpath/regexps/nopan",
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

done_testing();
