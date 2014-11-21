# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}

use strict;
use warnings;

package Test::Quattor::TextRender::RegexpTest;

use Test::More;

use base qw(Test::Quattor::RegexpTest);

use CAF::TextRender;


=pod

=head1 NAME

Test::Quattor::TextRender::RegexpTest - Class to handle a single regexptest.

=head1 DESCRIPTION

This class parses and executes the tests as described in a single regexptest.

=head2 Public methods

=over

=item new

Returns a new object, accepts the following options

=over

=item regexp

The regexptest file.

=item config

The configuration instance to retreive the values from.

=item includepath

The includepath for CAF::TextRender.

=back

=cut

# Render the text using config and flags-renderpath
# Store the CAF::TextRender instance and the get_text result in attributes
sub render
{
    my ($self) = @_;

    my $srv = $self->{config}->getElement($self->{flags}->{renderpath})->getTree();

    # TODO how to keep this in sync with what metaconfig does? esp the options
    # TODO add log => $self; but then we need warn and debug in Test::Quattor::Object
    $self->{trd} = CAF::TextRender->new(
        $srv->{module},
        $srv->{contents},
        eol => 0,
        includepath => $self->{includepath},
        );

    $self->{text} = $self->{trd}->get_text;
    $self->verbose("Rendertext:\n$self->{rendertext}");

}


# Implement the preprocess method by rendering the text as defined in the flags
sub preprocess 
{
    my ($self) =@_;
    isa_ok($self->{config}, "EDG::WP4::CCM::Configuration", "config EDG::WP4::CCM::Configuration instance");

    # render the text
    my $rp = $self->{flags}->{renderpath};
    ok($self->{config}->elementExists($rp), "Renderpath $rp found");

    $self->render;

    # In case of failure, fail is in the ok message
    ok(defined($self->{text}), "No renderfailure (fail: ".($self->{trd}->{fail} || "").")");
}

1;

