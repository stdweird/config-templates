# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# ${developer-info
# ${author-info}
# #
      # perl-CAF, 13.5.0, 1, 20130513-1603
      #
#
#
# CAF::ReporterObject class
#
# Written by German Cancio <German.Cancio@cern.ch>
#            and Piotr Poznanski <Piotr.Poznanski@cern.ch>
# (C) 2003 German Cancio & EU DataGrid http://www.edg.org
#

package CAF::ReporterObject;

use strict;
use vars qw(@ISA $_SINGLETON);
use CAF::Object;
use LC::Exception qw (SUCCESS throw_error);
use CAF::Reporter;

@ISA = qw(CAF::Object CAF::Reporter);


BEGIN {
  # ensure no object defined on startup
  $_SINGLETON=undef;
}

=pod

=head1 NAME

CAF::ReporterObject - singleton Reporter object class

=head1 SYNOPSIS

 use CAF::ReporterObject;
 my $r=CAF::ReporterObject->instance();

 $r->report("whatever");
 $r->debug("blah blah");
 ...

=head1 INHERITANCE

  CAF::Reporter
  CAF::Object

=head1 DESCRIPTION

Provides a wrapper class to instantiate the Reporter as a singleton object.

=over

=cut

#------------------------------------------------------------
#                      Public Methods/Functions
#------------------------------------------------------------

=pod

=back

=head2 Public methods

=over 4

=item instance(): ReporterObject

returns the ReporterObject instance and creates it if
neccessary. ReporterObject is a singleton.

=cut


sub instance () {
  my $class=shift;

  return $_SINGLETON
    if (defined $_SINGLETON);
  $_SINGLETON=$class->SUPER::new();
  return $_SINGLETON;
}

=pod

=item new(): throws error

new() throws an error, as this method is not to be used (instead,
create/get the singleton with instance())

=cut

sub new () {
  throw_error("new() cannot be used for ReporterObject singleton class");
  return ();
}


=head2 Private methods

=over 4

=item _initialize()

initialize the singleton.

=cut

sub _initialize () {
  return SUCCESS;
}

=pod

=back

=cut

#------------------------------------------------------------
#                      Other doc
#------------------------------------------------------------

=pod

=head1 SEE ALSO

CAF::Object, LC::Exception, CAF::Reporter

=head1 AUTHORS

German Cancio <German.Cancio@cern.ch>,
Piotr Poznanski <Piotr.Poznanski@cern.ch>

=head1 VERSION

$Id: ReporterObject.pm,v 1.2 2007/11/27 15:20:58 poleggi Exp $

=cut

1; ## END ##
