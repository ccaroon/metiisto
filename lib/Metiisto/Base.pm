package Metiisto::Base;
################################################################################
use strict;

use Class::DBI::AbstractSearch;
use Dancer2::Plugin::Database;

use Metiisto::Util::DateTime;
use base 'Class::DBI';

sub db_Main { return database; }
__PACKAGE__->set_sql(count => "SELECT COUNT(*) FROM __TABLE__");
__PACKAGE__->set_sql(count_where => "SELECT COUNT(*) FROM __TABLE__ WHERE %s");
################################################################################
sub count
{
    my $class = shift;
    return ($class->sql_count()->select_val());
}
################################################################################
sub count_where
{
    my $class = shift;
    my $where = shift;
    my $placeholders = shift || [];
    
    $where =~ s/^\s*where//i;
    
    return ($class->sql_count_where($where)->select_val(@$placeholders));
}
################################################################################
sub has_a_datetime
{
    my $class = shift;
    my $field = shift;

    $class->has_a( $field => 'Metiisto::Util::DateTime',
        inflate  => sub {
            my $date_str = shift || undef;
            return (Metiisto::Util::DateTime->parse($date_str));
        },
        deflate  => sub {
            my $dt = shift;
            return ($dt->format_db());
        },
    );
}
################################################################################
# TODO: HACK, HACK!!
# I don't like this, but without it Class::DBI issues a warn that causes
# Dancer to 500. Development mode only?
sub DESTROY
{
    my $this = shift;
    
    if ($this->is_changed())
    {
        $this->discard_changes();
    }
}
################################################################################
1;
