package Para::Setup;
#==================================================== -*- cperl -*- ==========
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
#=============================================================================

=head1 NAME

Para::Setup

=cut

use 5.010;
use strict;
use warnings;

use Carp qw( confess );
use IO::File;
use utf8;
use DBI;
use Carp qw( croak );
use DateTime::Format::Pg;

use Para::Frame::Utils qw( debug datadump throw validate_utf8 catch create_dir );
use Para::Frame::Time qw( now );

use Rit::Base::Utils qw( valclean parse_propargs query_desig );
use Rit::Base::Setup;

our( %TOPIC, %RELTYPE, @AUTOCREATED, $R, $L, $LOG, $odbix, $class, $individual, $pc_topic, $pc_entry, $pc_featured_topic, $word_plural, $information_store, $mia, $organization, $ia, $practisable );

sub dlog;

sub setup_db
{
    unless( $ARGV[0] and ($ARGV[0] eq 'setup_db') )
    {
	return;
    }

    my $dbix = $Rit::dbix;
    my $dbh = $dbix->dbh;
    my $now = DateTime::Format::Pg->format_datetime(now);

    $R = Rit::Base->Resource;
    my $C = Rit::Base->Constants;
    $L = Rit::Base->Literal;

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

    $odbix = Para::Frame::DBIx->
      new({connect =>$Para::CFG->{'dbconnect_old'}});
    $odbix->connect;
    my $odbh = $odbix->dbh;



    my $C_login_account     = $C->get('login_account');
    $ia                  = $C->get('intelligent_agent');
    my $C_predicate         = $C->get('predicate');
    $class                  = $C->get('class');
    my $C_resource          = $C->get('resource');
    my $C_arc               = $C->get('arc');

    my $C_int   = $C->get('int');
    my $C_float = $C->get('float');
    my $C_bool  = $C->get('bool');
    my $C_date  = $C->get('date');
    my $C_url   = $C->get('url');
    my $C_file   = $C->get('file');
    my $C_website_url   = $C->get('website_url');
    my $C_email_address = $C->get('email_address');
    my $C_text  = $C->get('text');
    my $C_term  = $C->get('term');
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


    ### Open log for important notes
    #
    create_dir( $Para::Frame::CFG->{'dir_log'} );
    my $import_log = $Para::Frame::CFG->{'dir_log'}.'/import.log';
    $LOG = IO::File->new($import_log,">:encoding(UTF-8)") or die "Failed to open $import_log: ".$!;
    $LOG->autoflush(1);
    $LOG->print("Started import log ".scalar(localtime)."\n\n");

    $R->find_set({
		  label => 'pc_old_topic_id',
		  is => $C_predicate,
		  range => $C_int,
		  admin_comment => "Old t.t",
		 });

    $pc->add({pc_old_topic_id => 32574});


    $individual
      = $R->find_set({
		      label => 'individual',
		      admin_comment => "Individual is the collection of all individuals: things that are not sets or collections. Individuals might be concrete or abstract, and include (among other things) physical objects, events, numbers, relations, and groups.",
		      is => $class,
		      has_cyc_id => 'Individual',
		      pc_old_topic_id => 715586,
		     });

    $R->find_set({
		  label => 'pc_old_arctype_id',
		  is => $C_predicate,
		  domain => $C_predicate,
		  range => $C_int,
		  admin_comment => "Old reltype.reltype",
		 });

    $R->find_set({
		  label => 'name_rev',
		  is => $C_predicate,
		  domain => $C_predicate,
		  range => $C_text,
		  admin_comment => "Old reltype.rev_name",
		 });


    $R->find_set({
		  label => 'quoted_is',
		  is => $C_predicate,
		  range => $class,
		  admin_comment => "Referes to the node rather than the thing represented by the node.",
		  has_cyc_id => 'quotedIsa',
		 });


    $class->add({pc_old_topic_id => 9});

    $C_language->add({pc_old_topic_id => 33859});


    #
    # Domains and ranges used for reltypes
    #
    # pct is used as a prefix: paranormal creation topic

    my $spatial_thing
      = $R->find_set({
		      label => 'spatial_thing',
		      admin_comment => "The collection of all things that have a spatial extent or location relative to some other SpatialThing or in some embedding space. Note that to say that an entity is a member of this collection is to remain agnostic about two issues. First, a SpatialThing may be PartiallyTangible (e.g. Texas-State) or wholly Intangible (e.g. ArcticCircle or a line mentioned in a geometric theorem). Second, although we do insist on location relative to another spatial thing or in some embedding space, a SpatialThing might or might not be located in the actual physical universe.",
		      has_cyc_id => 'SpatialThing',
		      scof => $individual,
		      pc_old_topic_id => 715395,
		     });

    my $temporal_thing
      = $R->find_set({
		      label => 'temporal_thing',
		      admin_comment => "This is the collection of all things that have temporal extent or location -- things about which one might sensibly ask 'When?'. TemporalThing thus contains many kinds of things, including events, physical objects, agreements, and pure intervals of time.",
		      has_cyc_id => 'TemporalThing',
		      scof => $individual,
		      pc_old_topic_id => 717756,
		     });

    my $time_interval
      = $R->find_set({
		      label => 'time_interval',
		      admin_comment => "Includes timeintervals like seasons and timepoints like now",
		      has_cyc_id => 'TimeInterval',
		      scof => $temporal_thing,
		     });

    my $temporal_stuff_type
      = $R->find_set({
		      label => 'temporal_stuff_type',
		      admin_comment => "Temporal Thing class",
		      has_cyc_id => 'TemporalStuffType',
		      is => $class,
		     });

    $information_store
      = $R->find_set({
		      label => 'information_store',
		      admin_comment => "Each instance of InformationStore is a tangible or intangible, concrete or abstract repository of information. The information stored in an information store is stored there as a consequence of the actions of one or more agents.",
		      has_cyc_id => 'InformationStore',
		      is => $temporal_stuff_type,
		      scof => $individual,
		      pc_old_topic_id => 4463,
		     });
    my $ais
      = $R->find_set({
		      label => 'ais',
		      admin_comment => "AspatialInformationStore is the collection of all information stores that have no spatial location. Specializations of AspatialInformationStore include ConceptualWork, Microtheory, AbstractInformationStructure, and FieldOfStudy.",
		      has_cyc_id => 'AspatialInformationStore',
		      scof => $information_store,
		      pc_old_topic_id => 710042,
		     });

    # AbstractStructure genls AspatialInformationStore.
    # ContextualizedInformationStructure genls AbstractStructure.
    # AbstractInformationStructure genls AbstractStructure.
    # AbstractVisualStructure genls AbstractStructure.
    # GraphicalStructure genls AbstractVisualStructure.
    # GraphicalAIS genls GraphicalStructure.
    # ComputerAIS genls AbstractInformationStructure.
    # LexicalItem genls AbstractInformationStructure


    my $abis
      = $R->find_set({
		      label => 'abis',
		      admin_comment => "Each instance of AbstractInformationStructure is an abstract individual comprising abstract symbols and relations between them. ABIS includes CharacterString, Sentence, abstract diagrams, graphs, and bit strings.",
		      has_cyc_id => 'AbstractInformationStructure',
		      scof => $ais,
		      pc_old_topic_id => 713793,
		     });

    my $graphical_ais
      = $R->find_set({
		      label => 'graphical_ais',
		      admin_comment => "the collection of all abstract graphical structures that consist of abstract symbols and the relations between them. Each instance of AbstractVisualStructure (AVS) is a structure that can be discerned visually. Any concrete instantiation of a given AVS consists of a particular spatial (or spatio-temporal) arrangement of shapes and/or colors. A given AVS might have multiple instantiations. By the same token, a given concrete visual arrangment (appearing, say, on a sheet of paper or a computer monitor screen) might simultaneously instantiate multiple AVSs, corresponding to different degrees of abstractness.",
		      has_cyc_id => 'GraphicalAIS',
		      scof => $abis,
		      pc_old_topic_id => 713792,
		     });

    my $field_of_study
      = $R->find_set({
		      label => 'field_of_study',
		      admin_comment => "Each instance of FieldOfStudy is a particular area of study, with its own distinctive set of theories, hypotheses, and problems.",
		      has_cyc_id => 'FieldOfStudy',
		      scof => $ais,
		      pc_old_topic_id => 3719,
		     });

    my $belief_system
      = $R->find_set({
		      label => 'belief_system',
		      admin_comment => "A specialization of AspatialInformationStore. Each instance of BeliefSystem is an ideology (systems of belief) in terms of which an agent characterizes (i.e., makes sense of) the world. Instances of BeliefSystem include: Vegetarianism, GermanNaziIdeology, RepublicanPartyIdeology, Communism, Pacifism, Atheism, etc.",
		      has_cyc_id => 'BeliefSystem',
		      scof => $ais,
		      pc_old_topic_id => 387298,
		     });

    my $hypotheis
      = $R->find_set({
		      label => 'hypothesis',
		      scof => $ais,
		      pc_old_topic_id => 133761,
		     });

    my $situation
      = $R->find_set({
		      label => 'situation',
		      admin_comment => "A temporally extended intangible individual. Examples: Gesture, Miracle, Event",
		      has_cyc_id => 'Situation',
		      scof => $temporal_thing,
		      pc_old_topic_id => 81959,
		     });

    # MentalSituation, MentalState, Consciousness, IntentionalMentalSituation

    # See also FieldOfStudy, BeliefSystem, Dream, Meme

    my $pit
      = $R->find_set({
		      label => 'pit',
		      admin_comment => "Each instance of PropositionalInformationThing (or \"PIT\") is an abstract object -- a chunk of information consisting of one or more propositions. The propositional content of a PIT is not essentially encoded in any particular language, and it may be representable in many languages. PITs are used to represent the informational contents of InformationBearingThings.",
		      has_cyc_id => 'PropositionalInformationThing',
		      scof => $ais,
		     });

    # See also MentalInformation, SensoryInformation, Memory,
    # BeliefSystem, PhilosophicalTheory

    my $ibt
      = $R->find_set({
		      label => 'ibt',
		      admin_comment => "InformationBearingThing: A collection of spatially-localized individuals, including various actions and events as well as physical objects. Each instance of InformationBearingThing (or \"IBT\") is an item that contains information (for an agent who knows how to interpret it). Examples: a copy of the novel Moby Dick; a photograph. It is important to distinguish the various specializations of InformationBearingThing from those of AspatialInformationStore (whose instances are the chunks of information instantiated in particular IBTs.",
		      has_cyc_id => 'InformationBearingThing',
		      scof => $information_store,
		      is => $temporal_stuff_type,
		     });
    my $cw
      = $R->find_set({
		      label => 'cw',
		      admin_comment => "ConceptualWork: A specialization of AspatialInformationStore. Each instance of ConceptualWork is a partially abstract work (in the sense that each instance has a beginning in time, but lacks a location in space) which either has an associated AbstractInformationStructure (q.v.) or has a version with an associated AbstractInformationStructure. Conceptual works or versions of conceptual works can be instantiated in instances of InformationBearingThing (q.v.); every such instantiation of a conceptual work will also be an instantiation of an instance of AbstractInformationStructure. Notable specializations of ConceptualWork include ComputerProgram-CW, VisualWork, and Book-CW.",
		      scof => $ais,
		      has_cyc_id => 'ConceptualWork',
		      pc_old_topic_id => 716725,
		     });

    my $media
      = $R->find_set({
		      label => 'media',
		      admin_comment => "Each instance of MediaProduct is an information store created for the purposes of media distribution (see MediaTransferEvent). Specializations of MediaProduct include RecordedVideoProduct, MediaSeriesProduct, WorldWideWebSite and NewsArticle.",
		      scof => [ $information_store, $temporal_thing, $temporal_stuff_type, $cw ],
		      has_cyc_id => 'MediaProduct',
		      pc_old_topic_id => 710085,
		     });

    # See also possessesCopyOf, instantiationOfWork, instantiationOfAIT
    # !!! ibt instantiationOfWork cw
    # !!! ibt instantiationOfAIT ais
    # !!! ibt instantiationOfAIS AbstractInformationStructure
    # !!! ibt pitOfIBT pit
    # !!! ibt containsInfoPropositional-IBT pit
    # !!! cw containsInfoStructure-CW ais
    # !!! cw partialInfoStructureOfCW AbstractStructure
    # !!! pcw topicOfPCW Thing
    # !!! Collection topicOf Thing


##############################################################################

    my $all_abstract
      = $R->find_set({
		      label => 'all_abstract',
		      is => $spatial_thing,
		      is => $temporal_thing,
		      admin_comment => 'The thing that contains the physical universe and all other abstract planes of existence',
		      pc_old_topic_id => 75908,
		     });

# ... remodel...
#    my $psychological_phenomenon
#      = $R->find_set({
#		      label => 'pct_psychological_phenomenon',
#		      scof => $individual,
#		      pc_old_topic_id => 3318,
#		     });
#
#     my $thought
#      = $R->find_set({
#		      label => 'pct_thought',
#		      is => $psychological_phenomenon,
#		      pc_old_topic_id => 148549,
#		      has_wikipedia_id => 'Thought',
#		     });
#
#    my $perspective
#      = $R->find_set({
#		      label => 'pct_perspective',
#		      scof => $thought,
#		     });

    my $physical_organism
      = $R->find_set({
		      label => 'physical_organism',
		      admin_comment => "Physical life form",
		      scof => $spatial_thing,
		      has_cyc_id => 'Organism-Whole',
		      pc_old_topic_id => 9052,
		     });

    my $agent_generic
      = $R->find_set({
		      label => 'agent_generic',
		      admin_comment => "Each instance of Agent-Generic is a being that has desires or intentions, and the ability to act on those desires or intentions. Instances of Agent-Generic may be individuals (see the specialization IndividualAgent) or they may consist of several Agent-Generics operating together (see the specialization MultiIndividualAgent).",
		      has_cyc_id => 'Agent-Generic',
		      scof => $temporal_thing,
		      pc_old_topic_id => 718806,
		     });

    $ia->add({
	      scof => [$information_store, $agent_generic],
	      pc_old_topic_id => 715488,
	     });

    my $legal_agent
      = $R->find_set({
		      label => 'legal_agent',
		      admin_comment => "Each instance of LegalAgent is an agent who has some status in a particular legal system. At the very least, such an agent is recognized by some legal authority as having some kinds of rights and/or responsibilities as an agent (e.g., citizens of Germany), or as being subject to certain restrictions and penalties (e.g., a company that has been blacklisted by Iraq).",
		      scof => $ia,
		      has_cyc_id => 'LegalAgent',
		     });

    my $person
      = $R->find_set({
		      label => 'person',
		      admin_comment => "An individual intelligent agent",
		      scof => [$legal_agent, $physical_organism],
		      has_cyc_id => 'Person',
		      pc_old_topic_id => 2140,
		      has_wikipedia_id => 'Person',
		     });

    my $life_form
      = $R->find_set({
		      label => 'life_form',
		      admin_comment => "Any living organism in abstract sense, including non-material non-localized life forms",
		      scof => $agent_generic,
		      pc_old_topic_id => 398,
		     });

    $mia
      = $R->find_set({
		      label => 'mia',
		      admin_comment => "MultiIndividualAgent. A type of Agent-Generic that may or may not be intelligent. Usually constitutes some type of group, such as a LegalCorporation, CrowdOfPeople or Organization",
		      has_cyc_id => 'MultiIndividualAgent',
		      pc_old_topic_id => 143,
		      scof => $agent_generic,
		     });

    $organization
      = $R->find_set({
		      label => 'organization',
		      admin_comment => "The collection of groups of IntelligentAgents whose members operate together to form a kind of collective. Groups of this sort satisfy the minimal condition for intelligent agency, viz., they are capable of acting purposefully",
		      has_cyc_id => 'Organization',
		      pc_old_topic_id => 696050,
		      scof => [$mia, $ia],
		     });

    $pc->add({is=>$organization}); # Paranormal Sweden is a Multi-individual agent

    my $legal_corporation
      = $R->find_set({
		      label => 'legal_corporation',
		      admin_comment => "The collection of all Organizations which have been incorporated in accordance with the laws of a jurisdiction. Each instance of LegalCorporation is a legal entity distinct from its owners and employees, and is afforded certain powers both by law and by its incorporating documents.",
		      has_cyc_id => 'LegalCorporation',
		      pc_old_topic_id => 499235,
		      scof => [$organization, $legal_agent],
		     });

    my $product
      = $R->find_set({
		      label => 'product',
		      admin_comment => "Each instance of Product is a TemporalThing that is, or was at one time, offered for sale or performed as a commercial service, or was produced with the intent of being offered for sale.",
		      has_cyc_id => 'Product',
		      pc_old_topic_id => 422155,
		      scof => $individual,
		      has_wikipedia_id => 'Product_(business)',
		     });

    my $service_product
      = $R->find_set({
		      label => 'service_product',
		      admin_comment => "The collection of all ServiceEvents for which payment is made.",
		      has_cyc_id => 'ServiceProduct',
		      scof => $product,
		     });

    my $book_cw
      = $R->find_set({
		      label => 'book_cw',
		      admin_comment => "Each instance of Book-CW is an abstract work intended to be instantiated as a book of some sort. Instances of Book-CW may be intended to be instantiated in any book format: hardcopy (see BookCopy), electronic, audio tape, etc.",
		      scof => [$cw, $product],
		      has_cyc_id => 'Book-CW',
		      pc_old_topic_id => 443,
		     });

    my $license
      = $R->find_set({
		      label => 'license',
		      admin_comment => "Each element of License-LegalAgreement is a credential issued by a granting authority and recorded in some tangible document (see License-IBO), which authorizes the agent to whom it is issued to perform actions of a certain kind.",
		      has_cyc_id => 'License-LegalAgreement',
		      pc_old_topic_id => 144544,
		      scof => $cw,
		      has_wikipedia_id => 'License',
		     });

    my $permission_ibt
      = $R->find_set({
		      label => 'permission_ibt',
		      admin_comment => "The InformationBearingThing that holds the persmission",
		      scof => $ibt,
		      pc_old_topic_id => 387092,
		     });

    my $believable
      = $R->find_set({
		      label => 'pct_believable',
		      admin_comment => "Stuff that an IntelligentAgent can believe in. Stuff there it may be of interest to know if someone believes in it.",
		      pc_old_topic_id => 10,
		      is => $class,
		     });

    $practisable
      = $R->find_set({
		      label => 'pct_practisable',
		      admin_comment => "Stuff that an IntelligentAgent can be involved in or use (IntelligentAgentActivity), like therapies, religions or skills",
		      pc_old_topic_id => 11,
		      scof => $ais,
		     });

    my $experiencable
      = $R->find_set({
		      label => 'pct_experiencable',
		      admin_comment => "Stuff that a person can experience, tat would be of interest",
		      pc_old_topic_id => 12,
		      is => $class,
		     });

#    my $person_type
#      = $R->find_set({
#		      label => 'pct_person_type',
#		      admin_comment => "PersonType",
#		      scof => $class,
#		     });


    my $location
      = $R->find_set({
		      label => 'location',
		      admin_comment => "Each instance of Place is a spatial thing which has a relatively permanent location.",
		      scof => [$spatial_thing, $temporal_thing],
		      pc_old_topic_id => 3322,
		      has_cyc_id => 'Place',
		      has_wikipedia_id => 'Location_(geography)',
		     });

    my $concart
      = $R->find_set({
		      label => 'concart',
		      admin_comment => "A ConstructionArtifact is a place built  by humans.",
		      scof => $location,
		      has_cyc_id => 'ConstructionArtifact',
		     });

    my $portable_object
      = $R->find_set({
		      label => 'portable_object',
		      admin_comment => "Each instance of PortableObject is a tangible object that is not \"fastened down\" and is light enough for an average human (or, more to the point, for its average intended user) to move easily.",
		      scof => [$spatial_thing, $temporal_thing],
		      has_cyc_id => 'PortableObject',
		      pc_old_topic_id => 3323,
		     });

    my $animal_body_part
      = $R->find_set({
		      label => 'animal_body_part',
		      admin_comment => "Each instance of AnimalBodyPart is an anatomical part of some living animal, and thus is itself an instance of BiologicalLivingObject (q.v).",
		      has_cyc_id => 'AnimalBodyPart',
		      scof => $portable_object,
		      pc_old_topic_id => 35830,
		     });

    my $retail_store
      = $R->find_set({
		      label => 'retail_store',
		      admin_comment => "A specialization of RetailOrganization. Each instance of RetailStore is a local single-site organization (but not necessarily a stand-alone business, since it might be part of a chain of retail stores) which sells goods directly to consumers at the organization's physicalQuarters.",
		      has_cyc_id => 'RetailStore',
		      pc_old_topic_id => 147096,
		      scof => [$legal_corporation,$concart],
		     });

    my $gtin
      = $R->find_set({
		      label => 'gtin',
		      admin_comment => "Global Trade Identification Number. Includes ISBN, ISSN and other barcode standards. http://www.gtin.info/",
		      scof => $C_text,
		      has_wikipedia_id => 'Global_Trade_Item_Number',
		     });

    $C->get('swedish')->add({pc_old_topic_id => 359});
    $C->get('english')->add({pc_old_topic_id => 396598});


    my $pc_masterpiece =
      $R->find_set({
		    label => 'pc_masterpiece',
		    scof => $ais,
		    pc_old_topic_id => 550893,
		    admin_comment => "The masterpiece of a paranomal.se administrator",
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



##############################################################################

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

#    my $virtual_address =
#      $R->find_set({
#		    label => 'virtual_address',
#		    scof => $C_text,
#		    admin_comment => "Similar to Cycs Computer network contact address. The collection of unique ID strings that are used as addresses on a computer network. This includes e-mail addresses, URLs, ICQ addresses, and so on. (But we also include telephone addresses)",
#		    has_cyc_id => 'ComputerNetworkContactAddress',
#		   });
#
#    $C_email_address->update({scof => $virtual_address});
#    $C_file->update({scof => $virtual_address});
#    $C_url->update({scof => $virtual_address});
#    $C_phone_number->update({scof => $virtual_address});
#
#    my $im_contact_address =
#      $R->find_set({
#		    label => 'im_contact_address',
#		    scof => $virtual_address,
#		    admin_comment => "Instant Messenger program protocol contact address. OpenCyc 1.0 has a InstantMessengerProgram but not corresponding MachineProtocol or ComputerNetworkContactAddress.",
#		   });
#
#    my $address_icq =
#      $R->find_set({
#		    label => 'address_icq',
#		    scof => $im_contact_address,
#		   });
#
#    my $address_msn =
#      $R->find_set({
#		    label => 'address_msn',
#		    scof => $im_contact_address,
#		   });
#
#    my $address_skype =
#      $R->find_set({
#		    label => 'address_skype',
#		    scof => $im_contact_address,
#		   });
#
#    my $address_phone_stationary =
#      $R->find_set({
#		    label => 'address_phone_stationary',
#		    scof => $C_phone_number,
#		   });
#
#    my $address_phone_mobile =
#      $R->find_set({
#		    label => 'address_phone_mobile',
#		    scof => $C_phone_number,
#		   });
#
#
##############################################################################
#
#
#    $R->find_set({
#		  label => 'pc_member_id',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.member",
#		 });
#
#
#    $R->find_set({
#		  label => 'pc_member_level',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.member_level",
#		 });
#
#    $R->find_set({
#		  label => 'pc_latest_in',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_date,
#		  admin_comment => "Old member.latest_in",
#		 });
#
#    $R->find_set({
#		  label => 'pc_latest_out',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_date,
#		  admin_comment => "Old member.latest_out",
#		 });
#
#    $R->find_set({
#		  label => 'pc_latest_host',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_url,
#		  admin_comment => "Old member.latest_host",
#		 });
#
#    $R->find_set({
#		  label => 'has_virtual_address',
#		  is => $C_predicate,
#		  domain => $ia,
#		  range => $virtual_address,
#		 });
#
#    $R->find_set({
#		  label => 'sys_username',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_text,
#		  admin_comment => "Old member.sys_uid",
#		 });
#
#    $R->find_set({
#		  label => 'pc_sys_logging',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.sys_logging",
#		 });
#
#    $R->find_set({
#		  label => 'pc_present_contact',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.present_contact",
#		 });
#
#    $R->find_set({
#		  label => 'pc_present_activity',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.present_activity",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_general_belief',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.general_belief",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_general_theory',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.general_theory",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_general_practice',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.general_practice",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_general_editor',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.general_editor",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_general_helper',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.general_helper",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_general_meeter',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.general_meeter",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_general_bookmark',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.general_bookmark",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_general_discussion',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.general_discussion",
#		 });
#
#    $R->find_set({
#		  label => 'pc_chat_nick',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_text,
#		  admin_comment => "Old member.chat_nick",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_newsmail_level',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.newsmail",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_show_complexity_level',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.show_complexity",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_show_detail_level',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.show_detail",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_show_edit_level',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.show_edit",
#		 });
#
#    my $pc_website_style =
#      $R->find_set({
#		    label => 'pc_website_style',
#		    scof => $individual,
#		    admin_comment => "Collection of css styles",
#		   });
#
#    $R->find_set({
#		  label => 'pc_show_style',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $pc_website_style,
#		  admin_comment => "Old member.show_style",
#		 });
#
#    my $style_blue =
#      $R->find_set({
#		    name => 'blue',
#		    is => $pc_website_style,
#		   });
#
#    my $style_light =
#      $R->find_set({
#		    name => 'light',
#		    is => $pc_website_style,
#		   });
#
#    $R->find_set({
#		  label => 'name_given',
#		  is => $C_predicate,
#		  domain => $person,
#		  range => $C_text,
#		  admin_comment => "Old member.name_given. See cyc_id HumanGivenName",
#		 });
#
#    $R->find_set({
#		  label => 'name_middle',
#		  is => $C_predicate,
#		  domain => $person,
#		  range => $C_text,
#		  admin_comment => "Old member.name_middle",
#		 });
#
#    $R->find_set({
#		  label => 'name_family',
#		  is => $C_predicate,
#		  domain => $person,
#		  range => $C_text,
#		  admin_comment => "Old member.name_family. See cyc_id HumanGivenName",
#		 });
#
#    $R->find_set({
#		  label => 'pc_bdate_year',
#		  is => $C_predicate,
#		  domain => $person,
#		  range => $C_int,
#		  admin_comment => "Old member.bdate_ymd_year. Year of birth",
#		 });
#
#    $R->find_set({
#		  label => 'geo_x',
#		  is => $C_predicate,
#		  domain => $spatial_thing,
#		  range => $C_float,
#		  admin_comment => "Latitude",
#		 });
#
#    $R->find_set({
#		  label => 'geo_y',
#		  is => $C_predicate,
#		  domain => $spatial_thing,
#		  range => $C_float,
#		  admin_comment => "Longitude",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_present_interests',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.present_intrests",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_payment_period_length',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.member_payment_period_length",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_payment_period_expire',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_date,
#		  admin_comment => "Old member.member_payment_period_expire",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_payment_period_cost',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.member_payment_period_cost",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_payment_total',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.member_payment_total",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_chat_level',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.chat_level",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_present_contact_public',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.present_contact_public",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_show_level',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.show_level",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_present_gifts',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.present_gifts",
#		 });
#
#    $R->find_set({
#		  label => 'pc_member_present_blog',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_int,
#		  admin_comment => "Old member.present_blog",
#		 });
#
#
#
#
#    my $person_type_by_culture =
#      $R->find_set({
#		    label => 'person_type_by_culture',
#		    admin_comment => "A collection of collections. Each instance of PersonTypeByCulture is the collection of all and only those persons who participate (see cultureParticipants) in some particular human culture. Examples include FrenchPerson and EthnicGroupOfAustralianAborigines.",
#		    has_cyc_id => 'PersonTypeByCulture',
#		    is => $class,
#		   });
#
#    my $person_type_by_gender =
#      $R->find_set({
#		    label => 'person_type_by_gender',
#		    admin_comment => "Each instance of PersonTypeByGender is the collection of all Persons of a particular gender, understood as a set of attitudes, beliefs, and behaviors (and not strictly a matter of one's biological sex).",
#		    scof => $person_type_by_culture,
#		    has_cyc_id => 'PersonTypeByGender',
#		    pc_old_topic_id => 184438,
#		   });
#
#    my $masculine_person =
#      $R->find_set({
#		    label => 'masculine_person',
#		    admin_comment => "A PersonTypeByGender (q.v.). MasculinePerson is the collection of all Persons of masculine gender. Note that a human MasculinePerson is typically, but not necessarily, a MaleHuman (c.f.).",
#		    scof => $person,
#		    has_cyc_id => 'MasculinePerson',
#		   });
#
#    my $femenine_person =
#      $R->find_set({
#		    label => 'femenine_person',
#		    admin_comment => "A PersonTypeByGender (q.v.). FemininePerson is the collection of all Persons of feminine gender. Note that a human FemininePerson is typically, but not necessarily, a FemaleHuman (c.f.).",
#		    scof => $person,
#		    has_cyc_id => 'FemininePerson',
#		   });
#




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

#    $R->find_set({
#		  label => 'pci_belief',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $believable,
#		  admin_comment => "Old intrest.belief",
#		 });
#
#    $R->find_set({
#		  label => 'pci_knowledge',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_resource,
#		  admin_comment => "Old intrest.knowledge",
#		 });
#
#    $R->find_set({
#		  label => 'pci_theory',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_resource,
#		  admin_comment => "Old intrest.theory",
#		 });
#
#    $R->find_set({
#		  label => 'pci_skill',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $practisable,
#		  admin_comment => "Old intrest.skill",
#		 });
#
#    $R->find_set({
#		  label => 'pci_practice',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $practisable,
#		  admin_comment => "Old intrest.practice",
#		 });
#
#    $R->find_set({
#		  label => 'pci_editor',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_resource,
#		  admin_comment => "Old intrest.editor",
#		 });
#
#    $R->find_set({
#		  label => 'pci_helper',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_resource,
#		  admin_comment => "Old intrest.helper",
#		 });
#
#    $R->find_set({
#		  label => 'pci_meeter',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_resource,
#		  admin_comment => "Old intrest.meeter",
#		 });
#
#    $R->find_set({
#		  label => 'pci_bookmark',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $C_resource,
#		  admin_comment => "Old intrest.bookmark",
#		 });
#
#    $R->find_set({
#		  label => 'pci_experience',
#		  is => $C_predicate,
#		  domain => $C_login_account,
#		  range => $experiencable,
#		  admin_comment => "Old intrest.experience",
#		 });
#
#    $R->find_set({
#		  label => 'pci_defined',
#		  is => $C_predicate,
#		  domain => $C_arc,
#		  range => $C_int,
#		  admin_comment => "Old intrest.intrest_defined to be used on interested_in arcs",
#		 });
#
#    $R->find_set({
#		  label => 'pci_connected',
#		  is => $C_predicate,
#		  domain => $C_arc,
#		  range => $C_int,
#		  admin_comment => "Old intrest.intrest_connected to be used on interested_in arcs",
#		 });
#
#

    $R->find_set({
		  label => 'cia',
		  is => $C_predicate,
		  domain => $ais,
		  range => $C_resource,
		  has_cyc_id => 'containsInformationAbout',
		  admin_comment => "Contains information about. Old TS. This predicate relates sources of information to their topics.",
		 });
    # See also containsInformation
    # containsInfoPropositional-IBT
    # propositionalInfoAbout




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
     0 => 'related',
     1 => 'is',
     2 => 'scof',
     3 => [
	   {
	    pred => 'broader',
	    has_cyc_id => 'generalizations',
	   },
	  ],
     4 => [
	   {
	    pred => 'topic_according_to',
	    doamin => $media,
	    range => $information_store,
	   },
	   {
	    pred => 'according_to',
	    doamin => $pc_topic,
	    range => $information_store,
	   },
	  ],
     5 => undef,
     6 => ['excerpt_from', $media, $cw],
     7 => ['member_of', $agent_generic, $mia],
     8 => ['original_creator', $information_store, $ia],
     9 => [
	   {
	    pred => 'has_source',
	    domain => $ais,
	    range => $cw,
	   },
	   {
	    rev => 1,
	    pred => 'cia',
	   },
	  ],
     10 => [
	    {
	     pred => 'always_offered_by',
	     range_scof => $ia,
	    },
	    {
	     pred => 'offered_by',
	     range => $ia,
	    },
	   ],
     11 => 'compares',
     12 => [
	    {
	     pred => 'interested_in',
	     domain => $agent_generic,
	    },
	    {
	     pred => 'allways_interested_in',
	     domain_scof => $agent_generic,
	    },
	    {
	     pred => 'cia',
	    },
	   ],
     13 => ['published_date', $media, $C_date],
     14 => ['published_by', $media, $ia],
     15 => ['has_subtitle', $cw, $C_text],
     16 => ['has_translator', $cw, $ia],
     17 => ['has_gtin', $product, $gtin],
     18 => ['has_number_of_pages', $media, $C_int],
     19 => ['has_start_date', $temporal_thing, $C_date],
     20 => ['has_end_date', $temporal_thing, $C_date],
     21 => ['influenced_by', $information_store, $information_store],
     22 => ['has_license', $media, $license],
     23 => ['has_copyright', $media, $legal_agent],
     24 => ['has_visiting_address', $ia, $C_text],
     25 => undef, ### TODO: use zipcode
     26 => undef, ### TODO: use city
     27 => ['has_virtual_address', $ia, $C_phone_number],
     28 => [
	    {
	     pred => 'has_permission',
	     domain => $media,
	     range => $permission_ibt,
	    },
	    {
	     pred => 'gives_permission',
	     domain => $ia,
	     range => $permission_ibt,
	    },
	   ],
     29 => [
	    {
	     pred => 'instances_are_member_of',
	     domain_scof => $person,
	     range => $mia,
	    },
	   ],
     30 => ['can_be', $class, $class],
     31 => [
	    {
	     pred => 'is_part_of',
	     domain =>  $individual,
	     range => $individual,
	    },
	    {
	     pred => 'quoted_is_part_of',
	     range => $pc_masterpiece,
	    },
	   ],
     32 => [
	    {
	     pred => 'can_be_part_of',
	     domain => $class,
	     domain_scof => $individual,
	     range => $class,
	     range_scof => $individual,
	    },
	   ],
     33 => ['is_of_language', $media, $C_language],
     34 => [
	    {
	     pred => 'practise',
	     domain => $ia,
	     range => $practisable,
	    },
	    {
	     pred => 'allways_practice',
	     domain_scof => $person,
	     range => $practisable,
	    },
	   ],
     35 => [
	    {
	     pred => 'has_experienced',
	     domain => $ia,
	     range => $experiencable,
	    },
	    {
	     pred => 'allways_experienced',
	     domain_scof => $ia,
	     range => $experiencable,
	    },
	   ],
     36 => 'is_influenced_by',
     37 => ['based_upon', $media, $media],
     38 => ['has_epithet', $individual, $individual],
     39 => [
	    {
	     pred => 'in_place',
	     domain => $spatial_thing,
	     range => $location,
	    },
	    {
	     pred => 'org_present_in_region',
	     domain => $organization,
	     range => $location,
	    },
	   ],
     40 => undef,
     41 => undef,
     42 => undef,
     43 => ['has_postal_address', $ia, $C_text],
     44 => ['instance_owned_by', $temporal_stuff_type, $legal_agent],
     45 => ['has_owner', $temporal_thing, $legal_agent],
     46 => undef,
     47 => [
	    {
	     pred => 'uses',
	     domain_scof => $temporal_thing,
	    }
	   ],
     48 => [
	    {
	     pred => 'instances_are_part_of',
	     domain => $class,
	     range => $individual,
	    },
	   ],
    };

    my $ortl = $odbix->select_key('reltype','from reltype');

    foreach my $rtid ( sort keys %$arctype_map )
    {
	my $defs = $arctype_map->{$rtid} or next;

	unless( ref $defs )
	{
	    $defs = [$defs];
	}

	my( @preds_rel, @preds_rev );

	unless( ref $defs->[0] )
	{
	    my( $pred_name, $domain, $range ) = @$defs;
	    $defs =
	      [{
		pred => $pred_name,
		domain => $domain,
		range => $range,
	       }];
	}

	foreach my $def (@$defs)
	{
	    my $pred_name = $def->{'pred'} or die;
	    my $domain = $def->{'domain'};
	    my $range = $def->{'range'} || $C_resource;
	    my $domain_scof = $def->{'domain_scof'};
	    my $range_scof = $def->{'range_scof'};

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

	    if( $domain_scof )
	    {
		$pred->add({ domain_scof => $domain_scof });
	    }

	    if( $range_scof )
	    {
		$pred->add({ range_scof => $range_scof });
	    }

	    if( $name_rev )
	    {
		$pred->add({ name_rev => $name_rev });
	    }

	    if( $def->{'rev'} )
	    {
		push @preds_rev, $pred;
	    }
	    else
	    {
		push @preds_rel, $pred;
	    }
	}

	$RELTYPE{ $rtid } =
	{
	 rel => \@preds_rel,
	 rev => \@preds_rev,
	};
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
		    has_cyc_id => 'PlanetEarth',
		    has_wikipedia_id => 'Earth',
		   });

    my $sweden =
      $R->find_set({
		    label => 'sweden',
		    is => $location,
		    pc_old_topic_id => 397071,
		    is_part_of => $planet_earth,
		    has_wikipedia_id => 'Sweden',
		   });

    my $country =
      $R->find_set({
		    label => 'loc_country',
		    scof => $location,
		    pc_old_topic_id => 129520,
		    has_cyc_id => 'Country',
		    has_wikipedia_id => 'Country',
		   });
#    my $county =
#      $R->find_set({
#		    label => 'loc_county',
#		    scof => $location,
#		    pc_old_topic_id => 541764,
#		    has_cyc_id => 'County',
#		    has_wikipedia_id => 'County',
#		   });
#
#    my $municipality =
#      $R->find_set({
#		    label => 'loc_municipality',
#		    scof => $location,
#		    has_cyc_id => 'Municipality',
#		    can_be_part_of => $county,
#		    has_wikipedia_id => 'Municipality',
#		   });
#
#    my $city =
#      $R->find_set({
#		    label => 'loc_city',
#		    scof => $location,
#		    pc_old_topic_id => 129524,
#		    has_cyc_id => 'City',
#		    can_be_part_of => $municipality,
#		    has_wikipedia_id => 'City',
#		   });
#
#    my $parish =
#      $R->find_set({
#		    label => 'loc_parish',
#		    scof => $location,
#		    can_be_part_of => $municipality,
#		    has_wikipedia_id => 'Parish_(country_subdivision)',
#		   });
#
#    my $zipcode =
#      $R->find_set({
#		    label => 'loc_zipcode',
#		    scof => $location,
#		    admin_comment => "A specialization of ContactInfoString. Each instance of PostalCode is a character string used by a postal service to designate a particular geographic area.",
#		    has_cyc_id => 'InternationalPostalCode',
#		    can_be_part_of => $city,
#		    has_wikipedia_id => 'Postal_code',
#		   });
#

    #### COMMIT
    $R->commit;


#&    my %countyidx;
#&  COUNTY:
#&    {
#&	my $countylist = $odbix->select_list('from county');
#&	my( $countyrec, $countyerror ) = $countylist->get_first;
#&	while(! $countyerror )
#&	{
#&	    my $id = sprintf "%.2d", $countyrec->{'county'};
#&	    $countyidx{ $id } =
#&	      $R->create({
#&			  name => $countyrec->{county_name},
#&			  code => $id,
#&			  name_short => $countyrec->{county_code},
#&			  is => $county,
#&			  is_part_of => $sweden,
#&			 });
#&	}
#&	continue
#&	{
#&	    ( $countyrec, $countyerror ) = $countylist->get_next;
#&	}
#&    }
#&
#&    my %cityidx;
#&  CITY:
#&    {
#&	debug "retrieving list of all cities";
#&	my $citylist = $odbix->select_list('from city');
#&	my( $cityrec, $cityerror ) = $citylist->get_first;
#&	while(! $cityerror )
#&	{
#&	    $cityidx{ $cityrec->{'city'} } =
#&	      $R->create({
#&			  name => ucfirst lc $cityrec->{city_name},
#&			  is => $city,
#&			  is_part_of => $countyidx{ $cityrec->{city_l} },
#&			  geo_x => $cityrec->{city_x},
#&			  geo_y => $cityrec->{city_y},
#&			 });
#&	}
#&	continue
#&	{
#&	    ( $cityrec, $cityerror ) = $citylist->get_next;
#&	}
#&    }
#&
#&    my %munidx;
#&#  MUNICIPALITY:
#&#    {
#&#	debug "retrieving list of all municipalities";
#&#	my $munlist = $odbix->select_list('from municipality');
#&#	my( $munrec, $munerror ) = $munlist->get_first;
#&#	while(! $munerror )
#&#	{
#&#	    $munidx{ $munrec->{'municipality'} } =
#&#	      $R->create({
#&#			  name => $munrec->{municipality_name},
#&#			  is => $municipality,
#&#			  code => $munrec->{municipality},
#&#			  is_part_of => $countyidx{ $munrec->{municipality_l} },
#&#			 });
#&#	}
#&#	continue
#&#	{
#&#	    ( $munrec, $munerror ) = $munlist->get_next;
#&#	}
#&#    }
#&
#&    my %parishidx;
#&#  PARISH:
#&#    {
#&#	debug "retrieving list of all parishes";
#&#	my $parishlist = $odbix->select_list('from parish');
#&#	my( $parishrec, $parisherror ) = $parishlist->get_first;
#&#	while(! $parisherror )
#&#	{
#&#	    $parishidx{ $parishrec->{'parish'} } =
#&#	      $R->create({
#&#			  name => $parishrec->{parish_name},
#&#			  is => $parish,
#&#			  code => $parishrec->{parish},
#&#			  is_part_of => $munidx{ $parishrec->{parish_lk} },
#&#			 });
#&#	}
#&#	continue
#&#	{
#&#	    ( $parishrec, $parisherror ) = $parishlist->get_next;
#&#	}
#&#    }
#&
#&
#&    # Now bring the official codes up to date for 2009
#&    #
#&    debug "Setting up LKF 2009";
#&    open LKF, '<', $Para::CFG->{'pc_root'}.'/doc/lkf2009.txt' or die $!;
#&    while(my $line = <LKF>)
#&    {
#&	chomp $line;
#&	next unless $line;
#&
#&	utf8::decode( $line );
#&	my( $key, $val ) = split /=/, $line;
#&	my( $l, $k, $f ) = $key =~ /^(..)(..)?(..)?/;
#&
#&	if( $f )
#&	{
#&	    debug "F $key = $val";
#&	    $parishidx{ $key } =
#&	      $R->create({
#&			  name => $val,
#&			  is => $parish,
#&			  code => $key,
#&			  is_part_of =>  $munidx{ $l.$k },
#&			 });
#&	}
#&	elsif( $k )
#&	{
#&	    debug "K $key = $val";
#&	    $munidx{ $key } =
#&	      $R->create({
#&			  name => $val,
#&			  is => $municipality,
#&			  code => $key,
#&			  is_part_of => $countyidx{ $l },
#&			 });
#&	}
#&	elsif( $l )
#&	{
#&	    debug "L $key = $val";
#&	    # Done above
#&	}
#&	else
#&	{
#&	    die "Could not parse key $key";
#&	}
#&    }
#&
#&
#&
#&
#&
#&
#&
#&
#&  ZIPCODE:
#&    {
#&	my %trans =
#&	  (
#&	   1917 => '0331',
#&	  );
#&
#&	debug "retrieving list of all zipcodes";
#&	my $ziplist = $odbix->select_list('from zip');
#&	my( $ziprec, $ziperror ) = $ziplist->get_first;
#&	while(! $ziperror )
#&	{
#&	    my $zip_city = $ziprec->{zip_city};
#&	    my $zip_lk = sprintf "%.4d", $ziprec->{zip_lk};
#&
#&	    if( $trans{$zip_lk} ){ $zip_lk = $trans{$zip_lk} };
#&
#&
#&	    unless( $cityidx{ $zip_city } )
#&	    {
#&		throw "City $zip_city not found in city index";
#&	    }
#&
#&	    unless( $munidx{ $zip_lk } )
#&	    {
#&		throw "Municipality $zip_lk not found in mun index";
#&	    }
#&
#&	    $R->create({
#&			is => $zipcode,
#&			code => $ziprec->{zip},
#&			is_part_of => [
#&				       $cityidx{ $zip_city },
#&				       $munidx{ $zip_lk },
#&				      ],
#&			geo_x => $ziprec->{zip_x},
#&			geo_y => $ziprec->{zip_y},
#&		       });
#&	}
#&	continue
#&	{
#&	    ( $ziprec, $ziperror ) = $ziplist->get_next;
#&	}
#&    }
#&

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
#	   sys_email => $C_email_address,
#	   home_online_uri => $C_website_url,
#	   home_online_icq => $address_icq,
#	   home_online_msn => $address_msn,
#	   home_tele_phone => $address_phone_stationary,
#	   home_tele_mobile => $address_phone_mobile,
#	   home_online_skype => $address_skype,
	  );

	debug "retrieving list of all members";

	my $list = $odbix->select_list('from member where member_level > 4 and member > 0 order by member limit 0');
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
#		push @is, $femenine_person;
	    }
	    elsif( $rec->{'gender'} eq 'M' )
	    {
#		push @is, $masculine_person;
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
    #  t                        pc_old_topic_id
    #  t_pop                    -
    #  t_size                   -
    #  t_created                node(created)
    #  t_createdby              node(created)
    #  t_updated                -
    #  t_changedby              -
    #  t_status                 ... pc_featured_topic
    #  t_title                  name
    #  t_text                   description
    #  t_entry                  is $pc_entry
    #  t_entry_parent           is_part_of / cia
    #  t_entry_next             ... (use weight)
    #  t_entry_imported         -
    #  t_file                   pc_public_path
    #  t_class                  is $class
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
    #  t_title_short_plural     ... is $term_plural
    #  t_vacuumed               -

    ## t_status: http://old.paranormal.se/meta/devel/entry_status.html

    $pc_topic =
      $R->find_set({
		    label => 'pc_topic',
		    is => $class,
		    admin_comment => "A topic that is meant to be presented as an encyclopedia article. Not all topics from old paranormal should be topics.",
		   });

    $pc_entry =
      $R->find_set({
		    label => 'pc_entry',
		    scof => $media,
		    admin_comment => "A topic that is meant to be presented as an encyclopedia article. Not all topics from old paranormal should be topics.",
		   });

    $pc_featured_topic =
      $R->find_set({
		    label => 'pc_featured_topic',
		    scof => $pc_topic,
		    admin_comment => "A topic of high quality regarding its entries and metadata. Old t.t_status 5 ('final' Official entry)",
		    has_wikipedia_id => 'Category:Featured_articles',
		   });

    $word_plural =
      $R->find_set({
		    label => 'term_plural',
		    scof => $C_term,
		    admin_comment => "A term in plural form",
		    has_wikipedia_id => 'Plural',
		   });

    $R->find_set({
		  label => 'pc_public_path',
		  is => $C_predicate,
		  domain => $pc_topic,
		  range => $C_file,
		  admin_comment => "Old t.t_file",
		 });

    $R->find_set({
		  label => 'pc_connected',
		  is => $C_predicate,
		  domain => $pc_topic,
		  range => $C_int,
		  admin_comment => "Old t.t_connected",
		 });






    # TS
    #
    # ts_entry     ...
    # ts_topic     ...
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

    $R->commit;

  TS:
    {
	debug "======= retrieving list of all topic statements";
	my $list = $odbix->select_list('from ts where ts_active is true and ts_status > 2 order by ts_entry limit 0');
	my( $rec, $error ) = $list->get_first;
	while(! $error )
	{
	    my $e = import_topic( $rec->{ts_entry} );
	    my $t = import_topic( $rec->{ts_topic} );
	    $e->add_arc({'cia' => $t});
	}
	continue
	{
	    ( $rec, $error ) = $list->get_next;
	}
    };



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

    $R->find_set({
		  label => 'pca_autolink',
		  is => $C_predicate,
		  domain => $C_text,
		  range => $C_bool,
		  admin_comment => "Old talias.talias_autolink",
		 });

    $R->find_set({
		  label => 'pca_index',
		  is => $C_predicate,
		  domain => $C_text,
		  range => $C_bool,
		  admin_comment => "Old talias.talias_index",
		 });

    $R->commit;

  TALIAS:
    {
	debug "======= retrieving list of all topic aliases";
	my $list = $odbix->select_list('from talias where talias_active is true and talias_status > 3 order by talias_t limit 0');
	my( $rec, $error ) = $list->get_first;
	while(! $error )
	{
	    my $t = import_topic( $rec->{talias_t} );
	    my $str = $rec->{talias};

	    debug "Alias $str for ".$t->sysdesig;

#	    debug $t->list('name')->sysdesig;

	    my $al;
	    foreach my $eal ( $t->list('name')->as_array )
	    {
		if( lc($eal->plain) eq lc($str) )
		{
		    $al = $eal;
		    last;
		}
	    }

	    unless( $al )
	    {
		$al = $L->new($str,$C_term);
		$t->add({'name'=>$al});
	    }

	    my %props;
	    if( $rec->{talias_autolink} )
	    {
		$props{pca_autolink} = 1;
	    }

	    if( $rec->{talias_index} )
	    {
		$props{pca_index} = 1;
	    }

	    $props{url_part} = $rec->{talias_urlpart};

	    if( $rec->{talias_language} )
	    {
		my $lang =  import_topic( $rec->{talias_language} );
		$props{is_of_language} = $lang;
	    }

	    # TODO: Set the creator and created date of literal
	    $al->add(\%props);
	}
	continue
	{
	    ( $rec, $error ) = $list->get_next;
	}
    };


    # MEDIA
    #
    # media                 ...
    # media_mimetype        is ...?
    # media_url             has_url
    # media_checked_working -
    # media_checked_failed  -
    # media_speed           -

    # This is all mimetypes used in old db;
    #   application/pdf
    #   email
    #   image/gif
    #   image/jpeg
    #   image/png
    #   image/svg+xml
    #   text/html
    #   text/plain

    my %mtype;

    my $computer_file_ais
      = $R->find_set({
		      label => 'computer_file_ais',
		      admin_comment => "Each instance of ComputerFile-AIS is an abstract series of bits encoding some information and conforming to some file system protocol.",
		      scof => $abis,
		      has_cyc_id => 'ComputerFile-AIS',
		     });

#    my $computer_file_type_by_format
#      = $R->find_set({
#		      label => 'computer_file_type_by_format',
#		      admin_comment => "A collection of collections of computer files [ComputerFile-AIS]. Each instance of ComputerFileTypeByFormat (e.g. JPEGFile) is a collection of all ComputerFile-AISs that conform to a single preestablished layout for electronic data. Programs accept data as input in a certain format, process it, and provide it as output in the same or another format. This constant refers to the format of the data. For every instance of ComputerFileCopy, one can assert a fileFormat for it.",
#		      is => $class, # SecondOrderCollection
#		      has_cyc_id => 'ComputerFileTypeByFormat',
#		     });
#
#    $mtype{'application/pdf'}
#      = $R->find_set({
#		      label => 'file_pdf',
#		      admin_comment => "Computer files encoded in the PDF file format.",
#		      is => $computer_file_type_by_format,
#		      scof => $computer_file_ais,
#		      has_cyc_id => 'PortableDocumentFormatFile',
#		      code => 'application/pdf',
#		     });
#
#    $mtype{'email'}
#      = $R->find_set({
#		      label => 'file_email',
#		      is => $computer_file_type_by_format,
#		      scof => $computer_file_ais,
#		      has_cyc_id => 'EMailFile',
#		      code => 'email',
#		     });
#
#    my $file_image
#      = $R->find_set({
#		      label => 'file_image',
#		      admin_comment => "A specialization of ComputerFile-AIS. Each ComputerImageFile contains a digital representation of some VisualImage, and is linked to an instance of ComputerImageFileTypeByFormat via the predicate fileFormat.",
#		      is => $computer_file_type_by_format,
#		      scof => $computer_file_ais,
#		      has_cyc_id => 'ComputerImageFile',
#		     });
#
#    $mtype{'image/gif'}
#      = $R->find_set({
#		      label => 'file_gif',
#		      admin_comment => "A collection of ComputerImageFiles. Each GIFFile is encoded in the \"Graphics Interchange Format\". GIFFiles are extremely common for inline images on web pages, and generally have filenames that end in \".gif\".",
#		      is => $computer_file_type_by_format,
#		      scof => $file_image,
#		      has_cyc_id => 'GIFFile',
#		      code => 'image/gif',
#		     });
#
#    $mtype{'image/jpeg'}
#      = $R->find_set({
#		      label => 'file_jpeg',
#		      admin_comment => "A collection of ComputerImageFiles. Each JPEGFile is a ComputerImageFile whose fileFormat conforms to the standard image compression algorithm designed by the Joint Photographic Experts Group for compressing either full-colour or grey-scale digital images of 'natural', real-world scenes. Instances of JPEGFile often have filenames that end in '.jpg' or '.jpeg'.",
#		      is => $computer_file_type_by_format,
#		      scof => $file_image,
#		      has_cyc_id => 'JPEGFile',
#		      code => 'image/jpeg',
#		     });
#
#    $mtype{'image/png'}
#      = $R->find_set({
#		      label => 'file_png',
#		      admin_comment => "The collection of computer image files encoded in the '.png' file format. Designed to replace GIF files, PNG files have three main advantages: alpha channels (variable transparency), gamma correction (cross-platform control of image brightness) and two-dimensional interlacing.",
#		      is => $computer_file_type_by_format,
#		      scof => $file_image,
#		      has_cyc_id => 'PortableNetworkGraphicsFile',
#		      code => 'image/png',
#		     });
#
#    $mtype{'image/svg+xml'}
#      = $R->find_set({
#		      label => 'file_svg',
#		      admin_comment => "An SVG image file",
#		      is => $computer_file_type_by_format,
#		      scof => $file_image,
#		      code => 'image/svg+xml',
#		     });
#
#    $mtype{'text/html'}
#      = $R->find_set({
#		      label => 'file_html',
#		      admin_comment => "The subcollection of ComputerFile-AIS written in the language HypertextMarkupLanguage.",
#		      is => $computer_file_type_by_format,
#		      scof => $computer_file_ais,
#		      has_cyc_id => 'HTMLFile',
#		      code => 'text/html',
#		     });
#
#    $mtype{'text/plain'}
#      = $R->find_set({
#		      label => 'file_text_plain',
#		      admin_comment => "A plain text file with any charset.",
#		      is => $computer_file_type_by_format,
#		      scof => $computer_file_ais,
#		      code => 'text/plain',
#		     });

    $R->commit;

  MEDIA:
    {
	debug "======= retrieving list of all media";
	my $list = $odbix->select_list('from media order by media limit 0');
	my( $rec, $error ) = $list->get_first;
	while(! $error )
	{
	    my $t = import_topic( $rec->{media} );
	    next unless $t;

	    my $code_str = $rec->{'media_mimetype'};
	    my $url_str = $rec->{'media_url'};

	    $t->add({
		     is => $mtype{$code_str},
		     has_url => $url_str,
		    });
	}
	continue
	{
	    ( $rec, $error ) = $list->get_next;
	}
    };




    #### Specifying node types
    {
	my %mapis =
	  (
	  );

	foreach my $key ( keys %mapis )
	{
	    my $n = import_topic( $key );
	    $n->add({is => $mapis{$key} });
	}

	my %mapscof =
	  (
	   396717 => $person,
	  );

	foreach my $key ( keys %mapscof )
	{
	    my $n = import_topic( $key );
	    $n->add({scof => $mapscof{$key} });
	}



    };



#    ### TIME-TEST
#    #
#    my $pred_obj = $C->get('has_start_date');
#    my $value_obj = Rit::Base::Resource->
#      get_by_anything( '1875 ',
#		       {
#			valtype => $C_date,
#			pred_new => $pred_obj,
#		       });
#
#    debug $value_obj->sysdesig;
#    debug $value_obj->datetime;
#    debug $dbix->format_datetime($value_obj);
#    die "HERE";





    # REL
    #
    # rel_topic     -
    # rev           subj
    # rel           obj
    # rel_type      pred
    # rel_status    -
    # rel_value     value
    # rel_comment   description
    # rel_updated   -
    # rel_changedby -
    # rel_strength  arc_weight
    # rel_active    -
    # rel_createdby created_by
    # rel_created   created
    # rel_indirect  -
    # rel_implicit  -

  TOPIC:
    {
	$R->commit;

	debug "======= retrieving list of all topics and rels";
	my $list = $odbix->select_list('from t where t_active is true and t_status > 1 and t >= 0 and t_entry is false order by t limit 12');
	my( $rec, $error ) = $list->get_first;
	while(! $error )
	{
	    if( my $n = import_topic_main( $rec->{'t'}, $rec ) )
	    {
		import_topic_arcs( $n );
	    }

#	    unless( $list->index % 10 )
#	    {
		dlog sprintf "==== %7d", $list->index;
#	    }
	}
	continue
	{
	    ( $rec, $error ) = $list->get_next;
	}
    };



    # Adding additional entry tree
    debug "======= Couple imported topics to their entries";
    sleep 10;
    foreach my $tid ( keys %TOPIC )
    {
	import_topic_entries( $tid );
    }

    # Adding main parent
    debug "======= Couple imported topics to their parents";
    sleep 10;
    foreach my $tid ( keys %TOPIC )
    {
	import_topic_parent( $tid );
    }

    debug "======= Topics import done";


    $Para::Frame::REQ->done;
    $req->user->set_default_propargs(undef);

    print "Done!\n";

    return;
}


