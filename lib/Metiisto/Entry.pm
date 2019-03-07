package Metiisto::Entry;
################################################################################
use strict;

use Metiisto::Jira;
use Metiisto::Util::DateTime;

use base qw(Metiisto::Base Metiisto::Taggable);

use constant CATEGORY_MEETING     => 'Meeting';
use constant CATEGORY_TICKET      => 'Ticket';
use constant CATEGORY_CODE_REVIEW => 'Code Review';
use constant CATEGORY_OPERATIONAL => 'Operational';
use constant CATEGORY_OTHER       => 'Other';
use constant CATEGORIES => [
    CATEGORY_MEETING,
    CATEGORY_TICKET,
    CATEGORY_CODE_REVIEW,
    CATEGORY_OPERATIONAL,
    CATEGORY_OTHER,
];

__PACKAGE__->table('entries');

__PACKAGE__->columns(Primary   => qw/id/);
__PACKAGE__->columns(Essential => qw/task_date ticket_num parent_ticket subject category time_spent/);
__PACKAGE__->columns(Other     => qw/entry_date description/);

__PACKAGE__->has_a_datetime('task_date');
__PACKAGE__->has_a_datetime('entry_date');

__PACKAGE__->init_tagging();
################################################################################
sub ticket_link
{
    my $this = shift;
    my $for_parent = shift;

    my $ticket_num = $this->ticket_num();
    if ($for_parent) {
        $ticket_num = $this->parent_ticket();
    }

    my $link = "";
    if ($ticket_num) {
        # HACK: need to make more generic
        my $jira = Metiisto::Jira->by_name("webassign");
        if ($ticket_num =~ /^DO-/) {
            $jira = Metiisto::Jira->by_name("cengage");
        }
        $link = $jira->browse_link($ticket_num)
    }

    return ($link);
}
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
sub find_week
{
    my $class = shift;
    my %args  = @_;

    my $conditions = $args{where} || {};

    my $start_date = Metiisto::Util::DateTime->sunday(for_date => $args{date});
    my $start_str = $start_date->format_db(date_only => 1);
    $start_date->add_days(days => 6);
    my $end_str = $start_date->format_db(date_only => 1);
    $conditions->{task_date} = { 'between' => [$start_str, $end_str] };

    my @search_opts = (
        $conditions,
        {
            order_by => 'task_date, entry_date',
        }
    );
    
    my @results = wantarray
        ? Metiisto::Entry->search_where(@search_opts)
        : scalar Metiisto::Entry->search_where(@search_opts);
    
    return(wantarray ? @results : $results[0]);
}
################################################################################
1;
