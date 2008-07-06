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

    my $dbix = $Rit::dbix;
    my $dbh = $dbix->dbh;
    my $now = DateTime::Format::Pg->format_datetime(now);

    my $R = Rit::Base->Resource;
    my $C = Rit::Base->Constants;

    my $root = $R->get_by_label('root');

    my $req = Para::Frame::Request->new_bgrequest();

    debug "Setting up DB - paranormal";
    $req->user->change_current_user( $root );
    my( $args, $arclim, $res ) = parse_propargs('auto');
    $req->user->set_default_propargs({
				      %$args,
				      activate_new_arcs => 1,
				     });

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
    my $C_phone = $C->get('phone');
    my $C_language = $C->get('language');

    my $pc = $R->find_set({
			   label => 'paranormal_sweden_creation',
			   is => $C_login_account,
			  });
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
      $R->find_set({
		    label => 'pc_member_id',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.member",
		   });


    my $pc_member_level =
      $R->find_set({
		    label => 'pc_member_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.member_level",
		   });

    my $pc_latest_in =
      $R->find_set({
		    label => 'pc_latest_in',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_date,
		    admin_comment => "Old member.latest_in",
		   });

    my $pc_latest_out =
      $R->find_set({
		    label => 'pc_latest_out',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_date,
		    admin_comment => "Old member.latest_out",
		   });

    my $pc_latest_host =
      $R->find_set({
		    label => 'pc_latest_host',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_url,
		    admin_comment => "Old member.latest_host",
		   });

    my $has_email =
      $R->find_set({
		    label => 'has_email',
		    is => $C_predicate,
		    domain => $C_intelligent_agent,
		    range => $C_email,
		    admin_comment => "E-mail going to the agent",
		   });

    my $sys_username =
      $R->find_set({
		    label => 'sys_username',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_text,
		    admin_comment => "Old member.sys_uid",
		   });

    my $pc_sys_logging =
      $R->find_set({
		    label => 'pc_sys_logging',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.sys_logging",
		   });

    my $pc_present_contact =
      $R->find_set({
		    label => 'pc_present_contact',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.present_contact",
		   });

    my $pc_present_activity =
      $R->find_set({
		    label => 'pc_present_activity',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.present_activity",
		   });

    my $pc_member_general_belief =
      $R->find_set({
		    label => 'pc_member_general_belief',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_belief",
		   });

    my $pc_member_general_theory =
      $R->find_set({
		    label => 'pc_member_general_theory',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_theory",
		   });

    my $pc_member_general_practice =
      $R->find_set({
		    label => 'pc_member_general_practice',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_practice",
		   });

    my $pc_member_general_editor =
      $R->find_set({
		    label => 'pc_member_general_editor',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_editor",
		   });

    my $pc_member_general_helper =
      $R->find_set({
		    label => 'pc_member_general_helper',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_helper",
		   });

    my $pc_member_general_meeter =
      $R->find_set({
		    label => 'pc_member_general_meeter',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_meeter",
		   });

    my $pc_member_general_bookmark =
      $R->find_set({
		    label => 'pc_member_general_bookmark',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_bookmark",
		   });

    my $pc_member_general_discussion =
      $R->find_set({
		    label => 'pc_member_general_discussion',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.general_discussion",
		   });

    my $pc_chat_nick =
      $R->find_set({
		    label => 'pc_chat_nick',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.chat_nick",
		   });

    my $pc_member_newsmail_level =
      $R->find_set({
		    label => 'pc_member_newsmail_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.newsmail",
		   });

    my $pc_member_show_complexity_level =
      $R->find_set({
		    label => 'pc_member_show_complexity_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.show_complexity",
		   });

    my $pc_member_show_detail_level =
      $R->find_set({
		    label => 'pc_member_show_detail_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.show_detail",
		   });

    my $pc_member_show_edit_level =
      $R->find_set({
		    label => 'pc_member_show_edit_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.show_edit",
		   });

    my $pc_website_style =
      $R->find_set({
		    label => 'pc_website_style',
		    is => $C_class,
		    admin_comment => "Collection of css styles",
		   });

    my $pc_show_style =
      $R->find_set({
		    label => 'pc_show_style',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $pc_website_style,
		    admin_comment => "Old member.show_style",
		   });

    my $name_given =
      $R->find_set({
		    label => 'name_given',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_text,
		    admin_comment => "Old member.name_given",
		   });

    my $name_middle =
      $R->find_set({
		    label => 'name_middle',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_text,
		    admin_comment => "Old member.name_middle",
		   });

    my $name_family =
      $R->find_set({
		    label => 'name_family',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_text,
		    admin_comment => "Old member.name_family",
		   });


    # RELTYPE
    #
    # reltype             pc_arctype_id
    # rel_name            name
    # rev_name            name_rev
    # reltype_topic       -
    # reltype_description admin_comment
    # reltype_updated     node(updated)
    # reltype_changedby   node(updated_by)
    # reltype_super       -
    # reltype_literal     range

    my $pc_arctype_id =
      $R->find_set({
		    label => 'pc_arctype_id',
		    is => $C_predicate,
		    domain => $C_predicate,
		    range => $C_int,
		    admin_comment => "Old reltype.reltype",
		   });

    my $name_rev =
      $R->find_set({
		    label => 'name_rev',
		    is => $C_predicate,
		    domain => $C_predicate,
		    range => $C_text,
		    admin_comment => "Old reltype.rev_name",
		   });

