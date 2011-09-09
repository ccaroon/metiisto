package Metiisto::Base;
################################################################################
# $Id: $
################################################################################
use strict;

use Dancer::Plugin::Database;

use base 'Class::DBI';

sub db_Main { return database; }
#__PACKAGE__->connection('dbi:mysql:workman_devel', 'ccaroon', 'Vepkef21');
################################################################################
1;
