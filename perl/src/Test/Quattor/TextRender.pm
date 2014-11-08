# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}

use strict;
use warnings;

package Test::Quattor::TextRender;

use File::Find;
use Test::More;

use base qw(Test::Quattor::Object);


=pod

=head1 NAME

Test::Quattor::TextRender - Class for unittesting 
the TextRender templates.

=head1 DESCRIPTION

This class should be used whenever to unittest templates 
that can be processed via TextRender. (For testing ncm-metaconfig 
templates looked at the derived Test::Quattor::TextRender::Metaconfig
class).

=head2 Public methods

=over

=item new

Returns a new object, accepts the following options

=over

=item basepath

Basepath that points to the templates.

=item ttpath

Path to the TT files. If undefined, C<basepath/service> is used. 
If the path is not absolute, search from basepath.  

=item expect

Expect is a hash reference to bypass some built-in tests 
in the test methods. 

Use with care, better to fix the actual problem. 
(No attempt is made to make this any userfriendly; 
main reason of existence is to unittest 
these test modules).

=over

=item misplacedtt

Array reference of misplaced TT files to pass the C<test_gather_tt> test method.

=back

=back

=cut


sub new {
    my $that = shift;
    my $proto = ref($that) || $that;
    my $self = { @_ };

    bless($self, $proto);

    $self->_initialize();
    
    # sanity checks
    
    ok(-d $self->{basepath}, "basepath $self->{basepath} exists");

    if ($self->{ttpath}) {
        if ($self->{ttpath} !~ m/^\//) {
            $self->verbose("Relative ttpath $self->{ttpath} found");
            $self->{ttpath} = "$self->{basepath}/$self->{ttpath}";
        }
        ok(-d $self->{ttpath}, "ttpath $self->{ttpath} exists");
    } else {
        $self->notok("Init without ttpath");
    }
    
    return $self;
}

=pod 

=head2 _initialize

Process more arguments 

=cut

sub _initialize
{
    # nothing to do here for Test::Quattor::TextRender
}


=pod 

=head2 gather_tt

Walk the C<ttpath> and gather all TT files
A TT file is a text file with an C<.tt> extension; 
they are considered 'misplaced' when they are 
in a 'test' or 'pan' directory.

Returns a reference to list with path 
(relative to the basepath) of TT and misplaced TT files.

=cut

sub gather_tt 
{
    my ($self) = @_;
    
    my @tts;
    my @misplaced_tts;
    
    my $relpath = $self->{basepath};
    
    my $wanted = sub {
        my $name = $File::Find::name;
        $name =~ s/^$relpath\/+//;
        if (-T && m/\.(tt)$/) {
            if ($name !~ m/(^|\/)(pan|tests)\//) {
                push(@tts, $name);    
            } else {
                push(@misplaced_tts, $name);
            }
        }
    };

    find($wanted, $self->{ttpath});

    return \@tts, \@misplaced_tts;
}

# check the pan section, prepare proper directory structure to use the schema
#   at least one schema.pan must exist
# parse the tests
#   gather object templates
#   check for matching directory and or test file
#   compile the test objects
#   run them through TextRender, initialised like metaconfig
#   parse all tests

# Make a metaconfig class to set directory etc etc. Or does it belong in metaconfig?


# Run tests based on gather_tt results; returns nothing.
sub test_gather_tt 
{
    my ($self) = @_;

    my ($tts, $misplaced_tts) = $self->gather_tt();

    my $ntts = scalar @$tts;    
    ok($tts, "found $ntts TT files in ttpath $self->{ttpath}");
    $self->verbose("found $ntts TT files: ", join(", ", @$tts));

    # Fail test and log any misplaced TTs
    my $msg= "misplaced TTs ".join(', ', @$misplaced_tts);
    if ($self->{expect}->{misplacedtt}) {
        is_deeply($misplaced_tts, $self->{expect}->{misplacedtt}, "Expected $msg");
    } else {
        is(scalar @$misplaced_tts, 0, "No $msg");
    }
}


1;