#    my $arctype_map =
#    {
#     0 => 'see_also',
#     1 => 'is',
#     2 => 'scof',
#     3 => 'iso',
#     4 => ['according_to', $perspective, $thought],
#     5 => undef,
#     6 => ['excerpt_from', $text, $media],
#     7 => ['member_of', $person, $group],
#     8 => ['original_creator', $media, $intelligent_agent],
#     9 => ['has_source', $media, $media],
#     10 => ['offered_by', $trade_item, $intelligent_agent],
#     11 => ['compares', $perspective, undef],
#     12 => ['interested_in', $thought, undef],
#     13 => ['published_date', $media, $C_date],
#     14 => ['published_by', $media, $intelligent_agent],
#     15 => ['has_subtitle', $media, $C_text],
#     16 => ['has_translator', $media, $intelligent_agent],
#     17 => ['has_gtin', $trade_item, $gtin],
#     18 => ['has_number_of_pages', $printed_media, $C_int],
#     19 => ['has_start_date', $temporal_thing, $C_date],
#     20 => ['has_end_date', $temporal_thing, $C_date],
#     21 => ['influenced_by', $thought, $thought],
#     22 => ['has_license', $media, $license],
#     23 => ['has_copyright', $media, $legal_agent],
#     24 => ['has_visiting_address', $addressable, $address],
#     25 => ['has_zipcode', $addressable, $zipcode],
#     26 => ['in_city', $addressable, $city],
#     27 => ['has_phone_number', [$counstruction_artifact, $agent], $C_phone],
#     28 => ['has_permission_document', $text, $usage_permission],
#     29 => ['instances_are_member_of', $person_class, $group],
#     30 => ['can_be', $C_class, $C_class],
#     31 => ['is_part_of', $thing, $thing],
#     32 => ['can_be_part_of', $C_class, $C_class],
#     33 => ['is_of_language', $media, $C_language],
#     34 => ['practise', $intelligent_agent, $practisable,
#	    'allways_practice', $person_class, $practisable],
#     35 => ['has_experienced', $person, $experiencable],
#     36 => ['is_influenced_by', $thing, $thing],
#     37 => ['based_upon', $media, $media],
#     38 => ['has_epithet', $life_form, $epithet],
#     39 => ['in_place', $thing, $location],
#     40 => undef,
#     41 => undef,
#     42 => undef,
#     43 => ['has_postal_address', $addressable, $address],
#     44 => ['instance_owned_by', $thing_class, $legal_agent],
#     45 => ['has_owner', $thing, $legal_agent],
#     46 => undef,
#     47 => ['uses', $composition, $thing_class],
#    };
#
#    foreach my $rtid ( sort keys %$arctype_map )
#    {
#	my $pred_name = $arctype_map->{$rtid} or next;
#	my $pred = $R->find_set({label => $pred_name});
#    }
#
#
#
#
#
#
#    # LOCATIONS
#    #
#    # country            loc_country
#    # county             loc_county
#    # municipality       loc_municipality
#    # city               loc_city
#    # parish             loc_parish
#    # zip                loc_zip
#    # street             loc_street
#    # address            loc_address
#
#
#    my $location =
#      $R->find_set({
#		    label => 'location',
#		    is => $C_class,
#		   });
#
#    my $is_a_part_of =
#      $R->find_set({
#		    label => 'is_a_part_of',
#		    is => $C_predicate,
#		    admin_comment => "Old ",
#		   });
#
#
#    my $country =
#      $R->find_set({
#		    label => 'loc_country',
#		    scof => $location,
#		   });
#
#    my $ =
#      $R->find_set({
#		    label => '',
#		    scof => $location,
#		   });
#
#    my $ =
#      $R->find_set({
#		    label => '',
#		    scof => $location,
#		   });
#
#    my $ =
#      $R->find_set({
#		    label => '',
#		    scof => $location,
#		   });
#
#    my $ =
#      $R->find_set({
#		    label => '',
#		    scof => $location,
#		   });
#
#    my $ =
#      $R->find_set({
#		    label => '',
#		    scof => $location,
#		   });
#    my $ =
#      $R->find_set({
#		    label => '',
#		    scof => $location,
#		   });
#
#    my $ =
#      $R->find_set({
#		    label => '',
#		    scof => $location,
#		   });
#
#    my $ =
#      $R->find_set({
#		    label => '',
#		    scof => $location,
#		   });
#
#
#
#
#
#
#
#    # ADDRESS
#    #
#    # address_street     -
#    # address_nr_from    pc_address_nr_from
#    # address_nr_to      pc_address_nr_to
#    # address_step       pc_address_nr_step
#    # address_zip        in_region
#    # address_from_x     -
#    # address_from_y     -
#    # address_to_x       -
#    # address_to_y       -
#
#
#    my $pc_address_nr_from =
#      $R->find_set({
#		    label => 'pc_address_nr_from',
#		    is => $C_predicate,
#		    domain => $C_login_account,
#		    range => $pc_website_style,
#		    admin_comment => "Old member.show_style",
#		   });
#
#
#






######## Setup Para classes
    my %PM =
      (
       login_account => 'Para::User',
      );

    foreach my $cname ( keys %PM )
    {
	my $mname = $PM{ $cname };

	my $mn = $R->find_set({
			       code => $mname,
			       is   => 'class_perl_module',
			      });

	my $cn = $R->get_by_label( $cname );
	$cn->update({ 'class_handled_by_perl_module' => $mn });
    }




    $Para::Frame::REQ->done;
    $req->user->set_default_propargs(undef);

    print "Done!\n";

    return;
}

1;
