use strict;
use warnings;

use Test::More;
use Test::Quattor::TextRender;
use Cwd;

=pod

=head1 DESCRIPTION

Test the TT files location 

=head2 Direct TT path 

Using direct TT path

=cut

my $dt = Test::Quattor::TextRender->new(
    basepath => getcwd()."/../resources",
    ttpath => 'metaconfig/testservice',
    );

isa_ok($dt, "Test::Quattor::TextRender", "Returns Test::Quattor::TextRender instance for direct ttpath");

my ($tts, $mtts) = $dt->gather_tt();
isa_ok($tts, "ARRAY", "gather_tt returns array reference to TTs for direct ttpath");
isa_ok($mtts, "ARRAY", "gather_tt returns array reference to misplaced TTs for direct ttpath");

is(scalar @$tts, 2, "Found 2 TT files for direct ttpath");
is_deeply($tts, ['metaconfig/testservice/1.0/main.tt', 'metaconfig/testservice/1.0/extra.tt'], 
          "Found TT files with location relative to basepath for direct ttpath");

is(scalar @$mtts, 2, "Found 2 misplaced TT files for direct ttpath");


done_testing();
