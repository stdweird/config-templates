# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}

use strict;
use warnings;

package Test::Quattor::TextRender;

use File::Basename;
use File::Find;
use Cwd 'abs_path';
use Test::More;

use Template::Parser;

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

Path to the TT files.  
If the path is not absolute, search from basepath.  

=item panpath

Path to the (mandatory) pan files.  
If the path is not absolute, search from basepath.  

=item pannamespace

Namespace for the (mandatory) pan files.  

=item expect

Expect is a hash reference to bypass some built-in tests 
in the test methods. 

Use with care, better to fix the actual problem. 
(No attempt is made to make this any userfriendly; 
main reason of existence is to unittest 
these test modules).

=over

=item invalidtt

Array reference of invalid TT files to pass the C<test_gather_tt> test method.

=item invalidpan

Array reference of invalid pan templates to pass the C<test_gather_pan> test method.

=back

=back

=cut


sub _initialize
{
    my ($self) = @_;
    $self->_sanitize();
}

# sanity checks, validates some internals, return nothing
sub _sanitize
{
    my ($self) = @_;
    $self->{basepath} = abs_path($self->{basepath});
    ok(-d $self->{basepath}, "basepath $self->{basepath} exists");

    if ($self->{ttpath}) {
        if ($self->{ttpath} !~ m/^\//) {
            $self->verbose("Relative ttpath $self->{ttpath} found");
            $self->{ttpath} = "$self->{basepath}/$self->{ttpath}";
        }
        $self->{ttpath} = abs_path($self->{ttpath});
        ok(-d $self->{ttpath}, "ttpath $self->{ttpath} exists");
    } else {
        $self->notok("Init without ttpath");
    }

    if ($self->{panpath}) {
        if ($self->{panpath} !~ m/^\//) {
            $self->verbose("Relative panpath $self->{panpath} found");
            $self->{panpath} = "$self->{basepath}/$self->{panpath}";
        }
        $self->{panpath} = abs_path($self->{panpath});
        ok(-d $self->{panpath}, "Init panpath $self->{panpath} exists");
    } else {
        $self->notok("Init without panpath");
    }

    ok($self->{pannamespace}, "Using init pannamespace $self->{pannamespace}");
}

=pod 

=head2 gather_tt

Walk the C<ttpath> and gather all TT files
A TT file is a text file with an C<.tt> extension; 
they are considered 'invalid' when they are 
in a 'test' or 'pan' directory or 
when they fail syntax validation.

Returns an arrayreference with path 
(relative to the basepath) of TT and invalid TT files.

=cut

sub gather_tt 
{
    my ($self) = @_;
    
    my @tts;
    my @invalid_tts;
    
    my $relpath = $self->{basepath};
    
    my $wanted = sub {
        my $name = $File::Find::name;
        $name =~ s/^$relpath\/+//;
        if (-T && m/\.(tt)$/) {
            if ($name !~ m/(^|\/)(pan|tests)\//) {
                my $tp=Template::Parser->new({});
                open TT, $_;
                if($tp->parse(join( "", <TT>))) {
                    push(@tts, $name);
                } else {
                    $self->verbose("failed syntax validation TT $name with ".$tp->error());
                    push(@invalid_tts, $name);
                }
                close TT;
            } else {
                push(@invalid_tts, $name);
            }
        }
    };

    find($wanted, $self->{ttpath});

    return \@tts, \@invalid_tts;
}

=pod

=head2 test_gather_tt

Run tests based on gather_tt results; returns nothing.

=cut

sub test_gather_tt 
{
    my ($self) = @_;

    my ($tts, $invalid_tts) = $self->gather_tt();

    my $ntts = scalar @$tts;    
    ok($tts, "found $ntts TT files in ttpath $self->{ttpath}");
    $self->verbose("found $ntts TT files: ", join(", ", @$tts));

    # Fail test and log any invalid TTs
    my $msg= "invalid TTs ".join(', ', @$invalid_tts);
    if ($self->{expect}->{invalidtt}) {
        is_deeply($invalid_tts, $self->{expect}->{invalidtt}, "Expected $msg");
    } else {
        is(scalar @$invalid_tts, 0, "No $msg");
    }
}

=pod

=head2 gather_pan

Same as Test::Quattor::Object C<gather_pan>, but with <relpath> set 
to the instance 'basepath'. (With C<panpath> and C<pannamespace> as arguments)

=cut

sub gather_pan
{
    my ($self, $panpath, $pannamespace) = @_;
    return $self->SUPER::gather_pan($self->{basepath}, $panpath, $pannamespace);    
}

=pod

=head2 test_gather_pan

Run tests based on gather_pan results; returns nothing.

(C<panpath> and C<pannamespace> can be passed as arguments to 
override the instance values).

=cut

sub test_gather_pan
{
    my ($self, $panpath, $pannamespace) = @_;

    $panpath = $self->{panpath} if ! defined($panpath);
    $pannamespace = $self->{pannamespace} if ! defined($pannamespace);

    my ($pans, $invalid_pans) = $self->gather_pan($panpath, $pannamespace);

    my $npans = scalar keys %$pans;    
    ok($pans, "found $npans pan templates in panpath $panpath");
    $self->verbose("found $npans pan templates: ", join(", ", keys %$pans));

    # Fail test and log any invalid pan templates
    my $msg= "invalid pan templates ".join(', ', @$invalid_pans);
    if ($self->{expect}->{invalidpan}) {
        is_deeply($invalid_pans, $self->{expect}->{invalidpan}, "Expected $msg");
    } else {
        is(scalar @$invalid_pans, 0, "No $msg");
    }

    # there must be one declaration template called schema.pan in the panpath
    my $schema = "$panpath/schema.pan";
    $schema =~ s/^$self->{basepath}\/+//;
    is($pans->{$schema}, "declaration", "Found schema $schema");

    # there can be no object templates
    while (my ($pan, $type) = each %$pans) {
        $self->notok("No object template $pan found.") if ($type eq 'object');
    }

}



# parse the tests
#   gather object templates
#   check for matching directory and or test file
#   compile the test objects
#   run them through CAF::TextRender, initialised like metaconfig?
#   parse all tests

# Parse/validate the tests
#  return instances for each subtest

# Foreach test
#   search object templates
#   compile them
#   Gather all subtest instances
#   Run over all subtests

1;