##############################################################################

sub tree_entry
{
    my( $e ) = @_;
    my $parent = $e->first_prop('is_part_of');

    $e->{pc_wc} ||= 0; # weight counter

    foreach my $se ( import_childs($e)->as_array )
    {
	$e->{pc_wc} ++;
	$se->update({weight => $e->{pc_wc}});
	tree_entry($se);
    }

    while( $TOPIC{$e->pc_old_topic_id}{next} )
    {
	my $next = import_topic( $TOPIC{$e->pc_old_topic_id}{next} );
	$parent->{pc_wc} ++;
	$next->add({
		    is_part_of => $parent,
		    weight => $parent->{pc_wc},
		   });

	$next->{pc_wc} ||= 0; # weight counter
	foreach my $se ( import_childs($next)->as_array )
	{
	    $next->{pc_wc} ++;
	    $se->update({weight => $next->{pc_wc}});
	    tree_entry($se);
	}
	$e = $next;
    }
}


##############################################################################

sub import_topic_main
{
    my( $id, $rec ) = @_;

    unless( $rec )
    {
	$rec = $odbix->select_possible_record('from t where t_active is true and t=?', $id);
	unless( $rec )
	{
	    return undef;
	}
    }


###    my $created_by = $R->get({pc_member_id => $rec->{'t_createdby'}});

    my $title;

    my %prop =
      (
#       pc_old_topic_id => $id,
       created => $rec->{'t_created'},
###       created_by => $created_by,
       description => $rec->{'t_text'},
       is => [],
      );

    $TOPIC{$id} = {};

    if( $rec->{'t_title'} )
    {
	$title = $L->new($rec->{'t_title'},'term');
	push @{$prop{name}}, $title;
    }

    if( my $pc_connected = $rec->{'t_connected'} )
    {
	$prop{ pc_connected } = $pc_connected;
    }

    if( my $url_part = $rec->{'t_urlpart'} )
    {
	$prop{ url_part } = $url_part;
    }

    if( my $admin_comment = $rec->{'t_comment_admin'} )
    {
	$prop{ admin_comment } = $admin_comment;
    }

### We do not know what is in this slot. Leave it...
#
#    if( $rec->{'t_title_short'} )
#    {
#	# TODO: use name with prop is short
#	my $title_short = $L->new($rec->{'t_title_short'},'term');
#	$prop{ name_short }  = $title_short;
#	push @{$prop{name}}, $title_short;
#    }

    if( my $t_status = $rec->{'t_status'} )
    {
	if( $t_status == 5 )
	{
	    push @{$prop{quoted_is}}, $pc_featured_topic;
	}
    }

    if( $rec->{t_entry} )
    {
	push @{$prop{is}}, $pc_entry;
    }
    else # topic
    {
	push @{$prop{is}}, $pc_topic;

	if( my $pc_public_path = $rec->{'t_file'} )
	{
	    $prop{ pc_public_path } = $pc_public_path;
	}
    }

    if( my $parent = $rec->{t_entry_parent} )
    {
	$TOPIC{$id}{parent} = $parent;
    }

    if( my $next = $rec->{t_entry_next} )
    {
	$TOPIC{$id}{next} = $next;
    }

    if( $rec->{t_class} )
    {
	push @{$prop{is}}, $class;
    }

    if( my $plural = $rec->{t_title_short_plural} )
    {
	my $name = $L->new($plural,'term_plural');
	push @{$prop{name}}, $name;
    }

    # May be one of the nodes created previously
    my $n = $R->find({pc_old_topic_id=>$id})->get_first_nos;
    unless( $n )
    {
	$prop{pc_old_topic_id} = $id;
	$n = $R->create(\%prop);
    }

    $TOPIC{$id}{node} = $n;

    if( $title )
    {
	$title->lit_revarc->set_weight( 10, {force_same_version=>1} );
    }

    return $TOPIC{$id}{node};
}


