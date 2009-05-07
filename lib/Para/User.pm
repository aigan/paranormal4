package Para::User;
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

Para::User

=cut

use 5.010;
use strict;
use warnings;
use base qw(Rit::Base::User);

use Para::Frame::Reload;
use Para::Frame::Utils qw( debug trim );

use Rit::Base::Utils qw( is_undef );
use Rit::Base::User;
use Rit::Base::Constants qw( $C_login_account $C_guest_access );
use Rit::Base::Literal::Time qw( now );

##############################################################################
#
#=head2 get
#
#  $class->get( $username, \%args )
#
#C<%args> may be
#
#  password
#  password_encrypted
#
#For cases when where may be more than one user with the same username.
#
#Called by L<Para::Frame::User/identify_user> and
#L<Para::Frame::Action::user_login>.
#
#Returns a L<Rit::Guides::User> or a L<Rit::Guides::CityBreak::User>.
#
#=cut
#
#sub get
#{
#    my( $this, $username, $args ) = @_;
#
#    return undef unless $username;
#    if( $username =~ /\@/ )
#    {
#	if( my $cbuser = Rit::Guides::CityBreak::User->get($username, $args) )
#	{
#	    return $cbuser->node;
#	}
#    }
#
#    return $this->Rit::Base::User::get($username, $args);
#}
#
##############################################################################
#
#=head2 level
#
#cb users gets level 5 instead of any other given level
#
#=cut
#
#sub level
#{
#    unless( $_[0]->{'level'} )
#    {
#	my $node = $_[0];
#	if( $node->has_value({ 'has' => $C_cb_account }) )
#	{
#	    $node->{'level'} = 5;
#	}
#	else
#	{
#	    return $node->SUPER::level;
#	}
#    }
#
#    return $_[0]->{'level'};
#}
#
#
##############################################################################
#
#=head2 after_user_login
#
#=cut
#
#sub after_user_login
#{
#    my( $u ) = @_;
#
#    my $req = $Para::Frame::REQ;
#    my $page = $req->page;
#
#    # If logged in from start page or login page
#    if( $page->path =~ /^(\/login\.tt)?$/  )
#    {
#	my $level = $u->level;
#
#	debug "The level for user was found out to be $level";
#
#	if( $u->level >= 20 )
#	{
#	    $req->set_page_path("/admin/agenda/");
#	}
#	elsif( $u->level >= 10 )
#	{
#	    $req->set_page_path("/customer_admin/");
#	}
#	else
#	{
#	    $req->set_page_path("/booking/current.tt");
#	}
#    }
#
#}
#
##############################################################################

=head2 has_page_update_access

  $u->has_page_update_access()

  $u->has_page_update_access( $file )

Reimplement this to give update access for a specific page or the
default access for the given user.

C<$file> must be a L<Para::Frame::File> object.

Returns: true or false

The default is false (0).

=cut

sub has_page_update_access
{
    my( $u, $file ) = @_;

    debug "has_page_update_access?";

    return $u->has_root_access;


    if( $file )
    {
	unless( UNIVERSAL::isa( $file, 'Para::Frame::File' ) )
	{
	    throw('action', "File param not a Para::Frame::File object");
	}
    }

    return 0;
}

##############################################################################

1;
