#  $Id$  -*-cperl-*-
package Para::Setup;
#=====================================================================
#
# DESCRIPTION
#   Paranormal Database Setup
#
# AUTHOR
#   Jonas Liljegren   <jonas@paranormal.se>
#
# COPYRIGHT
#   Copyright (C) 2007 Jonas Liljegren.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
#=====================================================================

=head1 NAME

Para::Setup

=cut

use strict;

BEGIN
{
    our $VERSION  = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);
    print "Loading ".__PACKAGE__." $VERSION\n";
}

use utf8;
use DBI;
use Carp qw( croak );
use DateTime::Format::Pg;

use Para::Frame::Utils qw( debug datadump throw );
use Para::Frame::Time qw( now );

use Rit::Base::Utils qw( valclean parse_propargs query_desig );
use Rit::Base::Setup;

sub setup_db
{
    unless( $ARGV[0] and ($ARGV[0] eq 'setup_db') )
    {
	return;
    }

    debug "Setting up DB - ritbase";

    Rit::Base::Setup->setup_db();

    my $dbix = $Rit::dbix;
    my $dbh = $dbix->dbh;
    my $now = DateTime::Format::Pg->format_datetime(now);

    my $R = Rit::Base->Resource;
    my $C = Rit::Base->Constants;

    my $root = $R->get_by_constant_label('root');

    my $req = Para::Frame::Request->new_bgrequest();

    debug "Setting up DB - paranormal";
    $req->user->change_current_user( $root );
    $req->user->set_default_propargs({activate_new_arcs => 1 });
    my( $args, $arclim, $res ) = parse_propargs();

    debug "Args:\n".query_desig($args);


    debug "User is ".$req->user->desig;

    debug "------------------------------------";

    my $C_login_account     = $C->get('login_account');
    my $C_intelligent_agent = $C->get('intelligent_agent');
    my $C_predicate         = $C->get('predicate');
    my $C_class             = $C->get('class');

    my $C_int   = $C->get('int');
    my $C_date  = $C->get('date');
    my $C_url   = $C->get('url');
    my $C_email = $C->get('email');
    my $C_text  = $C->get('text');

    my $pc = $R->find_set(
			  {
			   label => 'paranormal_sweden_creation',
			   is => $C_login_account,
			  }
			 );
    $dbix->commit;

    $Para::Frame::CFG->{'rb_default_source'} = $pc;
    $req->user->change_current_user( $pc );


    # MEMBER
    #
    # member             pc_member_id
    # nickname           short_name
    # member_level       pc_member_level
    # member_created     node(created)
    # member_updated     node(updated)
    # latest_in          pc_latest_in
    # latest_out         pc_latest_out
    # latest_host        pc_latest_host
    # mailalias_updated  -
    # intrest_updated    -
    # sys_email          has_email
    # sys_uid            sys_username
    # sys_logging        pc_sys_logging
    # present_contact    pc_present_contact
    # present_activity   pc_present_activity
    # general_belief     pc_member_general_belief
    # general_theory     pc_member_general_theory
    # general_practice   pc_member_general_practice
    # general_editor     pc_member_general_editor
    # general_helper     pc_member_general_helper
    # general_meeter     pc_member_general_meeter
    # general_bookmark   pc_member_general_bookmark
    # general_discussion pc_member_general_discussion
    # chat_nick          pc_chat_nick
    # prefered_chat      -
    # prefered_im        -
    # newsmail           pc_member_newsmail_level
    # show_complexity    pc_member_show_complexity_level
    # show_detail        pc_member_show_detail_level
    # show_edit          pc_member_show_edit_level
    # show_style         pc_show_style
    # name_prefix        -
    # name_given         name_given
    # name_middle        name_middle
    # name_family        name_family
    # name_suffix        -



    my $pc_member_id =
      $R->find_set(
		   {
		    label => 'pc_member_id',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.member",
		   });


    my $pc_member_level =
      $R->find_set(
		   {
		    label => 'pc_member_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.member_level",
		   });

    my $pc_latest_in =
      $R->find_set(
		   {
		    label => 'pc_latest_in',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_date,
		    admin_comment => "Old member.latest_in",
		   });

    my $pc_latest_out =
      $R->find_set(
		   {
		    label => 'pc_latest_out',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_date,
		    admin_comment => "Old member.latest_out",
		   });

    my $pc_latest_host =
      $R->find_set(
		   {
		    label => 'pc_latest_host',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_url,
		    admin_comment => "Old member.latest_host",
		   });

    my $has_email =
      $R->find_set(
		   {
		    label => 'has_email',
		    is => $C_predicate,
		    domain => $C_intelligent_agent,
		    range => $C_email,
		    admin_comment => "E-mail going to the agent",
		   });

    my $sys_username =
      $R->find_set(
		   {
		    label => 'sys_username',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_text,
		    admin_comment => "Old member.sys_uid",
		   });

    my $pc_sys_logging =
      $R->find_set(
		   {
		    label => 'pc_sys_logging',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.sys_logging",
		   });

    my $pc_present_contact =
      $R->find_set(
		   {
		    label => 'pc_present_contact',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.present_contact",
		   });

    my $pc_present_activity =
      $R->find_set(
		   {
		    label => 'pc_present_activity',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.present_activity",
		   });

    my $pc_member_general_belief =
      $R->find_set(
		   {
		    label => 'pc_member_general_belief',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_belief",
		   });

    my $pc_member_general_theory =
      $R->find_set(
		   {
		    label => 'pc_member_general_theory',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_theory",
		   });

    my $pc_member_general_practice =
      $R->find_set(
		   {
		    label => 'pc_member_general_practice',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_practice",
		   });

    my $pc_member_general_editor =
      $R->find_set(
		   {
		    label => 'pc_member_general_editor',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_editor",
		   });

    my $pc_member_general_helper =
      $R->find_set(
		   {
		    label => 'pc_member_general_helper',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_helper",
		   });

    my $pc_member_general_meeter =
      $R->find_set(
		   {
		    label => 'pc_member_general_meeter',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_meeter",
		   });

    my $pc_member_general_bookmark =
      $R->find_set(
		   {
		    label => 'pc_member_general_bookmark',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_bookmark",
		   });

    my $pc_member_general_discussion =
      $R->find_set(
		   {
		    label => 'pc_member_general_discussion',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_discussion",
		   });

    my $pc_chat_nick =
      $R->find_set(
		   {
		    label => 'pc_chat_nick',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.chat_nick",
		   });

    my $pc_member_newsmail_level =
      $R->find_set(
		   {
		    label => 'pc_member_newsmail_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.newsmail",
		   });

    my $pc_member_show_complexity_level =
      $R->find_set(
		   {
		    label => 'pc_member_show_complexity_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.show_complexity",
		   });

    my $pc_member_show_detail_level =
      $R->find_set(
		   {
		    label => 'pc_member_show_detail_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.show_detail",
		   });

    my $pc_member_show_edit_level =
      $R->find_set(
		   {
		    label => 'pc_member_show_edit_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.show_edit",
		   });

    my $pc_website_style =
      $R->find_set(
		   {
		    label => 'pc_website_style',
		    is => $C_class,
		    admin_comment => "Collection of css styles",
		   });

    my $pc_show_style =
      $R->find_set(
		   {
		    label => 'pc_show_style',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $pc_website_style,
		    admin_comment => "Old member.show_style",
		   });

    my $name_given =
      $R->find_set(
		   {
		    label => 'name_given',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_text,
		    admin_comment => "Old member.name_given",
		   });

    my $name_middle =
      $R->find_set(
		   {
		    label => 'name_middle',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_text,
		    admin_comment => "Old member.name_middle",
		   });

    my $name_family =
      $R->find_set(
		   {
		    label => 'name_family',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_text,
		    admin_comment => "Old member.name_family",
		   });




    $dbix->commit;

    print "Done!\n";

    return;
}

1;
