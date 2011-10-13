package Metiisto::Entry;
################################################################################
use strict;

use Metiisto::Util::DateTime;

use base 'Metiisto::Base';

use constant CATEGORIES => [
    'Meeting',
    'Ticket',
    'Code Review',
    'Operational',
    'Goal Progress',
    'Other',
];

__PACKAGE__->table('entries');
__PACKAGE__->columns(All => qw/
    id task_date entry_date ticket_num subject description category goal_id
/);
__PACKAGE__->has_a_datetime('task_date');
__PACKAGE__->has_a_datetime('entry_date');
# TODO: has_a: goal -- deprecate goals
################################################################################
sub recent_subjects
{
    my $class = shift;
    
    my @subjects;
    my $date = Metiisto::Util::DateTime->new(epoch => time - (31 * 86400));
    
    my $stmt = $class->db_Main()->prepare_cached(
        "select distinct(subject) from entries where task_date >= ?");
    $stmt->execute($date->format_db());

    while (my $row = $stmt->fetchrow_arrayref())
    {
        push @subjects, $row->[0];
    }

    return (wantarray ? @subjects : \@subjects);
}
################################################################################
sub this_week
{
    my $class = shift;
    
    my $start_date = Metiisto::Util::DateTime->monday();
    my $mon_str = $start_date->format_db(date_only => 1);
    $start_date->add_days(days => 4);
    my $fri_str = $start_date->format_db(date_only => 1);

    return(
        Metiisto::Entry->search_where
        (
            {
                task_date => { 'between' => [$mon_str, $fri_str] },
            },
            {
                order_by => 'task_date, entry_date',
            }
        )
    );
}
################################################################################
1;
