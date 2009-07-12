package Para::Resource;

=head1 NAME

Para::Resource

=cut

use 5.010;
use strict;
use warnings;
use utf8;

use constant UMASK => 02;

use Para::Frame::Reload;
use Para::Frame::Utils qw( debug datadump throw );

use Rit::Base::Constants qw( );
use Rit::Base::Resource;
use Rit::Base::Utils qw( parse_propargs is_undef );


##############################################################################

=head2 set_url_part

Generates and returns the part name to use as a part of a unique URL
among all nodes of this class.

These should be unique within the same city.

Returns:

A L<Rit::Base::Literal::String> node or L<Rit::Base::Undef>

=cut

sub set_url_part
{
    die "FIXME";

#    my( $node, $args ) = @_; # no parsing
#
#    my $city_list = $node->in_region({is=>$C_city},$args);
#    if( $city_list->size > 1 )
#    {
#	$node->add_note("Placed in more than one city");
#    }
#    elsif( $city_list->size < 1 )
#    {
#	$node->add_note("Not placed in a city");
#    }
#    my $city = $city_list->get_first_nos;
#    $city->defined or return undef;
#
#    my $city_part = $city->get_set_url_part($args)->plain
#      or return is_undef;
#
#    my $req = $Para::Frame::REQ;
#    my $lang = $req->language;
#    $req->set_language('en');
#    my $name = $node->list('name',undef,$args)->loc
#      or return is_undef;
#    my $test_base = name2url( $name );
#    $req->set_language($lang);
#
#    $test_base =~ s/\s+ab?$//; # AB et al
#
#    if( not $test_base )
#    {
#	$test_base = 'undefined';
#	$node->add_note("Name undefined");
#    }
#    elsif( $test_base eq $city_part )
#    {
#	debug $node->sysdesig.": Name is equal to the city";
#    }
#    else
#    {
#	# Remove parts equal to city
#	my @words;
#	foreach my $word ( split /_/, $test_base )
#	{
#	    unless( $word eq $city_part )
#	    {
#		push @words, $word;
#	    }
#	}
#	$test_base = join '_', @words;
#
#	$test_base =~ s/_in?$//; # in city...
#    }
#
#
#    # See if the url part is taken
#
#    my $test_part = $test_base;
#    my $count = 0;
#    my $name_part;
#
#    unless( $test_part )
#    {
#	confess "Failed getting test_part for $node->{id}";
#    }
#
#    while( not $name_part )
#    {
#	debug "Looking for $test_part in ".$city->desig;
#
#	my $alts = Rit::Base::Resource->find({
#					      in_region => $city,
#					      is => $C_tourist_related_client,
#					      url_part => $test_part,
#					      id_ne => $node,
#					     }, $args);
##	debug "Search done";
#	if( $alts->size )
#	{
#	    $count++;
#	    $test_part = $test_base . $count;
#	}
#	else
#	{
#	    $name_part = $test_part;
#	}
#    }
#
#    $node->update({url_part=>$name_part},
#		  { %$args, activate_new_arcs => 1 });
#    return $node->first_prop('url_part', undef, $args);
}


##############################################################################

=head2 get_set_url_part

Returns url_part

Generates it if it's not defined yet

=cut


sub get_set_url_part
{
    my( $node, $args ) = @_;
    return
      $node->first_prop('url_part', undef, $args) ||
	$node->set_url_part($args);
}


##############################################################################

=head2 page_presentation

  $node->page_presentation

  $node->page_presentation( $part, \%args )

params:

Returns:

A L<Para::Frame::Page> object.

Or undef, if there is no valid page presentation URL present.

=cut


sub page_presentation
{
    # The same path for publication and access
    return shift->page_presentation_template(@_);
}


##############################################################################

=head2 page_presentation_template

  $node->page_presentation_template

  $node->page_presentation_template( $part, \%args )

params:

Returns:

A L<Para::Frame::Page> object.

Or undef, if there is no valid page presentation template present.

=cut


sub page_presentation_template
{
    my( $node, $part, $args_in ) = @_;
    my $args = parse_propargs($args_in);

#    debug "page_presentation with args ".datadump($args,3);

    my( $req ) = $Para::Frame::REQ;
    my $site = $req->site;
    my $site_code = $site->code;

    my $prefix = $args->{'go_prefix'} || '';

    my $dir;
    if( $node->{'page_presentation_template'}{$prefix}{$site_code} )
    {
	$dir = $node->{'page_presentation_template'}{$prefix}{$site_code};
    }
    else
    {
	my $path = $node->pc_public_path;
	return undef unless $path;


	$path =~ s/\.html$//;
	my $home = $site->home_url_path;

	my $url = "$home$prefix$path/";

	my $args = {};
	$args->{'url'} = $url;
	$args->{'file_may_not_exist'} = 1;
	$args->{'site'} = $site;

	debug "GENERATING presentation page template";
	$dir = $node->{'page_presentation_template'}{$prefix}{$site_code}
	    = Para::Frame::Dir->new($args);
    }

    if( $part )
    {
	return $dir->get_virtual( $part );
    }
    else
    {
	return $dir;
    }
}


##############################################################################

=head2 publish

Generates the presentation page for the object

=cut

sub publish
{
    my( $node, $part, $args ) = @_;

    my $req = $Para::Frame::REQ;
    my $site = $req->site;

    my $srcroot =  Para::Frame::Dir->new({  filename =>
					    $site->appback->[0] . "/multi"
					 });

    $part ||= 'index.html';

    debug "publishing ".$node->id." $part";

    my $page_dest = $node->page_presentation_template(undef,$args)->as_dir;
    my $target = $page_dest->get_virtual($part)->target_with_lang({ext=>'html'});

    debug "PUBLISHING --> ".$target->sysdesig;

    # process file
    my $part_src = $part;
    $part_src =~ s/\.html$/.html_tt/;
    my $page_src = $srcroot->get_virtual("/default/$part_src");

    unless( $page_src->exist )
    {
	throw('notfound', $page_src->sys_path_slash." not found");
#	throw('notfound', $target->url_path_slash." not found");
    }


    $target->set_depends_on([$page_src]);

    $target->precompile({
                         type => 'html',
                         template => $page_src,
                         template_root => $srcroot,
                         params =>
                         {
                          item => $node,
                         },
                         umask => UMASK,
                         default_propargs => $args,
                        });

    return $target;
}


##############################################################################

=head2 unpublish

Removes any published pages in /go/

=cut

sub unpublish
{
    my( $node ) = @_;

    my $req = $Para::Frame::REQ;
    my $page = $node->page_presentation_template
      or return undef;
    my $dir = $page->dir;
    if( $dir->exist )
    {
	$dir->remove;
	return 1;
    }
    return 0;
}


##############################################################################


1;
