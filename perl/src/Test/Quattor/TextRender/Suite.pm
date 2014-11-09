# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}

use strict;
use warnings;

package Test::Quattor::TextRender::Suite;

use Test::More;
use Cwd qw(abs_path);

use File::Basename;
use File::Find;

use base qw(Test::Quattor::Object);

=pod

=head1 NAME

Test::Quattor::TextRender::Suite - Class for a template test suite.

=head1 DESCRIPTION

A TextRender test suite corresponds to one or more 
regular expression based tests (regexptest for short)
that are tested against the profile genereated from one
corresponding object template.

A test suite can be a combination of file (implying one regexptest, and that 
file being the regexptest) and/or a directory
(one or more regexptests; each file in the directory is one
regexptest; no subdirectory structure); 
with the file or directory name 
identical to the corresponding object template.
The names cannot start with a '.'.

=head1 new

Support options

=over

=item testspath

Basepath for the suite tests. 

=item regexps

Path to the suite regexptests  (C<testspath>/regexps is default when not specified).

=item profiles

Path to the suite object templates (C<testspath>/profiles is default when not specified).

=back

=cut

sub _initialize
{
    my ($self) = @_;
    
    $self->{testspath} = abs_path($self->{testspath});
    ok(-d $self->{testspath}, "testspath $self->{testspath} exists");

    if ($self->{profilespath}) {
        if ($self->{profilespath} !~ m/^\//) {
            $self->verbose("Relative profilespath $self->{profilespath} found");
            $self->{profilespath} = "$self->{testspath}/$self->{profilespath}";
        }
    } else {
        $self->{profilespath} = "$self->{testspath}/profiles";
    }
    $self->{profilespath} = abs_path($self->{profilespath});
    ok(-d $self->{profilespath}, "profilespath $self->{profilespath} exists");

    if ($self->{regexpspath}) {
        if ($self->{regexpspath} !~ m/^\//) {
            $self->verbose("Relative regexpspath $self->{regexpspath} found");
            $self->{regexpspath} = "$self->{testspath}/$self->{regexpspath}";
        }
    } else {
        $self->{regexpspath} = "$self->{testspath}/regexps";
    }
    $self->{regexpspath} = abs_path($self->{regexpspath});
    ok(-d $self->{regexpspath}, "Init regexpspath $self->{regexpspath} exists");
    
}

=pod

=head2 gather_regexp

Find all regexptests. Files/directories that start with a '.' are ignored.

Returns hash ref with name as key and array ref of the regexptests paths.

=cut

sub gather_regexp
{
    my ($self) = @_;
    
    my %regexps;
    

    opendir(DIR, $self->{regexpspath});

    foreach my $name (grep { ! m/^\./ } sort readdir(DIR)) {
        my $abs = "$self->{regexpspath}/$name";
        if (-f $abs) {
            $self->verbose("Found regexps file $name (abs $abs)");
            $regexps{$name} = [$name];
        } elsif (-d $abs) {
            opendir(my $dh, $abs);
            # only files
            my @files = map { "$name/$_" } grep { ! m/^\./ && -T "$abs/$_" } sort readdir($dh);
            closedir $dh;
            $self->verbose("Found regexps directory $name (abs $abs) with files ".join(", ", @files));
            $regexps{$name} = \@files;
        } else {
            $self->notok("Invalid regexp abs $abs found");            
        }
    }

    closedir(DIR);
   
    return \%regexps;
}

=pod

=head2 gather_profile

Create a hash reference of all object templates in the 'profilespath'
with name key and filepath as value.

=cut

sub gather_profile
{
    my ($self) = @_;
    
    # empty namespace
    my ($pans, $ipans) = $self->gather_pan($self->{profilespath}, $self->{profilespath}, '');
    
    is(scalar @$ipans, 0, 'No invalid pan templates');

    my %objs;
    while (my ($pan, $type) = each %$pans) {
        my $name = basename($pan);
        $name =~ s/\.pan$//;
        $objs{$name} = $pan if ($type eq 'object');
    }
    
    return \%objs;
}

=pod

=head2 test

Run all tests to validate the suite.

=cut

sub test
{

    my ($self) = @_;
    
    my $regexps = $self->gather_regexp();
    ok($regexps, "Found regexps");

    my $profiles = $self->gather_profile();    
    ok($profiles, "Found profiles");

    is_deeply([sort keys %$regexps], [sort keys %$profiles], 
                "All regexps have matching profile");

}

1;
