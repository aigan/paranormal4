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
#   Copyright (C) 2007-2009 Jonas Liljegren.  All Rights Reserved.
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

use Para::Frame::Utils qw( debug datadump throw validate_utf8 );
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
    my $L = Rit::Base->Literal;

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

    my $odbix = Para::Frame::DBIx->
      new({connect =>$Para::CFG->{'dbconnect_old'}});
    $odbix->connect;
    my $odbh = $odbix->dbh;



    my $C_login_account     = $C->get('login_account');
    my $ia                  = $C->get('intelligent_agent');
    my $C_predicate         = $C->get('predicate');
    my $class               = $C->get('class');
    my $C_resource          = $C->get('resource');
    my $C_arc               = $C->get('arc');

    my $C_int   = $C->get('int');
    my $C_float = $C->get('float');
    my $C_bool  = $C->get('bool');
    my $C_date  = $C->get('date');
    my $C_url   = $C->get('url');
    my $C_email_address = $C->get('email_address');
    my $C_text  = $C->get('text');
    my $C_phone_number = $C->get('phone_number');
    my $C_language = $C->get('language');
    my $C_password = $C->get('password');

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


    my $individual
      = $R->find_set({
		      label => 'individual',
		      admin_comment => "Individual is the collection of all individuals: things that are not sets or collections. Individuals might be concrete or abstract, and include (among other things) physical objects, events, numbers, relations, and groups.",
		      is => $class,
		     });

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
		      scof => $individual,
		      pc_old_topic_id => 3318,
		     });

    debug "---------------> HERE";


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
		      scof => $individual,
		     });
    my $media
      = $R->find_set({
		      label => 'media',
		      admin_comment => "Each instance of MediaProduct is an information store created for the purposes of media distribution (see MediaTransferEvent). Specializations of MediaProduct include RecordedVideoProduct, MediaSeriesProduct, WorldWideWebSite and NewsArticle.",
		      scof => $individual,
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

    my $spatial_thing
      = $R->find_set({
		      label => 'spatial_thing',
		      admin_comment => "The collection of all things that have a spatial extent or location relative to some other SpatialThing or in some embedding space. Note that to say that an entity is a member of this collection is to remain agnostic about two issues. First, a SpatialThing may be PartiallyTangible (e.g. Texas-State) or wholly Intangible (e.g. ArcticCircle or a line mentioned in a geometric theorem). Second, although we do insist on location relative to another spatial thing or in some embedding space, a SpatialThing might or might not be located in the actual physical universe.",
		      cyc_id => 'SpatialThing',
		      scof => $individual,
		     });

    my $physical_organism
      = $R->find_set({
		      label => 'physical_organism',
		      admin_comment => "Physical life form",
		      scof => $spatial_thing,
		      cyc_id => 'Organism-Whole',
		      pc_old_topic_id => 9052,
		     });

    my $person
      = $R->find_set({
		      label => 'person',
		      admin_comment => "An individual intelligent agent",
		      scof => [$ia, $physical_organism],
		      cyc_id => 'Person',
		      pc_old_topic_id => 2140,
		     });

    my $mia
      = $R->find_set({
		      label => 'mia',
		      admin_comment => "MultiIndividualAgent. A type of Agent-Generic that may or may not be intelligent. Usually constitutes some type of group, such as a LegalCorporation, CrowdOfPeople or Organization",
		      cyc_id => 'MultiIndividualAgent',
		      pc_old_topic_id => 143,
		      is => $class,
		     });

    my $product
      = $R->find_set({
		      label => 'product',
		      admin_comment => "Each instance of Product is a TemporalThing that is, or was at one time, offered for sale or performed as a commercial service, or was produced with the intent of being offered for sale.",
		      cyc_id => 'Product',
		      pc_old_topic_id => 422155,
		      scof => $individual,
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
		      is => $class,
		     });

    my $temporal_thing_class
      = $R->find_set({
		      label => 'pct_temporal_thing_class',
		      admin_comment => "Temporal Thing Type",
		      is => $class,
		     });

    my $license
      = $R->find_set({
		      label => 'license',
		      admin_comment => "Each element of License-LegalAgreement is a credential issued by a granting authority and recorded in some tangible document (see License-IBO), which authorizes the agent to whom it is issued to perform actions of a certain kind.",
		      cyc_id => 'License-LegalAgreement',
		      pc_old_topic_id => 144544,
		      scof => $media,
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

    my $believable
      = $R->find_set({
		      label => 'pct_believable',
		      admin_comment => "Stuff that an IntelligentAgent can believe in. Stuff there it may be of interest to know if someone believes in it.",
		      pc_old_topic_id => 10,
		      is => $class,
		     });

    my $practisable
      = $R->find_set({
		      label => 'pct_practisable',
		      admin_comment => "Stuff that an IntelligentAgent can be involved in or use (IntelligentAgentActivity), like therapies, religions or skills",
		      pc_old_topic_id => 11,
		      is => $class,
		     });

    my $experiencable
      = $R->find_set({
		      label => 'pct_experiencable',
		      admin_comment => "Stuff that a person can experience, tat would be of interest",
		      pc_old_topic_id => 12,
		      is => $class,
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



    ###################################################################

    # MEMBER
    #
    # member                       pc_member_id
    # nickname                     name_short
    # member_level                 pc_member_level
    # member_created               node(created)
    # member_updated               node(updated)
    # latest_in                    pc_latest_in
    # latest_out                   pc_latest_out
    # latest_host                  pc_latest_host
    # mailalias_updated            -
    # intrest_updated              -
    # sys_email                    has_virtual_address
    # sys_uid                      sys_username
    # sys_logging                  pc_sys_logging
    # present_contact              pc_present_contact
    # present_activity             pc_present_activity
    # general_belief               pc_member_general_belief
    # general_theory               pc_member_general_theory
    # general_practice             pc_member_general_practice
    # general_editor               pc_member_general_editor
    # general_helper               pc_member_general_helper
    # general_meeter               pc_member_general_meeter
    # general_bookmark             pc_member_general_bookmark
    # general_discussion           pc_member_general_discussion
    # chat_nick                    pc_chat_nick
    # prefered_chat                -
    # prefered_im                  -
    # newsmail                     pc_member_newsmail_level
    # show_complexity              pc_member_show_complexity_level
    # show_detail                  pc_member_show_detail_level
    # show_edit                    pc_member_show_edit_level
    # show_style                   pc_show_style
    # name_prefix                  -
    # name_given                   name_given
    # name_middle                  name_middle
    # name_family                  name_family
    # name_suffix                  -
    # bdate_ymd_year               pc_bdate_year
    # bdate_ymd_month              -
    # bdate_ymd_day                -
    # bdate_hms_hour               -
    # bdate_hms_minute             -
    # bdate_ymd_timezone           -
    # gender                       is
    # home_online_uri              has_virtual_address
    # home_online_email            - (only use real emails from now)
    # home_online_icq              has_virtual_address
    # home_online_aol              -
    # home_online_msn              has_virtual_address
    # home_tele_phone              has_virtual_address
    # home_tele_phone_comment      description
    # home_tele_mobile             has_virtual_address
    # home_tele_mobile_comment     description
    # home_tele_fax                -
    # home_tele_fax_comment        -
    # home_postal_name             -
    # home_postal_street           - (see ContactLocation GAF Arg : 3)
    # home_postal_visiting         -
    # home_postal_city             -
    # home_postal_code             in_place
    # home_postal_country          -
    # presentation                 description
    # statement                    -
    # geo_precision                -
    # geo_x                        geo_x
    # geo_y                        geo_y
    # member_topic                 pc_old_topic_id
    # present_intrests             pc_member_present_interests
    # member_payment_period_length pc_member_payment_period_length
    # member_payment_period_expire pc_member_payment_period_expire
    # member_payment_period_cost   pc_member_payment_period_cost
    # member_payment_level         -
    # member_payment_total         pc_member_payment_total
    # chat_level                   pc_member_chat_level
    # present_contact_public       pc_member_present_contact_public
    # show_level                   pc_member_show_level
    # present_gifts                pc_member_present_gifts
    # newsmail_latest              -
    # im_threshold                 -
    # member_comment_admin         admin_comment
    # sys_level                    -
    # home_online_skype            has_virtual_address
    # present_blog                 pc_member_present_blog

    my $virtual_address =
      $R->find_set({
		    label => 'virtual_address',
		    scof => $C_text,
		    admin_comment => "Similar to Cycs Computer network contact address. The collection of unique ID strings that are used as addresses on a computer network. This includes e-mail addresses, URLs, ICQ addresses, and so on. (But we also include telephone addresses)",
		    cyc_id => 'ComputerNetworkContactAddress',
		   });

    $C_email_address->update({scof => $virtual_address});
    $C->get('file')->update({scof => $virtual_address});
    $C_url->update({scof => $virtual_address});
    $C_phone_number->update({scof => $virtual_address});

    my $im_contact_address =
      $R->find_set({
		    label => 'im_contact_address',
		    scof => $virtual_address,
		    admin_comment => "Instant Messenger program protocol contact address. OpenCyc 1.0 has a InstantMessengerProgram but not corresponding MachineProtocol or ComputerNetworkContactAddress.",
		   });

    my $address_icq =
      $R->find_set({
		    label => 'address_icq',
		    scof => $im_contact_address,
		   });

    my $address_msn =
      $R->find_set({
		    label => 'address_msn',
		    scof => $im_contact_address,
		   });

    my $address_skype =
      $R->find_set({
		    label => 'address_skype',
		    scof => $im_contact_address,
		   });

    my $address_phone_stationary =
      $R->find_set({
		    label => 'address_phone_stationary',
		    scof => $C_phone_number,
		   });

    my $address_phone_mobile =
      $R->find_set({
		    label => 'address_phone_mobile',
		    scof => $C_phone_number,
		   });


######################


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

    my $has_virtual_address =
      $R->find_set({
		    label => 'has_virtual_address',
		    is => $C_predicate,
		    domain => $ia,
		    range => $virtual_address,
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
		    range => $C_text,
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
		    scof => $individual,
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

    my $style_blue =
      $R->find_set({
		    name => 'blue',
		    is => $pc_website_style,
		   });

    my $style_light =
      $R->find_set({
		    name => 'light',
		    is => $pc_website_style,
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


    my $pc_bdate_year =
      $R->find_set({
		    label => 'pc_bdate_year',
		    is => $C_predicate,
		    domain => $person,
		    range => $C_int,
		    admin_comment => "Old member.bdate_ymd_year. Year of birth",
		   });


    my $geo_x =
      $R->find_set({
		    label => 'geo_x',
		    is => $C_predicate,
		    domain => $spatial_thing,
		    range => $C_float,
		    admin_comment => "Latitude",
		   });

    my $geo_y =
      $R->find_set({
		    label => 'geo_y',
		    is => $C_predicate,
		    domain => $spatial_thing,
		    range => $C_float,
		    admin_comment => "Longitude",
		   });

    my $pc_member_present_interests =
      $R->find_set({
		    label => 'pc_member_present_interests',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.present_intrests",
		   });


    my $pc_member_payment_period_length =
      $R->find_set({
		    label => 'pc_member_payment_period_length',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.member_payment_period_length",
		   });

    my $pc_member_payment_period_expire =
      $R->find_set({
		    label => 'pc_member_payment_period_expire',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_date,
		    admin_comment => "Old member.member_payment_period_expire",
		   });

    my $pc_member_payment_period_cost =
      $R->find_set({
		    label => 'pc_member_payment_period_cost',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.member_payment_period_cost",
		   });

    my $pc_member_payment_total =
      $R->find_set({
		    label => 'pc_member_payment_total',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.member_payment_total",
		   });

    my $pc_member_chat_level =
      $R->find_set({
		    label => 'pc_member_chat_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.chat_level",
		   });

    my $pc_member_present_contact_public =
      $R->find_set({
		    label => 'pc_member_present_contact_public',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.present_contact_public",
		   });

    my $pc_member_show_level =
      $R->find_set({
		    label => 'pc_member_show_level',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.show_level",
		   });

    my $pc_member_present_gifts =
      $R->find_set({
		    label => 'pc_member_present_gifts',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.present_gifts",
		   });

    my $pc_member_present_blog =
      $R->find_set({
		    label => 'pc_member_present_blog',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_int,
		    admin_comment => "Old member.present_blog",
		   });




    my $person_type_by_culture =
      $R->find_set({
		    label => 'person_type_by_culture',
		    admin_comment => "A collection of collections. Each instance of PersonTypeByCulture is the collection of all and only those persons who participate (see cultureParticipants) in some particular human culture. Examples include FrenchPerson and EthnicGroupOfAustralianAborigines.",
		    cyc_id => 'PersonTypeByCulture',
		    is => $class,
		   });

    my $person_type_by_gender =
      $R->find_set({
		    label => 'person_type_by_gender',
		    admin_comment => "Each instance of PersonTypeByGender is the collection of all Persons of a particular gender, understood as a set of attitudes, beliefs, and behaviors (and not strictly a matter of one's biological sex).",
		    scof => $person_type_by_culture,
		    cyc_id => 'PersonTypeByGender',
		    pc_old_topic_id => 184438,
		   });

    my $masculine_person =
      $R->find_set({
		    label => 'masculine_person',
		    admin_comment => "A PersonTypeByGender (q.v.). MasculinePerson is the collection of all Persons of masculine gender. Note that a human MasculinePerson is typically, but not necessarily, a MaleHuman (c.f.).",
		    scof => $person,
		    cyc_id => 'MasculinePerson',
		   });

    my $femenine_person =
      $R->find_set({
		    label => 'femenine_person',
		    admin_comment => "A PersonTypeByGender (q.v.). FemininePerson is the collection of all Persons of feminine gender. Note that a human FemininePerson is typically, but not necessarily, a FemaleHuman (c.f.).",
		    scof => $person,
		    cyc_id => 'FemininePerson',
		   });





    # INTEREST predicates
    #
    # belief              pci_belief
    # knowledge           pci_knowledge
    # theory              pci_theory
    # skill               pci_skill
    # practice            pci_practice
    # editor              pci_editor
    # helper              pci_helper
    # meeter              pci_meeter
    # bookmark            pci_bookmark
    # visit_latest        -
    # visit_version       -
    # intrest_updated     -
    # experience          pci_experience
    # intrest_description description on interested_in arc
    # intrest_defined     pci_defined on interested_in arc
    # intrest_connected   pci_connected on interested_in arc
    # intrest             interested_in

    my $pci_belief =
      $R->find_set({
		    label => 'pci_belief',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $believable,
		    admin_comment => "Old intrest.belief",
		   });

    my $pci_knowledge =
      $R->find_set({
		    label => 'pci_knowledge',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_resource,
		    admin_comment => "Old intrest.knowledge",
		   });

    my $pci_theory =
      $R->find_set({
		    label => 'pci_theory',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_resource,
		    admin_comment => "Old intrest.theory",
		   });

    my $pci_skill =
      $R->find_set({
		    label => 'pci_skill',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $practisable,
		    admin_comment => "Old intrest.skill",
		   });

    my $pci_practice =
      $R->find_set({
		    label => 'pci_practice',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $practisable,
		    admin_comment => "Old intrest.practice",
		   });

    my $pci_editor =
      $R->find_set({
		    label => 'pci_editor',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_resource,
		    admin_comment => "Old intrest.editor",
		   });

    my $pci_helper =
      $R->find_set({
		    label => 'pci_helper',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_resource,
		    admin_comment => "Old intrest.helper",
		   });

    my $pci_meeter =
      $R->find_set({
		    label => 'pci_meeter',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_resource,
		    admin_comment => "Old intrest.meeter",
		   });

    my $pci_bookmark =
      $R->find_set({
		    label => 'pci_bookmark',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $C_resource,
		    admin_comment => "Old intrest.bookmark",
		   });

    my $pci_experience =
      $R->find_set({
		    label => 'pci_experience',
		    is => $C_predicate,
		    domain => $C_login_account,
		    range => $experiencable,
		    admin_comment => "Old intrest.experience",
		   });

    my $pci_defined =
      $R->find_set({
		    label => 'pci_defined',
		    is => $C_predicate,
		    domain => $C_arc,
		    range => $C_int,
		    admin_comment => "Old intrest.intrest_defined to be used on interested_in arcs",
		   });

    my $pci_connected =
      $R->find_set({
		    label => 'pci_connected',
		    is => $C_predicate,
		    domain => $C_arc,
		    range => $C_int,
		    admin_comment => "Old intrest.intrest_connected to be used on interested_in arcs",
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
     27 => ['has_virtual_address', $ia, $C_phone_number],
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

    my $ortl = $odbix->select_key('reltype','from reltype');

    foreach my $rtid ( sort keys %$arctype_map )
    {
	my $def = $arctype_map->{$rtid} or next;

	unless( ref $def )
	{
	    $def = [$def];
	}

	my( $pred_name, $domain, $range,
	    $pred_name2, $domain2, $range2
	  ) = @$def;
	$range ||= $C_resource;

	my $ort = $ortl->{$rtid};

	# TODO: set lang to sv
	my $name_rel = $ort->{'rel_name'};
	my $name_rev = $ort->{'rev_name'};
	my $desc = $ort->{'reltype_description'};

	my $predl = $R->find({label=>$pred_name});
	my $pred;
	if( $predl->size )
	{
	    $pred = $predl->get_first_nos;
	    $pred->add({
			pc_old_arctype_id => $rtid,
			name => $name_rel,
		       });
	}
	else
	{
	    $pred = $R->find_set({label => $pred_name,
				  is => $C_predicate,
				  pc_old_arctype_id => $rtid,
				  name => $name_rel,
				  range => $range,
				 });

	    if( $desc )
	    {
		$pred->add({ admin_comment => $desc });
	    }
	}


	if( $domain )
	{
	    $pred->add({ domain => $domain });
	}

	if( $name_rev )
	{
	    $pred->add({ name_rev => $name_rev });
	}
    }


# TODO: Convert reltype 25 zipcode to geo-tree placement
# TODO: Convert reltype 26 city to geo-tree placement




    # LOCATIONS
    #
    # country            loc_country
    # county             loc_county
    # municipality       loc_municipality
    # city               loc_city
    # parish             loc_parish
    # zipcode            loc_zipcode
    # street             loc_street
    # address            loc_address

    my $planet_earth =
      $R->find_set({
		    label => 'planet_earth',
		    is => $location,
		    pc_old_topic_id => 144335,
		    cyc_id => 'PlanetEarth',
		   });

    my $sweden =
      $R->find_set({
		    label => 'sweden',
		    is => $location,
		    pc_old_topic_id => 397071,
		    is_part_of => $planet_earth,
		   });

    my $country =
      $R->find_set({
		    label => 'loc_country',
		    scof => $location,
		    pc_old_topic_id => 129520,
		    cyc_id => 'Country',
		   });
    my $county =
      $R->find_set({
		    label => 'loc_county',
		    scof => $location,
		    pc_old_topic_id => 541764,
		    cyc_id => 'County',
		   });

    my $municipality =
      $R->find_set({
		    label => 'loc_municipality',
		    scof => $location,
		    cyc_id => 'Municipality',
		    can_be_part_of => $county,
		   });

    my $city =
      $R->find_set({
		    label => 'loc_city',
		    scof => $location,
		    pc_old_topic_id => 129524,
		    cyc_id => 'City',
		    can_be_part_of => $municipality,
		   });

    my $parish =
      $R->find_set({
		    label => 'loc_parish',
		    scof => $location,
		    can_be_part_of => $municipality,
		   });

    my $zipcode =
      $R->find_set({
		    label => 'loc_zipcode',
		    scof => $location,
		    admin_comment => "A specialization of ContactInfoString. Each instance of PostalCode is a character string used by a postal service to designate a particular geographic area.",
		    cyc_id => 'InternationalPostalCode',
		    can_be_part_of => $city,
		   });



    my %countyidx;
  COUNTY:
    {
	my $countylist = $odbix->select_list('from county');
	my( $countyrec, $countyerror ) = $countylist->get_first;
	while(! $countyerror )
	{
	    my $id = sprintf "%.2d", $countyrec->{'county'};
	    $countyidx{ $id } =
	      $R->create({
			  name => $countyrec->{county_name},
			  code => $id,
			  name_short => $countyrec->{county_code},
			  is => $county,
			  is_part_of => $sweden,
			 });
	}
	continue
	{
	    ( $countyrec, $countyerror ) = $countylist->get_next;
	}
    }

    my %cityidx;
  CITY:
    {
	debug "retrieving list of all cities";
	my $citylist = $odbix->select_list('from city');
	my( $cityrec, $cityerror ) = $citylist->get_first;
	while(! $cityerror )
	{
	    $cityidx{ $cityrec->{'city'} } =
	      $R->create({
			  name => ucfirst lc $cityrec->{city_name},
			  is => $city,
			  is_part_of => $countyidx{ $cityrec->{city_l} },
			  geo_x => $cityrec->{city_x},
			  geo_y => $cityrec->{city_y},
			 });
	}
	continue
	{
	    ( $cityrec, $cityerror ) = $citylist->get_next;
	}
    }

    my %munidx;
#  MUNICIPALITY:
#    {
#	debug "retrieving list of all municipalities";
#	my $munlist = $odbix->select_list('from municipality');
#	my( $munrec, $munerror ) = $munlist->get_first;
#	while(! $munerror )
#	{
#	    $munidx{ $munrec->{'municipality'} } =
#	      $R->create({
#			  name => $munrec->{municipality_name},
#			  is => $municipality,
#			  code => $munrec->{municipality},
#			  is_part_of => $countyidx{ $munrec->{municipality_l} },
#			 });
#	}
#	continue
#	{
#	    ( $munrec, $munerror ) = $munlist->get_next;
#	}
#    }

    my %parishidx;
#  PARISH:
#    {
#	debug "retrieving list of all parishes";
#	my $parishlist = $odbix->select_list('from parish');
#	my( $parishrec, $parisherror ) = $parishlist->get_first;
#	while(! $parisherror )
#	{
#	    $parishidx{ $parishrec->{'parish'} } =
#	      $R->create({
#			  name => $parishrec->{parish_name},
#			  is => $parish,
#			  code => $parishrec->{parish},
#			  is_part_of => $munidx{ $parishrec->{parish_lk} },
#			 });
#	}
#	continue
#	{
#	    ( $parishrec, $parisherror ) = $parishlist->get_next;
#	}
#    }


    # Now bring the official codes up to date for 2009
    #
    debug "Setting up LKF 2009";
    open LKF, '<', $Para::CFG->{'pc_root'}.'/doc/lkf2009.txt' or die $!;
    while(my $line = <LKF>)
    {
	chomp $line;
	next unless $line;

	utf8::decode( $line );
	my( $key, $val ) = split /=/, $line;
	my( $l, $k, $f ) = $key =~ /^(..)(..)?(..)?/;

	if( $f )
	{
	    debug "F $key = $val";
	    $parishidx{ $key } =
	      $R->create({
			  name => $val,
			  is => $parish,
			  code => $key,
			  is_part_of =>  $munidx{ $l.$k },
			 });
	}
	elsif( $k )
	{
	    debug "K $key = $val";
	    $munidx{ $key } =
	      $R->create({
			  name => $val,
			  is => $municipality,
			  code => $key,
			  is_part_of => $countyidx{ $l },
			 });
	}
	elsif( $l )
	{
	    debug "L $key = $val";
	    # Done above
	}
	else
	{
	    die "Could not parse key $key";
	}
    }








  ZIPCODE:
    {
	my %trans =
	  (
	   1917 => '0331',
	  );

	debug "retrieving list of all zipcodes";
	my $ziplist = $odbix->select_list('from zip');
	my( $ziprec, $ziperror ) = $ziplist->get_first;
	while(! $ziperror )
	{
	    my $zip_city = $ziprec->{zip_city};
	    my $zip_lk = sprintf "%.4d", $ziprec->{zip_lk};

	    if( $trans{$zip_lk} ){ $zip_lk = $trans{$zip_lk} };


	    unless( $cityidx{ $zip_city } )
	    {
		throw "City $zip_city not found in city index";
	    }

	    unless( $munidx{ $zip_lk } )
	    {
		throw "Municipality $zip_lk not found in mun index";
	    }

	    $R->create({
			is => $zipcode,
			code => $ziprec->{zip},
			is_part_of => [
				       $cityidx{ $zip_city },
				       $munidx{ $zip_lk },
				      ],
			geo_x => $ziprec->{zip_x},
			geo_y => $ziprec->{zip_y},
		       });
	}
	continue
	{
	    ( $ziprec, $ziperror ) = $ziplist->get_next;
	}
    }


# TODO: Import street and address

#    # ADDRESS
#    #
#    # address_street     -
#    # address_nr_from    pc_address_nr_from
#    # address_nr_to      pc_address_nr_to
#    # address_step       pc_address_nr_step
#    # address_zip        is_part_of
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


################################
# ApartmentBuilding
# ModernHumanResidence
# HumanResidence
# PhysicalContactLocation
# ContactLocation
# PartiallyTangible



# TODO: Import payment

# TODO: Import score

# TODO: Import slogan


    # TS
    #
    # ts_entry     -
    # ts_topic     -
    # ontopic      -
    # completeness -
    # correctness  -
    # delight      -
    # ts_created   -
    # ts_changedby -
    # ts_updated   -
    # ts_status    -
    # ts_comment   -
    # ts_score     -
    # ts_active    -
    # ts_createdby -

    my $cia =
      $R->find_set({
		    label => 'contains_information_about',
		    is => $C_predicate,
		    domain => $media,
		    range => $C_resource,
		    cyc_id => 'containsInformationAbout',
		    admin_comment => "Old TS. This predicate relates sources of information to their topics.",
		   });


    # TALIAS
    #
    # talias_t         -
    # talias           -
    # talias_updated   -
    # talias_changedby -
    # talias_status    -
    # talias_autolink  pca_autolink
    # talias_index     pca_index
    # talias_active    -
    # talias_created   -
    # talias_createdby -
    # talias_urlpart   url_part
    # talias_language  is_of_language

    my $pca_autolink =
      $R->find_set({
		    label => 'pca_autolink',
		    is => $C_predicate,
		    domain => $C_text,
		    range => $C_bool,
		    admin_comment => "Old talias.talias_autolink",
		   });

    my $pca_index =
      $R->find_set({
		    label => 'pca_index',
		    is => $C_predicate,
		    domain => $C_text,
		    range => $C_bool,
		    admin_comment => "Old talias.talias_index",
		   });






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






######## Importing member
  MEMBER:
    {
	my %map =
	  (
	   pc_member_id => 'member',
	   name_short => 'nickname',
	   pc_member_level => 'member_level',
	   pc_latest_in => 'latest_in',
	   pc_latest_out => 'latest_out',
	   pc_latest_host => 'latest_host',
	   sys_username => 'sys_uid',
	   pc_sys_logging => 'sys_logging',
	   pc_present_contact => 'present_contact',
	   pc_present_activity => 'present_activity',
	   pc_member_general_belief => 'general_belief',
	   pc_member_general_theory => 'general_theory',
	   pc_member_general_practice => 'general_practice',
	   pc_member_general_editor => 'general_editor',
	   pc_member_general_helper => 'general_helper',
	   pc_member_general_meeter => 'general_meeter',
	   pc_member_general_bookmark => 'general_bookmark',
	   pc_member_general_discussion => 'general_discussion',
	   pc_chat_nick => 'chat_nick',
	   pc_member_newsmail_level => 'newsmail',
	   pc_member_show_complexity_level => 'show_complexity',
	   pc_member_show_detail_level => 'show_detail',
	   pc_member_show_edit_level => 'show_edit',
	   pc_show_style => 'show_style',
	   name_given => 'name_given',
	   name_middle => 'name_middle',
	   name_family => 'name_family',
	   pc_bdate_year => 'bdate_ymd_year',
	   description => 'presentation',
	   geo_x => 'geo_x',
	   geo_y => 'geo_y',
	   pc_old_topic_id => 'member_topic',
	   pc_member_present_interests => 'present_intrests',
	   pc_member_payment_period_length => 'member_payment_period_length',
	   pc_member_payment_period_expire => 'member_payment_period_expire',
	   pc_member_payment_period_cost => 'member_payment_period_cost',
	   pc_member_payment_total => 'member_payment_total',
	   pc_member_chat_level => 'chat_level',
	   pc_member_present_contact_public => 'present_contact_public',
	   pc_member_show_level => 'show_level',
	   pc_member_present_gifts => 'present_gifts',
	   admin_comment => 'member_comment_admin',
	   pc_member_present_blog => 'present_blog',
	  );

	my %va =
	  (
	   sys_email => $C_email_address,
	   home_online_uri => $C_url,
	   home_online_icq => $address_icq,
	   home_online_msn => $address_msn,
	   home_tele_phone => $address_phone_stationary,
	   home_tele_mobile => $address_phone_mobile,
	   home_online_skype => $address_skype,
	  );

	debug "retrieving list of all members";

	my $list = $odbix->select_list('from member where member_level > 4 and member > 0 order by member limit 5');
	my( $rec, $error ) = $list->get_first;
	while(! $error )
	{
	    my %mdata;
	    foreach my $key ( keys %map )
	    {
		$mdata{ $key } = $rec->{ $map{ $key } };
		debug sprintf "%s -> %s: %s\n", $key, $map{ $key }, ($rec->{ $map{ $key } }||'<undef>');
	    }


	    my @virt_adr;
	    foreach my $key ( keys %va )
	    {
		if( $rec->{$key} )
		{
		    my $val = $L->new($rec->{$key},$va{$key});
		    push @virt_adr, $val;
		    debug "Adding virtual address ".$val->sysdesig;
#		    push @virt_adr, $L->new($rec->{$key},$va{$key});
		}
	    }

	    $mdata{'has_virtual_address'} = \@virt_adr;

	    my @is = ($C_login_account, $person);
	    if( $rec->{'gender'} eq 'F' )
	    {
		push @is, $femenine_person;
	    }
	    elsif( $rec->{'gender'} eq 'M' )
	    {
		push @is, $masculine_person;
	    }

	    $mdata{'is'} = \@is;


	    my $m = $R->create( {created=>$rec->{'member_created'}} );
	    $m->add( \%mdata, {write_access=>$m} );

	    ### defailt email
	    #
	    if( my $sysmail_arc = $m->first_arc('has_virtual_address',
						{'is'=>$C_email_address}) )
	    {
		$sysmail_arc->set_weight( 10, {force_same_version=>1} );
		debug sprintf "Setting weight of %s to 10", $sysmail_arc->desig;
	    }
	    my $malist = $odbix->select_list('from mailalias where mailalias_member=?', $rec->{'member'} );
	    my( $marec, $maerror ) = $malist->get_first;
	    while(! $maerror )
	    {
		my $ea = $L->new($marec->{'mailalias'},$C_email_address);
		$m->add({'has_virtual_address'=>$ea}, {write_access=>$m});
	    }
	    continue
	    {
		( $marec, $maerror ) = $malist->get_next;
	    }

	    ### default nick
	    #
	    my $nick_arc = $m->first_arc('name_short');
	    $nick_arc->set_weight( 10, {force_same_version=>1} );
	    debug sprintf "Setting weight of %s to 10", $nick_arc->desig;
	    my $nick = $nick_arc->value;
	    my $nicklist = $odbix->select_list('from nick where nick_member=?', $rec->{'member'} );
	    my( $nickrec, $nickerror ) = $nicklist->get_first;
	    while(! $nickerror )
	    {
		my $anick = $nickrec->{'uid'};
		next if $anick eq 'root';
		next if valclean($anick) eq $nick->clean_plain;
		my $nick = $L->new($nickrec->{'uid'},$C_text);
		$m->add({'name_short'=>$nick}, {write_access=>$m});
	    }
	    continue
	    {
		( $nickrec, $nickerror ) = $nicklist->get_next;
	    }

	    ### Password
	    #
	    my $pwdrec = $odbix->select_record('from passwd where passwd_member=?', $rec->{'member'} );
	    my $pwd = $L->new($pwdrec->{'passwd'},$C_password);
	    #### TODO:  Waiting with password til they get more secure
#	    $m->add({'has_password'=>$pwd}, {read_access=>$m,write_access=>$m});
	}
	continue
	{
	    ( $rec, $error ) = $list->get_next;
	}
    };



######## Importing topic
  TOPIC:
    {
        #  t                        pc_old_topic_id
        #  t_pop                    -
        #  t_size                   -
        #  t_created                node(created)
        #  t_createdby              node(created)
        #  t_updated                -
        #  t_changedby              -
        #  t_status                 ...
        #  t_title                  name
        #  t_text                   description
        #  t_entry                  ...
        #  t_entry_parent           is_part_of
        #  t_entry_next             ... (use weight)
        #  t_entry_imported         -
        #  t_file                   pc_public_path
        #  t_class                  ...
        #  t_ver                    -
        #  t_replace                -
        #  t_connected              pc_connected
        #  t_active                 -
        #  t_connected_status       -
        #  t_oldfile                -
        #  t_urlpart                url_part
        #  t_title_short_old        -
        #  t_title_short_plural_old -
        #  t_comment_admin          admin_comment
        #  t_published              -
        #  t_title_short            name_short
        #  t_title_short_plural     ...
        #  t_vacuumed               -

	## t_status: http://old.paranormal.se/meta/devel/entry_status.html

	debug "retrieving list of all topics";
	my $list = $odbix->select_list('from t where t_status > 1 order by t');
	my( $rec, $error ) = $list->get_first;
	while(! $error )
	{
	    my $created_by = $R->get({pc_member_id => $rec->{'t_createdby'}});

	    my %prop =
	      (
	       pc_old_topic_id => $rec->{'t'},
	       created => $rec->{'t_created'},
	       created_by => $created_by,
	       name => $rec->{'t_title'},
	       description => $rec->{'t_text'},
	      );

	    if( my $pc_public_path = $rec->{'t_file'} )
	    {
		$prop{ pc_public_path } = $pc_public_path;
	    }

	    if( my $pc_connected = $rec->{'t_connected'} )
	    {
		$prop{ pc_connected } = $pc_connected;
	    }

	    if( my $url_part = $rec->{'t_urlpart'} )
	    {
		$prop{ url_part ) = $url_part;
	    }

	    if( my $admin_comment = $rec->{'t_comment_admin'} )
	    {
		$prop{ admin_comment } = $admin_comment;
	    }

	    if( my $title_short = $rec->{'t_title_short'} )
	    {
		$prop{ title_short }  = $title_short;
	    }

	    if( my $t_status = $rec->{'t_status'} )
	    {
	    }

	    last;
	}
	continue
	{
	    ( $rec, $error ) = $list->get_next;
	}
    };






    $Para::Frame::REQ->done;
    $req->user->set_default_propargs(undef);

    print "Done!\n";

    return;
}

1;

# Handled tables
#
#  address      | ?
#  city         | !
#  country      | X
#  county       | !
#  domain       | X
#  event        | X
#  history      | X
#  intrest      | -
#  ipfilter     | ?
#  mailalias    | !
#  mailr        | X
#  media        | -
#  member       | !
#  memberhost   | X
#  memo         | X
#  municipality | !
#  nick         | !
#  parish       | !
#  passwd       | -
#  payment      | ?
#  plan         | X
#  publ         | X
#  rel          | -
#  reltype      | !
#  score        | ?
#  slogan       | ?
#  street       | ?
#  t            | -
#  talias       | -
#  ts           | -
#  zip          | !

