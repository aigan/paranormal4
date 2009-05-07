package Para;
#==================================================== -*- cperl -*- ==========
#
# DESCRIPTION
#   Paranormal.se overview class
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

use 5.010;
use strict;
use warnings;

use File::stat;

use Para::Frame::Reload;
use Para::Frame::Utils qw( debug paraframe_dbm_open );
use Para::Frame::Time qw( now duration );

use Rit::Base::Utils qw( parse_propargs );

use Para::Setup;

#use Para::Member;
#use Para::Topic;
#use Para::Widget;
#use Para::Interest;
#use Para::Interests::Tree;
#use Para::Email;
#use Para::Calendar;
#use Para::Domains;



our $CFG;
our $DOMAINS;

##############################################################################

=head2 new

Construct a class object singelton

=cut

sub new
{
    return bless {}, "Rit::Guides";
}


##############################################################################

=head2 store_cfg

=cut

sub store_cfg
{
    $CFG = $_[1];
}


##############################################################################

=head2 on_done

  Runs after each request

=cut

sub on_done ()
{
}


##############################################################################

=head2 on_configure

Adds class given by C<resource_class> as a parent to
L<Para::Resource>. That class must be loaded during startup.


=cut

sub on_configure
{
    if( my $resource_class = $Para::Frame::CFG->{'resource_class'} )
    {
	debug "Adding $resource_class";
	push @Rit::Base::Resource::ISA, $resource_class;
    }
}

##############################################################################

=head2 initialize_db

=cut

sub initialize_db
{
    debug "initialize_db";

#    return; ### NOTHING TO DO HERE NOW

    if( $ARGV[0] eq 'setup_db' )
    {
	Para::Setup->setup_db();
    }
    elsif( $ARGV[0] eq 'vacuum_all' )
    {
	$Rit::Base::VACUUM_ALL = 1;
    }

    if( $Rit::Base::VACUUM_ALL )
    {
	my $req = Para::Frame::Request->new_bgrequest();
	my $start = $ARGV[1] || 99999999;
	my $vnodes_sth = $Rit::dbix->dbh->prepare("select * from arc where active is true and ver <= $start order by ver desc");
	$vnodes_sth->execute;

	debug sprintf "Vacuuming %d arcs", $vnodes_sth->rows;
	my $obj_node_cnt = 0;
	while( my $rec = $vnodes_sth->fetchrow_hashref )
	{
	    my $arc = Rit::Base::Arc->get_by_rec($rec);
	    # Giving id for traceback debugging
	    $arc->vacuum(undef,$arc->id);

	    unless( ++$obj_node_cnt % 1000 )
	    {
		Rit::Base::Resource->commit;
		$Rit::dbix->commit;
		debug sprintf "%6d VACUUMED %d",$obj_node_cnt, $arc->id;
	    }
	}
	$Para::Frame::REQ->done;
    }


#    my $dbh =  $Rit::dbix->dbh;
#
#    my $req = Para::Frame::Request->new_bgrequest();
#    my( $args, $arclim, $res ) = parse_propargs('auto');
#
#    my $R = Rit::Base->Resource;
#    my $P = Rit::Base->Pred;
#    my $C = Rit::Base->Constants;
#
#    $res->autocommit;
#    $R->commit;
#
#    debug 1, "Adding/updating nodes and preds: done!";
}

##############################################################################

sub on_memory
{
    my( $size ) = @_;

    debug "Planning to clear some memory";
}


##############################################################################

sub clear_caches
{
    debug "Should clear caches";
}


##############################################################################

sub add_background_jobs
{
    my( $delta, $sysload ) = @_;
    my( $req ) = $Para::Frame::REQ;

    my $added = 0;


    foreach my $t ( values %$Para::Topic::TO_PUBLISH_NOW,
		    values %$Para::Topic::TO_PUBLISH )
    {
	$req->add_job('run_code', sub
		      {
			  $t->publish;
		      });
	$added ++;
    }


    # These are qick enough to be done directly
    #
    &timeout_login;

    $req->add_job('run_code', \&Para::Place::fix_zipcodes);

    $req->add_job('run_code', \&Para::Calendar::do_planned_actions);

    eval
    {
	unless( $added )
	{
	    $added += Para::Topic->publish_from_queue();
	}

	unless( $added )
	{
	    $added += Para::Topic->vacuum_from_queue(1);
	}
    };
    if( $@ )
    {
	debug "ERROR while setting up jobs:";
	debug $@;
    }
    else
    {
	debug "Finished setting up background jobs";
    }
    return 1;
}


##############################################################################

sub timeout_login
{
    my( $req ) = @_;

    debug "Should timeout login";
    return;


    my $recs = $Para::dbix->select_list("select member from member where latest_in is not null and (latest_out is null or latest_in > latest_out) order by latest_in");

    my $online = Para::Member->currently_online(2);
    my %seen = ();

    my $now = now();

    foreach my $rec ( $recs->as_array, @$online )
    {
	my $mid = $rec->{'member'};
	my $m = Para::Member->get_by_id( $mid );
	next if $seen{$mid} ++;

	unless( $mid == $m->id )
	{
	    debug "Member $mid has been removed from the db";
	    my $db = paraframe_dbm_open( $CFG->{DB_ONLINE} );
	    delete $db->{$mid};
	    next;
	}

	my $latest_in = $m->latest_in;
	my $latest_seen = $m->latest_seen;

	unless( $latest_in and $latest_seen )
	{
	    debug "$mid: ".$m->desig." should never have been set as online";
	    my $db = paraframe_dbm_open( $CFG->{DB_ONLINE} );
	    delete $db->{$mid};
	    next;
	}

	# Failsafe in case no logout was registred
	if( $latest_in->delta_ms($now) > duration( hours => 40 ) )
	{
	    debug "$mid: ".$m->desig." has been online since $latest_in";
	    $m->on_logout( $latest_in->add(hours=>1) );
	}
	elsif( $latest_seen->delta_ms($now) > duration( minutes => 30 ) )
	{
	    debug "Logging out ".$m->desig;
	    $m->on_logout( $now );
	}
    }
}


##############################################################################

sub display_slogan
{
    return "Should return a slogan";

    unless( @Para::slogans )
    {
	my $recs = $Para::dbix->select_list('from slogan');
	foreach my $rec ($recs->as_array )
	{
	    push @Para::slogans, $rec->{'slogan_text'};
	}
    }

    srand();
    my $rand = int(rand(@Para::slogans));
    return $Para::slogans[$rand];
}


##############################################################################

sub domains
{
    return $DOMAINS ||= Para::Domains->new;
}


##############################################################################

1;
