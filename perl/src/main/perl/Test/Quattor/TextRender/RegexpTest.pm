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

use Regexp::Assemble;
use CAF::TextRender;
use Readonly;

# Blocks are separated using this separator
Readonly my $BLOCK_SEPARATOR => qr{^-{3}$}m;
# Number of expected blocks
Readonly my $EXPECTED_BLOCKS => 3;

Readonly my $DEFAULT_FLAG_RENDERPATH => '/metaconfig';

Readonly::Hash my %DEFAULT_FLAGS => {
    multiline => 1,
    casesensitive => 1,
    ordered => 1,
};

# convert these flag names in respective regexp flags
Readonly::Hash my %FLAGS_REGEXP_MAP => {
    multiline => 'm',
    casesensitive => 'i', # actually this is caseinsensitive
    extended => 'x',
    singleline => 's',
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

=item includepath

The includepath for CAF::TextRender.

=back

=cut

sub _initialize {
    my ($self) = @_;

    $self->{flags} = { %DEFAULT_FLAGS };
    $self->{tests} = [];
    
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

    $self->parse_flags($blocks[1]);    

    $self->parse_tests($blocks[2]);    

}

# parse the description block, set the description attribute
# blocktxt is the 1st block of the regexptest file
sub parse_description
{
    my ($self, $blocktxt) = @_;
    
    my $description = $blocktxt;
    $description =~ s/\s+/ /g;
    $description =~ s/^\s+|\s+$//g;
    
    $self->{description} = $description;
    
}

# parse the flags block
#   regexp flags
#       (no)multiline / multiline=1/0 
#       singleline / singleline=1/0 (can coexist with multiline)
#       extended / extended=1/0
#       case(in)sensistive / casesensitive = 0/1
#   (un)ordered / ordered=0/1 : ordered matches
#   negate / negate = 0/1: Negate all regexps, none of the regexps can match
#       is an alias for COUNT 0 on every regtest (overwritten when COUNT is set for individual regexp)
#   quote / quote = 0/1: exact match of test block
#       multiline is logged and ignored
#       ordered is meaningless (and silently ignored)
#   location of module and contents settings:
#       metaconfigservice=/some/path 
#       renderpath=/some/path
#       other:
#           all starting with // are renderpath
#           all starting with / are metaconfigservice
#   DEFAULT
#       ordered=1
#       multiline=1
#       casesensitive=1
#       renderpath=/metaconfig
# blocktxt is the 2nd block of the regexptest file
sub parse_flags
{
    my ($self, $blocktxt)  =@_;

    foreach my $line (split("\n", $blocktxt)) {
        next if ($line =~ m/^\s*$/);
        if ($line =~ m/^\s*#+\s*(.*)\s*$/) {
            $self->verbose("flag commented: $1");
        } elsif ($line =~ m/^\s*(multiline|casesensitive|ordered|negate|quote|singleline|extended)(?:\s*=\s*(0|1))?\s*$/) {
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
    $self->{flags}->{renderpath} = $DEFAULT_FLAG_RENDERPATH if (! $self->{flags}->{renderpath} );
}

# Create the re flags from the flags
# Ignores all flags passed as arguments
# Returns string
sub make_re_flags 
{
    my ($self, @ignore) = @_;

    my @reflags;
    while (my ($flag, $reflag) = each %FLAGS_REGEXP_MAP) {
        my $val = $self->{flags}->{$flag};
        next if (! defined($val));
        next if (grep {$flag eq $_} @ignore);
        $val = $val ? 0 : 1 if ($flag eq 'casesensitive');
        push(@reflags, $reflag) if $val;
    }    

    return join("", sort @reflags);    
}

# parse the tests block
# If quote flag set: 
#   rendered text has to be exact match, incl EOF newline etc etc
# Else parse the tests line by line, one regexp per line:
#   starting with '\s*#{3} ' are comments
#   ending with '\s#{3}' are interpreted as options
#      COUNT \d+ : exact number of matches (use 0 to make sure a line doesn't match)
# blocktxt is the 3rd block of the regexptest file
sub parse_tests 
{
    my ($self, $blocktxt) = @_;
  
    if($self->{flags}->{quote}) {
        # TODO why would we ignore this? we can use \A/\B instead of ^/$
        $self->verbose("multiline set but ignored with quote flag") if $self->{flags}->{multiline};
            
        my $ra = Regexp::Assemble->new(flags => $self->make_re_flags('multiline'));
        $ra->add("^$blocktxt\$");
        my $test = { reg => $ra };
        $test->{count} = 0 if $self->{flags}->{negate};
        push(@{$self->{tests}}, $test);
        # return here to avoid extra indentation 
        return;
    }

    foreach my $line (split("\n", $blocktxt)) {
        next if ($line =~ m/^\s*$/);
        if ($line =~ m/^\s*#{3}+\s*(.*)\s*$/) {
            $self->verbose("regexptest test commented: $1");
            next;
        } 

        my $test = { reg => Regexp::Assemble->new(flags => $self->make_re_flags()) };

        $test->{count} = 0 if $self->{flags}->{negate};
        
        # parse any special options
        if ($line =~ m/^(.*)\s#{3}+\s(?:(?:COUNT\s(?<count>\d+)))\s*$/) {
            if(exists($+{count})) {
                $test->{count} = $+{count};
            }
            
            # redefine line 
            $line = $1;
        }

        # make regexp
        $test->{reg}->add($line);        
        
        # add test
        push(@{$self->{tests}}, $test);
    }
}

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

    $self->{rendertext} = $self->{trd}->get_text;
    
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
    my $rp = $self->{flags}->{renderpath};
    ok($self->{config}->elementExists($rp), "Renderpath $rp found");
    
    $self->render;

    # In case of failure, fail is in the ok message
    ok(defined($self->{rendertext}), "No renderfailure (fail: ".($self->{trd}->{fail} || "").")");
    
    # run the regexps over the text
    
}
