use strict;
use warnings;

use Test::More;
use Test::Quattor::Object;
use Cwd qw(abs_path getcwd);

=pod

=head1 DESCRIPTION

Test the Test::Quattor::Object class gather_pan method

=cut

my $dt = Test::Quattor::Object->new();

isa_ok($dt, "Test::Quattor::Object", "Returns Test::Quattor::Object instance");

# These are the textrender gather_pan tests.

my $basepath = abs_path(getcwd()."/../resources");
my $panpath = "$basepath/metaconfig/testservice/pan";
my $pannamespace = "metaconfig/testservice";

my ($pans, $ipans) = $dt->gather_pan($basepath, $panpath, $pannamespace);
isa_ok($pans, "HASH", "gather_pan returns hash reference to pan templates for panpath");
isa_ok($ipans, "ARRAY", "gather_pan returns array reference to invalid pan templates for panpath");

is(scalar keys %$pans, 3, "Found 2 pan templates for panpath");
is_deeply($pans, {'metaconfig/testservice/pan/schema.pan' => 'declaration', 
                  'metaconfig/testservice/pan/config.pan' => 'unique',
                  'metaconfig/testservice/pan/subtree/more.pan' => 'structure',
                 }, 
          "Found pan templates with location relative to basepath for panpath");

is(scalar @$ipans, 3, "Found 3 invalid pan templates for panpath");



done_testing();