##############################################################################

sub import_topic_parent
{
    my( $id ) = @_;

    my $th = $TOPIC{$id};
    if( $th->{parent} )
    {
	if( my $parent = import_topic( $th->{parent} ) )
	{
	    my $n = $th->{node};
	    if( $parent->has_value({is => $pc_topic}) )
	    {
		# Text officially belongs to this topic
		my $ciaa = $n->add_arc({'cia' => $parent});
		$ciaa->set_weight( 10, {force_same_version=>1} );
	    }
	    else # entry
	    {
		$n->add({is_part_of => $parent});
	    }
	}
    }
}


##############################################################################

sub import_topic_entries
{
    my( $id ) = @_;

    my $th = $TOPIC{$id};

    my $n = $th->{node};
    debug "*****  importing entries for ".$n->sysdesig;


    unless( $n->has_value({is=>$pc_topic}) )
    {
	debug "    not a topic";
	return;
    }

    foreach my $me ( import_childs($n)->as_array )
    {
	debug "  got main entry ".$me->sysdesig;
	$me->{pc_wc} ||= 0; # weight counter

	foreach my $se ( import_childs($me)->as_array )
	{
	    $me->{pc_wc} ++;
	    $se->update({weight => $me->{pc_wc}});
	    tree_entry($se);
	}

	my $e = $me;
	debug "  extracting chained entries for ".$e->sysdesig;
	while( $TOPIC{$e->pc_old_topic_id}{next} )
	{
	    my $next = import_topic( $TOPIC{$e->pc_old_topic_id}{next} );
	    last unless $next;
	    debug "    found ".$next->sysdesig;
	    $me->{pc_wc} ++;
	    $next->add({
			is_part_of => $me,
			weight => $me->{pc_wc},
		       });

	    $next->{pc_wc} ||= 0; # weight counter
	    debug "    getting childs of ".$next->sysdesig;
	    foreach my $se ( import_childs($next)->as_array )
	    {
		debug "      found child ".$se->sysdesig;
		$next->{pc_wc} ++;
		$se->update({weight => $next->{pc_wc}});
		tree_entry($se);
	    }

	    debug "    switching to look for chained entries for ".$e->sysdesig;
	    $e = $next;
	}
    }
}


