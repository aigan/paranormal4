#  $Id$  -*-cperl-*-
package Para::User::Meta;

=head1 NAME

Para::User::Meta

=cut

use strict;

BEGIN
{
    our $VERSION  = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);
    print "Loading ".__PACKAGE__." $VERSION\n";
}

use Para::Frame::Reload;
use Para::Frame::Utils qw( debug );

use Rit::Base::Resource;

use Para::User;

use base qw( Para::User Rit::Base::Resource );

=head1 DESCRIPTION

Inherits from L<Para::User> and L<Rit::Base::Resource>.

=cut

#######################################################################

1;
