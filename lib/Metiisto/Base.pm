package Metiisto::Base;
################################################################################
# $Id: $
################################################################################
use strict;

use Class::DBI::AbstractSearch;
use Dancer::Plugin::Database;

use base 'Class::DBI';

sub db_Main { return database; }
__PACKAGE__->set_sql(count => "SELECT COUNT(*) FROM __TABLE__");
#__PACKAGE__->connection('dbi:mysql:workman_devel', 'ccaroon', 'Vepkef21');
################################################################################
sub count
{
    my $class = shift;
    return ($class->sql_count()->select_val());
}
################################################################################
1;