##############################################################################

sub import_topic
{
    my( $id, $rec ) = @_;

    return undef unless $id;

#    debug "  get topic $id";

    if( $TOPIC{$id} )
    {
	return $TOPIC{$id}{node};
    }

    my $n = import_topic_main( $id, $rec );
    return undef unless $n;

    import_topic_parent( $id );
    import_topic_entries( $id );

    return $n;
}


##############################################################################

sub import_childs
{
    my( $n ) = @_;

    if( $n->{p4_imported_childs} )
    {
	return $n->{p4_imported_childs};
    }

    unless( UNIVERSAL::isa $n, 'Rit::Base::Resource' )
    {
	confess "Got $n";
    }

    debug "  Get childs to ".$n->pc_old_topic_id;
    my $list = $odbix->select_list('from t where t_active is true and t_status > 1 and t_entry_parent=? order by t', $n->first_prop('pc_old_topic_id')->plain);
    debug "  Got ".$list->size." results";

    my @childs;
    foreach my $rec ( $list->as_array )
    {
	push @childs, import_topic( $rec->{t}, $rec );
    }

    return $n->{p4_imported_childs} = Rit::Base::List->new(\@childs);
}


##############################################################################

sub import_topic_arcs
{
    my( $n ) = @_;

    return if $n->{p4_imported_arcs};

    if( $n->{p4_imported_arcs_partial} )
    {
	debug "**** Partially imported arcs for ".$n->sysdesig;
	return;
    }

    debug "initiating ".$n->sysdesig;

    $n->{p4_imported_arcs_partial} = 1;

    import_topic_arcs_primary( $n );

    # In order to bootstrap, start with is and scof
    my $list = $odbix->select_list('from rel where rel_active is true and rel_indirect is false and rel_strength >= 30 and rel_type > 2 and rev=? order by rel_type', $n->pc_old_topic_id->plain);

    my( $rec, $error ) = $list->get_first;
    while(! $error )
    {
	import_topic_arc( $rec );
    }
    continue
    {
	( $rec, $error ) = $list->get_next;
    }

    unless( $list->size )
    {
	debug $n->sysdesig." has no rels";
    }

    debug "INITIATED  ".$n->sysdesig;

    $n->{p4_imported_arcs} = 1;
}


