use strict;
use warnings;

use Test::More;
use Test::Quattor::Template;
use Cwd;

=pod

=head1 DESCRIPTION

Test the TT files location 

=head2 Using service

Locate the TT files via basepath and service (e.g. for metaconfig)

=cut

my $st = Test::Quattor::Template->new(
    basepath => getcwd()."/../resources/metaconfig",
    service => 'testservice',
    version => '1.0',
    );

isa_ok($st, "Test::Quattor::Template", "Returns Test::Quattor::Template instance for service");

my ($tts, $mtts) = $st->gather_tt();
isa_ok($tts, "ARRAY", "gather_tt returns array reference to TTs for service");
isa_ok($mtts, "ARRAY", "gather_tt returns array reference to misplaced TTs for service");

is(scalar @$tts, 2, "Found 2 TT files for service");
is_deeply($tts, ['testservice/1.0/main.tt', 'testservice/1.0/extra.tt'], 
          "Found TT files with location relative to basepath for service");

is(scalar @$mtts, 2, "Found 2 misplaced TT files for service");

=pod 

=head2 Direct TT path 

Using direct TT path

=cut

my $dt = Test::Quattor::Template->new(
    basepath => getcwd()."/../resources",
    ttpath => 'metaconfig/testservice',
    version => '1.0',
    );

isa_ok($dt, "Test::Quattor::Template", "Returns Test::Quattor::Template instance for direct ttpath");

($tts, $mtts) = $dt->gather_tt();
isa_ok($tts, "ARRAY", "gather_tt returns array reference to TTs for direct ttpath");
isa_ok($mtts, "ARRAY", "gather_tt returns array reference to misplaced TTs for direct ttpath");

is(scalar @$tts, 2, "Found 2 TT files for direct ttpath");
is_deeply($tts, ['metaconfig/testservice/1.0/main.tt', 'metaconfig/testservice/1.0/extra.tt'], 
          "Found TT files with location relative to basepath for direct ttpath");

is(scalar @$mtts, 2, "Found 2 misplaced TT files for direct ttpath");


done_testing();
