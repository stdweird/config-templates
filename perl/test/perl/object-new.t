use strict;
use warnings;

use Test::More;
use Test::Quattor::Object;

=pod

=head1 DESCRIPTION

Test the Test::Quattor::Object class

=cut

my $dt = Test::Quattor::Object->new(
    x => 'x',
    );

isa_ok($dt, "Test::Quattor::Object", "Returns Test::Quattor::Object instance");

is($dt->{x}, 'x', "Set attribute x");

ok($dt->can('info'), "Object instance has info method");
ok($dt->can('verbose'), "Object instance has verbose method");
ok($dt->can('error'), "Object instance has error method");

ok($dt->can('notok'), "Object instance has notok method");
ok($dt->can('gather_pan'), "Object instance has gather_pan method");

done_testing();
