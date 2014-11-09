# ${license-info}
# ${developer-info
# ${author-info}
# ${build-info}

use strict;
use warnings;

package Test::Quattor::TextRender::Test;

use Test::More;
use Cwd;

use base qw(Test::Quattor::Object);

=pod

=head1 NAME

Test::Quattor::TextRender::Test - Class for a single
template test.

=head1 DESCRIPTION

A TextRender test corresponds to one or more subtests
 that are tested against the profile genereated from one
 corresponding object template.

A test can be a file (implying one subtest, and that 
file being the subtest) or a directory
(one or more subtests; each file in the directory is one
subtest; no subdirectory structure); 
with the file or directory name 
identical to the corresponding object template.

=cut
