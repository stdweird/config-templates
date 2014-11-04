use strict;
use warnings;

use Test::More;
use Test::Quattor::Template;
use Cwd;

my $u = Test::Quattor::Template->new(
    basepath => getcwd()."/../resources/metaconfig",
    service => 'testservice',
    version => '1.0',
    );

isa_ok($u, "Test::Quattor::Template", "Returns Test::Quattor::Template instance");

my ($tts, $mtts) = $u->gather_tt();
isa_ok($tts, "ARRAY", "gather_tt returns array reference to TTs");
isa_ok($mtts, "ARRAY", "gather_tt returns array reference to misplaced TTs");

is(scalar @$tts, 2, "Found 2 TT files.");
is_deeply($tts, ['testservice/1.0/main.tt', 'testservice/1.0/extra.tt'], 
          "Found TT files with location relative to basepath");

is(scalar @$mtts, 2, "Found 2 misplaced TT files.");


done_testing();
