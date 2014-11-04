# 
# Module to run the unittest of a single version 
# of a metaconfig template.
#

use strict;
use warnings;

package Test::Quattor::Template;

use File::Find;
use Test::More;

=pod

=head1 NAME

Test::Quattor::Template - Class for unittesting 
the TextRender templates.

=head1 DESCRIPTION

This class should be used whenever to unittest templates 
that can be processed via TextRender, in particular the 
ncm-metaconfig templates.

=head2 Public methods

=over

=item new

Returns a new object, accepts the following options

=over

=item service

The name of the service

=item version

If a specific version is to be tested (undef assumes no version)

=item basepath

Basepath that points to the templates (the service is a subdirectory of the basepath)

=back

=cut


sub new {
    my $that = shift;
    my $proto = ref($that) || $that;
    my $self = { @_ };

    # check if servicepath exists
    if (! -d $self->{basepath}) {
        $self->error("basepath $self->{basepath} exists");
        return;
    }
    if (! $self->{service}) {
        $self->error("service defined");
        return;
    }
    $self->{servicepath} = "$self->{basepath}/$self->{service}";
    if (! -d $self->{servicepath}) {
        $self->error("basepath $self->{servicepath} exists");
        return;
    }
    
    bless($self, $proto);
    return $self;
}

# info-type logger, calls diag
sub info 
{
    my ($self, @args) = @_;
    diag('INFO '.join('', @args));
}

# verbose-type logger, calls note
sub verbose 
{
    my ($self, @args) = @_;
    note('VERBOSE '.join('', @args));
}

# error logger, uses diag; also makes test fail
sub error
{
    my ($self, @args);
    my $msg = join('', @args);
    diag("ERROR: $msg");
    ok(0, $msg);
}

# Walk the servicepath and gather all TT files
# a TT file is a text file with an .tt extension
# which is not 'test' or 'pan' directory.
# Returns a refernce to list with relative TT paths
# (relative to the basepath)
sub gather_tt 
{
    my ($self) = @_;
    
    my @tts;
    my $wanted = sub { 
        my $name = $File::Find::name;
        $name =~ s/^$self->{basepath}\/+//;
        -T && m/\.(tt)$/ && ! m/(^|\/)(pan|test)\// && push(@tts, $name) 
    };
    find($wanted, $self->{servicepath});

    my $tts = scalar @tts;
    ok($tts, "found $tts TT files in servicepath $self->{servicepath}");
    $self->verbose("found ", scalar @tts, " TT files: ", join(", ", @tts));
    return \@tts;
}

# check the pan section, prepare proper directory structure to use the schema
#   at least one schema.pan must exist
# parse the tests
#   gather object templates
#   check for matching directory and or test file
#   compile the test objects
#   run them through TextRender, initialised like metaconfig
#   parse all tests


# Run the tests
sub test 
{
    my ($self) = @_;
    
    $self->gather_tt();

}

1;
