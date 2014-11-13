# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}

use strict;
use warnings;

package Test::Quattor::TextRender::RegexpTest;

use Test::More;

use base qw(Test::Quattor::Object);

use EDG::WP4::CCM::Element qw(escape);

use Readonly;

# Blocks are separated using this separator
Readonly my $BLOCK_SEPARATOR => qr{^-{3}$}m;
# Number of expected blocks
Readonly my $EXPECTED_BLOCKS => 3;

Readonly::Hash my %DEFAULT_FLAGS => {
    multiline => 1,
    ordered => 1,
};


Readonly my $METACONFIG_SERVICES => "/software/components/metaconfig/services/";

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

=back

=cut

sub _initialize {
    my ($self) = @_;

    $self->{flags} = { %DEFAULT_FLAGS };
    
    return $self;
}

=pod

=head2 parse

Parse the regexp file in 3 sections: description, flags and tests. 

Each section is converted in an instance attribute named 'description',
 'flags' and 'tests'.

=cut

sub parse
{
    my ($self) = @_;    
    
    # cut textfile in 3 blocks
    open REG, $self->{regexp};
    my @blocks = split($BLOCK_SEPARATOR, join("", <REG>));
    close REG;
    
    is(scalar @blocks, $EXPECTED_BLOCKS, "Expected number of blocks");

    $self->parse_description($blocks[0]);    

}

# parse the description block, set the description attribute
sub parse_description
{
    my ($self, $blocktxt)  =@_;
    
    my $description = $blocktxt;
    $description =~ s/\s+/ /g;
    chomp($description);
    
    $self->{description} = $description;
    
}

# parse the flags
#   (no)multiline / multiline=1/0
#   case(in)sensistive / casesensitive = 0/1
#   metaconfigservice=/path 
#   renderpath=/some/path
#   (un)ordered / ordered=0/1 : ordered matches
#   negate = 0/1: Negate all regexps (none of the regexps can match) (not applicable when COUNT is set for individual regexp)
#   other:
#       all starting with // are renderpath
#       all starting with / are metaconfigservice

sub parse_flags
{
    my ($self, $blocktxt)  =@_;

    foreach my $line (split("\n", $blocktxt)) {
        if ($line =~ m/^\s*#+\s*(.*)\s*$/) {
            note("flag commented: $1");
        } elsif ($line =~ m/^\s*(multiline|casesensitive|ordered|negate)(?:\s*=\s*(0|1))?\s*$/) {
            $self->{flags}->{$1} = defined($2) ? $2 : 1;
        } elsif ($line =~ m/^\s*(?:no(?<s>multiline)(?<t>))|(?:(?<s>case)in(?<t>sensitive))|(?:un(?<s>ordered)(?<t>))\s*$/) {
            # yeah, not so pretty...
            $self->{flags}->{"$+{s}$+{t}"} = 0;
        } elsif ($line =~ m/^\s*(metaconfigservice|renderpath)\s*=\s*(\S+)\s*$/) {
            $self->{flags}->{$1} = $2;
        } elsif ($line =~ m/^\s*(?<r>\/)?(?<path>\/\S*)\s*$/) {
            $self->{flags}->{$+{r}? 'renderpath' : 'metaconfigservice'} = $+{path};
        } else {
            $self->notok("Unallowed flag $line");
        }
    }
    
    if(exists($self->{flags}->{metaconfigservice})) {
        # remove the metaconfigservice
        my $ms = delete $self->{flags}->{metaconfigservice};
        if(exists($self->{flags}->{renderpath})) {
            $self->notok("Both renderpath and metaconfigservice flags defined. Keeping renderpath");
        } else {
            $self->{flags}->{renderpath} = $METACONFIG_SERVICES.escape($ms);
        }
    }
}

# run tests
#   run the tests
#   2 modes: 
#       unordered: regexps can be matched anywhere
#       ordered: regexps can be matched in text following previous match
#       impl: run everything unordered, keep track of match index
#           for ordered, verify the indexes
#           also for count? only count from previous match


=pod

=head2 test

Perform the tests as defined in the flags and specified in the 'tests' section

=cut

sub test
{
    my ($self) = @_;    

    ok(-f $self->{regexp}, "Regexp file $self->{regexp} found.");

    isa_ok($self->{config}, "EDG::WP4::CCM::Configuration", "config EDG::WP4::CCM::Configuration instance");


    $self->parse;

    # render the text
    # run the regexps over the text
    
}
