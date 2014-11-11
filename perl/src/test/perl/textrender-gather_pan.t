use strict;
use warnings;

use Test::More;
use Test::Quattor::TextRender;
use Cwd;

=pod

=head1 DESCRIPTION

Test the pan files location and validity

=cut

my $dt = Test::Quattor::TextRender->new(
    basepath => getcwd()."/src/test/resources",
    ttpath => 'metaconfig/testservice',
    panpath => 'metaconfig/testservice/pan',
    pannamespace => 'metaconfig/testservice',
    );

isa_ok($dt, "Test::Quattor::TextRender", "Returns Test::Quattor::TextRender instance for panpath");

my ($pans, $ipans) = $dt->gather_pan($dt->{panpath}, $dt->{pannamespace});
isa_ok($pans, "HASH", "gather_pan returns hash reference to pan templates for panpath");
isa_ok($ipans, "ARRAY", "gather_pan returns array reference to invalid pan templates for panpath");

is(scalar keys %$pans, 3, "Found 3 pan templates for panpath");
is_deeply($pans, {'metaconfig/testservice/pan/schema.pan' => { type => 'declaration', expected => 'metaconfig/testservice/schema.pan'}, 
                  'metaconfig/testservice/pan/config.pan' => { type => 'unique', expected => 'metaconfig/testservice/config.pan'},
                  'metaconfig/testservice/pan/subtree/more.pan' => { type => 'structure', expected => 'metaconfig/testservice/subtree/more.pan'},
                 }, "Found pan templates with location relative to basepath for panpath");

is(scalar @$ipans, 3, "Found 3 invalid pan templates for panpath");

my $copies = $dt->make_namespace($dt->{panpath}, $dt->{pannamespace}, "target/test/newnamespace");
is(scalar @$copies, 3, "All files copied");


done_testing();