##############################################################################

sub import_topic_arcs_primary
{
    my( $n ) = @_;

    return if $n->{p4_imported_arcs_primary};

    if( $n->{p4_imported_arcs_primary_partial} )
    {
	debug "**** Partially imported primary arcs for ".$n->sysdesig;
	return;
    }

    debug "initiating ".$n->sysdesig;

    $n->{p4_imported_arcs_primary_partial} = 1;

    # In order to bootstrap, start with is and scof
    my $list = $odbix->select_list('from rel where rel_active is true and rel_indirect is false and rel_strength >= 30 and rel_type < 3 and rev=? order by rel_type', $n->pc_old_topic_id->plain);

    my( $rec, $error ) = $list->get_first;
    while(! $error )
    {
	import_topic_arc( $rec );
    }
    continue
    {
	( $rec, $error ) = $list->get_next;
    }

    unless( $list->size )
    {
	debug $n->sysdesig." has no rels";
    }

    debug "INITIATED  ".$n->sysdesig;

    $n->{p4_imported_arcs_primary} = 1;
}


##############################################################################

sub import_topic_arc
{
    my( $rec ) = @_;

    my $id = $rec->{rel_topic};
    return $TOPIC{$id}{node} if $TOPIC{$id};

    my $subj_in = import_topic( $rec->{rev} );
    return unless $subj_in;

    my $predaltsh = $RELTYPE{ $rec->{rel_type} };
    return unless $predaltsh; # unhandled reltype

    my $errmsg = "";

    my @preds; # choosen pred

    foreach my $dir ( 'rel', 'rev' )
    {
	my $rev = (($dir eq 'rev')? 1 : 0 );

	my( $subj, $obj );
	if( $rev )
	{
	    $subj = import_topic( $rec->{rel} );
	    return unless $subj;
	    import_topic_arcs_primary( $subj );
	}
	else
	{
	    $subj = $subj_in;
	}


	foreach my $alt_pred ( @{$predaltsh->{$dir}} )
	{
	    if( $alt_pred->plain eq 'scof' )
	    {
		# Bootstraping
		push @preds, [$alt_pred, $rev];
	    }
	    elsif( my $domain = $alt_pred->domain )
	    {
		$errmsg .= "  domain of ".$alt_pred->plain.
		  " is ".$domain->sysdesig."\n";

		if( $domain->equals($information_store) and
		    $subj->has_value({is=>$mia}) and
		    not $subj->has_value({is=>$domain}) )
		{
		    dlog "AUTOCREATING organization1 for ".$subj->sysdesig;
		    push  @AUTOCREATED, $subj->add_arc({is => $organization});
		}

		if( $domain->equals($organization) and
		    $subj->has_value({is=>$mia}) and
		    not $subj->has_value({is=>$domain}) )
		{
		    dlog "AUTOCREATING organization2 for ".$subj->sysdesig;
		    push  @AUTOCREATED, $subj->add_arc({is => $organization});
		}


		#####################

		if( $subj->has_value({is=>$domain}) )
		{
		    push @preds, [$alt_pred, $rev];
		}
		else
		{
		    $errmsg .=  "  Subj ".$subj->sysdesig.
		      " not in the right domain for ".$alt_pred->plain."\n";
		    $errmsg .= "  is for subj is ".$subj->is->sysdesig."\n";
		}
	    }
	    elsif( my $domain_scof = $alt_pred->domain_scof )
	    {
		$errmsg .= "  domain_scof of ".$alt_pred->plain.
		  " is ".$domain_scof->sysdesig."\n";

		if( $subj->has_value({scof=>$domain_scof}) )
		{
		    push @preds, [$alt_pred, $rev];
		}
		else
		{
		    $errmsg .= "  Subj ".$subj->sysdesig.
		      " not in the right domain_scof for ".$alt_pred->plain."\n";

		    $errmsg .= "  scof for subj is ".$subj->scof->sysdesig."\n";
		}
	    }
	    else
	    {
		push @preds, [$alt_pred, $rev];
	    }
	}
    }

    unless( @preds )
    {
	dlog "/~~~~~ No valid pred found for rel_topic ". $rec->{rel_topic};
	dlog $errmsg;
	dlog "\_____";
#	confess sprintf "  %s --R%d--> %s %s",
#	  $subj->sysdesig, $rec->{rel_type}, ($rec->{rel}||''), ($rec->{rel_value}||'');
	return;
    }

    if( @preds > 1 )
    {
	$errmsg .= "  Considering alternative preds\n";
	$errmsg .= "  ".$preds[0][0]->plain."\n";
	$errmsg .= "  ".$preds[1][0]->plain."\n";
    }


    foreach my $predl ( @preds )
    {
	my $pred_obj = $predl->[0];
	my $pred = $pred_obj->plain;
	my $rev = $predl->[1];

	my( $subj, $value_obj );
	if( $rev )
	{
	    $subj = import_topic( $rec->{rel} );
	    $value_obj  = $subj_in;
	}
	else
	{
	    $subj = $subj_in;
	}


###	my $created_by = $R->get({pc_member_id => $rec->{'rel_createdby'}});

	my %props =
	  (
	   subj => $subj->id,
	   pred => $pred,
	   arc_weight => $rec->{rel_strength},
###	   created_by => $created_by,
	   created => $rec->{created},
	  );


	if( $pred_obj->objtype )
	{
	    my $obj = $value_obj || import_topic( $rec->{rel} );
	    return unless $obj;

	    debug sprintf "Creating %s --%s--> %s",
	      $subj->sysdesig, $pred, $obj->sysdesig;

	    unless( $pred eq 'related' ) ### Loopy critters
	    {
		import_topic_arcs_primary( $obj );
	    }

	    # Automaticly making the obj a class if acting like one
	    #
	    if( $pred_obj->valtype->equals($class) )
	    {
		unless( $obj->has_value({is => $class}) )
		{
		    dlog "AUTOCREATING class for ".$obj->sysdesig;
		    push  @AUTOCREATED, $obj->add_arc({is => $class});
		}
	    }
	    elsif( $pred_obj->valtype->equals($individual) )
	    {
		if( my $class = $obj->first_prop('is',{is=>$pc_topic},'adirect') )
		{
		    unless( $class->has_value({scof => $individual}) )
		    {
			dlog "AUTOCREATING class-individual for ".$obj->sysdesig;
			push  @AUTOCREATED, $class->add_arc({scof => $individual});
		    }
		}

		unless( $obj->has_value({is => $individual}) )
		{
		    dlog "AUTOCREATING individual for ".$obj->sysdesig;
		    push  @AUTOCREATED, $obj->add_arc({is => $individual});
		}
	    }
	    elsif( $pred_obj->valtype->equals($ia) and
		   $obj->has_value({is => $mia}) and
		   not $obj->has_value({is => $ia}) )
	    {
		push  @AUTOCREATED, $obj->add_arc({is => $organization});
		# See Saffron Walden
	    }
	    elsif( $pred_obj->valtype->equals($information_store) )
	    {
		unless( $obj->has_value({is => $information_store}) )
		{
		    dlog "AUTOCREATING information_store for ".$obj->sysdesig;
		    push  @AUTOCREATED, $obj->add_arc({is => $information_store});
		}
	    }
	    elsif( $pred_obj->valtype->equals($practisable) )
	    {
		unless( $obj->has_value({is => $practisable}) )
		{
		    dlog "AUTOCREATING practisable for ".$obj->sysdesig;
		    push  @AUTOCREATED, $obj->add_arc({is => $practisable});
		}
	    }

	    $props{obj} = $obj->id;
	    $value_obj = $obj;
	}
	else
	{
	    my $val = $rec->{rel_value};
	    return unless length $val;
	    $props{value} = $val;

	    my $valtype = $pred_obj->valtype;
	    $value_obj = Rit::Base::Resource->
	      get_by_anything( $val,
			       {
				valtype => $valtype,
				subj_new => $subj,
				pred_new => $pred_obj,
			       });

	    debug sprintf "Creating %s --%s--> %s",
	      $subj->sysdesig, $pred, $value_obj->sysdesig;
	}

	# validation
	eval
	{
	    Rit::Base::Arc->validate_valtype({
					      subj => $subj,
					      pred => $pred_obj,
					      value => $value_obj,
					     });
	};
	if( my $err = catch(['validation']) )
	{
	    if( $pred_obj eq $preds[-1][0] )
	    {
		dlog "/~~~~~";
		dlog $errmsg;
		dlog $err;
		dlog "\_____";
		return;
#		debug "*****************************************************";
	    }
	    else
	    {
		debug $err;
		debug "Trying next pred";
		next;
	    }
	};

	my $arc = Rit::Base::Arc->create(\%props);

	my $desc = $rec->{rel_comment};
	if( defined $desc and length $desc )
	{
	    $arc->add({description=>$desc});
	}

	return $TOPIC{$id}{node} = $arc;
    }

    return;
}


##############################################################################

sub dlog
{
    my $msg = debug(@_);
    $LOG->print($msg);
}


##############################################################################

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
#  media        | !
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
#  t            | !
#  talias       | !
#  ts           | !
#  zip          | !

