# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}

use strict;
use warnings;

package Test::Quattor::TextRender::Metaconfig;

use Test::More;
use Cwd;

use base qw(Test::Quattor::TextRender);


=pod

=head1 NAME

Test::Quattor::TextRender::Metaconfig - Class for unittesting 
the ncm-metaconfig templates.

=head1 DESCRIPTION

This class should be used to unittest ncm-metaconfig 
templates.

To be used as

    my $u = Test::Quattor::TextRender::Metaconfig->new(
        service => 'logstash',
        version => '1.2',
        )->test();

=head2 Public methods

=over

=item new

Returns a new object, basepath is the default location
for metaconfig-unittests.

Accepts the following options

=over

=item service

The name of the service (the service is a subdirectory of the basepath).

=item version

If a specific version is to be tested (undef assumes no version).

=back

=cut


sub _initialize {
    my ($self) = @_;

    if(! $self->{basepath}) {    
        # TODO determine final path in tests
        $self->{basepath} = getcwd()."/../metaconfig";
    }

    ok($self->{service}, "service $self->{service} defined for ttpath");

    # derive ttpath from service
    $self->{ttpath} = "$self->{basepath}/$self->{service}";

    $self->{panpath} = "$self->{ttpath}/pan";
    $self->{pannamespace} = "metaconfig/$self->{service}";

    $self->SUPER::_initialize();

}


=pod

=head2 test

Run all unittests to validate a set of templates. 

=cut

sub test 
{
    my ($self) = @_;
    
    $self->test_gather_tt();
    $self->test_gather_pan();
    
    # Set panc include dirs
    
}

1;
