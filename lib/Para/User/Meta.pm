package Para::User::Meta;
#==================================================== -*- cperl -*- ==========
#
# AUTHOR
#   Jonas Liljegren   <jonas@paranormal.se>
#
# COPYRIGHT
#   Copyright (C) 2005-2009 Jonas Liljegren.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
#=============================================================================

=head1 NAME

Para::User::Meta

=cut

use 5.010;
use strict;
use warnings;

use Para::Frame::Reload;
use Para::Frame::Utils qw( debug );

use Rit::Base::Resource;

use Para::User;

use base qw( Para::User Rit::Base::Resource );

=head1 DESCRIPTION

Inherits from L<Para::User> and L<Rit::Base::Resource>.

=cut

##############################################################################

1;
