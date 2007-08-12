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

use Rit::Base::Utils qw( valclean );

sub setup_db
{
    my $dbix = $Rit::dbix;
    my $dbh = $dbix->dbh;
    my $now = DateTime::Format::Pg->format_datetime(now);






    $dbh->commit;

    print "Done!\n";

    return;
}

1;
