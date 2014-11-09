# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}

use strict;
use warnings;

package Test::Quattor::Object;

our @ISA;
use Test::More;

sub new {
    my $that = shift;
    my $proto = ref($that) || $that;
    my $self = { @_ };

    bless($self, $proto);

    $self->_initialize();
    
    return $self;
}

sub _initialize
{
    # nothing to do here
}
    
# info-type logger, calls diag
sub info 
{
    my ($self, @args) = @_;
    my $msg = join('', @args);
    diag("INFO $msg");
    return $msg;
}

# verbose-type logger, calls note
sub verbose 
{
    my ($self, @args) = @_;
    my $msg = join('', @args);
    note("VERBOSE $msg");
    return $msg;
}   

# error logger, uses diag
sub error
{
    my ($self, @args) = @_;
    my $msg = join('', @args);
    diag("ERROR: $msg");
    return $msg;
}

# Fail a test, use error 
sub notok 
{
    my ($self, @args) = @_;
    my $msg = $self->error(@args);
    ok(0, $msg);
}

1;
