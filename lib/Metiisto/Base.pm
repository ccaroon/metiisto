package Metiisto::Base;
################################################################################
use strict;

use Class::DBI::AbstractSearch;
use Dancer::Plugin::Database;

use Metiisto::Util::DateTime;
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
sub has_a_datetime
{
    my $class = shift;
    my $field = shift;

    $class->has_a( $field => 'Metiisto::Util::DateTime',
        inflate  => sub {
            my $date_str = shift;
            return (Metiisto::Util::DateTime->parse($date_str));
        },
        deflate  => sub {
            my $dt = shift;
            return ($dt->format("%Y-%m-%d %H:%M:%S"));
        },
    );
}
################################################################################
1;
