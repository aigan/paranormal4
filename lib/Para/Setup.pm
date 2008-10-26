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
    my $ia                  = $C->get('intelligent_agent');
    my $C_predicate         = $C->get('predicate');
    my $class               = $C->get('class');

    my $C_int   = $C->get('int');
    my $C_date  = $C->get('date');
    my $C_url   = $C->get('url');
    my $C_email = $C->get('email');
    my $C_text  = $C->get('text');
    my $C_phone_number = $C->get('phone_number');
    my $C_language = $C->get('language');

    my $pc = $R->find_set({
			   label => 'paranormal_sweden_creation',
			   is => $C_login_account,
			  });
    $dbix->commit;

    $Para::Frame::CFG->{'rb_default_source'} = $pc;
    $req->user->change_current_user( $pc );




    my $pc_old_topic_id =
      $R->find_set({
		    label => 'pc_old_topic_id',
		    is => $C_predicate,
		    range => $C_int,
		    admin_comment => "Old t.t",
		   });

    $pc->add({pc_old_topic_id => 32574});




    my $pc_old_arctype_id =
      $R->find_set({
		    label => 'pc_old_arctype_id',
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





    #
    # Domains and ranges used for reltypes
    #
    # pct is used as a prefix: paranormal creation topic

    my $psychological_phenomenon
      = $R->find_set({
		      label => 'pct_psychological_phenomenon',
		      is => $class,
		      pc_old_topic_id => 3318,
		     });

     my $thought
      = $R->find_set({
		      label => 'pct_thought',
		      scof => $psychological_phenomenon,
		      pc_old_topic_id => 148549,
		     });

    my $perspective
      = $R->find_set({
		      label => 'pct_perspective',
		      scof => $thought,
		     });

    my $information_store
      = $R->find_set({
		      label => 'information_store',
		      admin_comment => "Each instance of InformationStore is a tangible or intangible, concrete or abstract repository of information.",
		      cyc_id => 'InformationStore',
		     });
    my $media
      = $R->find_set({
		      label => 'media',
		      admin_comment => "Each instance of MediaProduct is an information store created for the purposes of media distribution (see MediaTransferEvent). Specializations of MediaProduct include RecordedVideoProduct, MediaSeriesProduct, WorldWideWebSite and NewsArticle.",
		      scof => $class,
		      cyc_id => 'MediaProduct',
		      pc_old_topic_id => 4463,
		     });
    my $ais
      = $R->find_set({
		      label => 'ais',
		      admin_comment => "AspatialInformationStore is the collection of all information stores that have no spatial location. Specializations of AspatialInformationStore include ConceptualWork, Microtheory, AbstractInformationStructure, and FieldOfStudy.",
		      cyc_id => 'AspatialInformationStore',
		      scof => $media,
		     });

    my $person
      = $R->find_set({
		      label => 'person',
		      admin_comment => "An individual intelligent agent",
		      scof => $ia,
		      cyc_id => 'Person',
		      pc_old_topic_id => 2140,
		     });

    my $mia
      = $R->find_set({
		      label => 'mia',
		      admin_comment => "MultiIndividualAgent. A type of Agent-Generic that may or may not be intelligent. Usually constitutes some type of group, such as a LegalCorporation, CrowdOfPeople or Organization",
		      cyc_id => 'MultiIndividualAgent',
		      pc_old_topic_id => 143,
		     });

    my $product
      = $R->find_set({
		      label => 'product',
		      admin_comment => "Each instance of Product is a TemporalThing that is, or was at one time, offered for sale or performed as a commercial service, or was produced with the intent of being offered for sale.",
		      cyc_id => 'Product',
		      pc_old_topic_id => 422155,
		     });

    my $book_cw
      = $R->find_set({
		      label => 'book_cw',
		      admin_comment => "Each instance of Book-CW is an abstract work intended to be instantiated as a book of some sort. Instances of Book-CW may be intended to be instantiated in any book format: hardcopy (see BookCopy), electronic, audio tape, etc.",
		      scof => $ais,
		      cyc_id => 'Book-CW',
		      pc_old_topic_id => 443,
		     });

    my $temporal_thing
      = $R->find_set({
		      label => 'temporal_thing',
		      admin_comment => "This is the collection of all things that have temporal extent or location -- things about which one might sensibly ask 'When?'. TemporalThing thus contains many kinds of things, including events, physical objects, agreements, and pure intervals of time.",
		      cyc_id => 'TemporalThing',
		     });

    my $temporal_thing_class
      = $R->find_set({
		      label => 'pct_temporal_thing_class',
		      admin_comment => "Temporal Thing Type",
		      scof => $class,
		     });

    my $spatial_thing
      = $R->find_set({
		      label => 'spatial_thing',
		      admin_comment => "The collection of all things that have a spatial extent or location relative to some other SpatialThing or in some embedding space. Note that to say that an entity is a member of this collection is to remain agnostic about two issues. First, a SpatialThing may be PartiallyTangible (e.g. Texas-State) or wholly Intangible (e.g. ArcticCircle or a line mentioned in a geometric theorem). Second, although we do insist on location relative to another spatial thing or in some embedding space, a SpatialThing might or might not be located in the actual physical universe.",
		      cyc_id => 'SpatialThing',
		      scof => $class,
		     });

    my $license
      = $R->find_set({
		      label => 'license',
		      admin_comment => "Each element of License-LegalAgreement is a credential issued by a granting authority and recorded in some tangible document (see License-IBO), which authorizes the agent to whom it is issued to perform actions of a certain kind.",
		      cyc_id => 'License-LegalAgreement',
		      pc_old_topic_id => 144544,
		     });

    my $legal_agent
      = $R->find_set({
		      label => 'legal_agent',
		      admin_comment => "Each instance of LegalAgent is an agent who has some status in a particular legal system. At the very least, such an agent is recognized by some legal authority as having some kinds of rights and/or responsibilities as an agent (e.g., citizens of Germany), or as being subject to certain restrictions and penalties (e.g., a company that has been blacklisted by Iraq).",
		      scof => $ia,
		      cyc_id => 'LegalAgent',
		     });

    my $permission_ibt
      = $R->find_set({
		      label => 'permission_ibt',
		      admin_comment => "The InformationBearingThing that holds the persmission",
		      scof => $media,
		      pc_old_topic_id => 387092,
		     });

    my $individual
      = $R->find_set({
		      label => 'individual',
		      admin_comment => "Individual is the collection of all individuals: things that are not sets or collections. Individuals might be concrete or abstract, and include (among other things) physical objects, events, numbers, relations, and groups.",
		     });

    my $practisable
      = $R->find_set({
		      label => 'pct_practisable',
		      admin_comment => "Stuff that an IntelligentAgent can be involved in or use (IntelligentAgentActivity), like therapies, religions or skills",
		      pc_old_topic_id => 11,
		     });

    my $experiencable
      = $R->find_set({
		      label => 'pct_experiencable',
		      admin_comment => "Stuff that a person can experience, tat would be of interest",
		      pc_old_topic_id => 12,
		     });

    my $person_class
      = $R->find_set({
		      label => 'pct_person_class',
		      admin_comment => "PersonType",
		      scof => $class,
		     });


    my $location
      = $R->find_set({
		      label => 'location',
		      admin_comment => "Each instance of Place is a spatial thing which has a relatively permanent location.",
		      scof => $spatial_thing,
		      pc_old_topic_id => 3322,
		      cyc_id => 'Place',
		     });

    my $gtin
      = $R->find_set({
		      label => 'gtin',
		      admin_comment => "Global Trade Identification Number. Includes ISBN, ISSN and other barcode standards. http://www.gtin.info/",
		      scof => $C_text,
		     });






# Just using intelligent_agent for now...
#
#    my $addressable
#      = $R->find_set({
#		      label => 'pct_addressable',
#		      admin_comment => "Anything that can have a PhysicalContactLocation or MailingLocation. See ContactLocation and ContactInfoString and addressOfLocation. I can't find a Cyc equivalent. They uses PartiallyTangible or Agent-PartiallyTangible.",
#		     });
#
# More information:
#
# ContactLocation
# ContactInfoString
# pointsOfContact
# SingleSiteOrganization
# physicalQuarters

#    my $zipcode
#      = $R->find_set({
#		      label => 'zipcode',
#		      admin_comment => "A specialization of ContactInfoString. Each instance of PostalCode is a character string used by a postal service to designate a particular geographic area.",
#		      cyc_id => 'InternationalPostalCode',
#		     });


    ###################################################################

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
		    domain => $ia,
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
		    is => $class,
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
		    domain => $person,
		    range => $C_text,
		    admin_comment => "Old member.name_given. See cyc_id HumanGivenName",
		   });

    my $name_middle =
      $R->find_set({
		    label => 'name_middle',
		    is => $C_predicate,
		    domain => $person,
		    range => $C_text,
		    admin_comment => "Old member.name_middle",
		   });

    my $name_family =
      $R->find_set({
		    label => 'name_family',
		    is => $C_predicate,
		    domain => $person,
		    range => $C_text,
		    admin_comment => "Old member.name_family. See cyc_id HumanGivenName",
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


    my $arctype_map =
    {
     0 => 'see_also',
     1 => 'is',
     2 => 'scof',
     3 => 'iso',
     4 => ['according_to', $perspective, $thought],
     5 => undef,
     6 => ['excerpt_from', $C_text, $media],
     7 => ['member_of', $person, $mia],
     8 => ['original_creator', $media, $ia],
     9 => ['has_source', $media, $media],
     10 => ['offered_by', $product, $ia],
     11 => ['compares', $perspective, undef],
     12 => ['interested_in', $thought, undef],
     13 => ['published_date', $media, $C_date],
     14 => ['published_by', $media, $ia],
     15 => ['has_subtitle', $media, $C_text],
     16 => ['has_translator', $media, $ia],
     17 => ['has_gtin', $product, $gtin],
     18 => ['has_number_of_pages', $media, $C_int],
     19 => ['has_start_date', $temporal_thing, $C_date],
     20 => ['has_end_date', $temporal_thing, $C_date],
     21 => ['influenced_by', $thought, $thought],
     22 => ['has_license', $media, $license],
     23 => ['has_copyright', $media, $legal_agent],
     24 => ['has_visiting_address', $ia, $C_text],
     25 => undef,
     26 => undef,
     27 => ['has_phone_number', $ia, $C_phone_number],
     28 => ['has_permission_document', $C_text, $permission_ibt],
     29 => ['instances_are_member_of', $person_class, $mia],
     30 => ['can_be', $class, $class],
     31 => ['is_part_of', $individual, $individual],
     32 => ['can_be_part_of', $class, $class],
     33 => ['is_of_language', $media, $C_language],
     34 => ['practise', $ia, $practisable,
	    'allways_practice', $person_class, $practisable],
     35 => ['has_experienced', $person, $experiencable],
     36 => 'is_influenced_by',
     37 => ['based_upon', $media, $media],
     38 => ['has_epithet', $individual, $individual],
     39 => ['in_place', $spatial_thing, $location],
     40 => undef,
     41 => undef,
     42 => undef,
     43 => ['has_postal_address', $ia, $C_text],
     44 => ['instance_owned_by', $temporal_thing_class, $legal_agent],
     45 => ['has_owner', $temporal_thing, $legal_agent],
     46 => undef,
     47 => ['uses', $temporal_thing_class, $temporal_thing_class],
    };

    foreach my $rtid ( sort keys %$arctype_map )
    {
	my $def = $arctype_map->{$rtid} or next;

	die datadump($def);


##	my $pred_name = $arctype_map->{$rtid} or next;
##	my $pred = $R->find_set({label => $pred_name});
    }


# TODO: Convert reltype 25 zipcode to geo-tree placement
# TODO: Convert reltype 26 city to geo-tree placement




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
#		    is => $class,
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
