package Metiisto::Todo;
################################################################################
use strict;

use Metiisto::Util::DateTime;

use base qw(Metiisto::Base Metiisto::Taggable);

use constant DUE_SOON => 86_400*7;
################################################################################
__PACKAGE__->table('todos');

__PACKAGE__->columns(Primary   => qw/id/);
__PACKAGE__->columns(Essential => qw/priority title completed_date due_date/);
__PACKAGE__->columns(Other     => qw/completed list_id description repeat_duration parent_id/);

__PACKAGE__->has_a(list_id => 'Metiisto::List');
__PACKAGE__->has_a_datetime('completed_date');
__PACKAGE__->has_a_datetime('due_date');

__PACKAGE__->has_a(parent_id => 'Metiisto::Todo');
__PACKAGE__->has_many(sub_tasks => 'Metiisto::Todo', { order_by => 'priority, due_date' });

__PACKAGE__->init_tagging();
################################################################################
sub list
{
    my $this = shift;
    return ($this->list_id());
}
################################################################################
sub due_soon
{
    my $this = shift;
    my $due_soon = 0;
    
    my $now    = time;
    my $due_date = defined $this->due_date() ? $this->due_date()->epoch() : undef;
    if ($due_date and $due_date > $now and ($due_date - $now < DUE_SOON))
    {
        $due_soon = 1;
    }
    
    return($due_soon);
}
################################################################################
sub overdue
{
    my $this = shift;
    my $overdue = 0;

    my $now    = time;
    my $due_date = defined $this->due_date() ? $this->due_date()->epoch() : undef;
    if ($due_date and $due_date < $now)
    {
        $overdue = 1;
    }

    return($overdue);
}
################################################################################
# TODO: If has sub_tasks, mark those complete too
sub mark_complete
{
    my $this = shift;

    if ($this->due_date() && $this->repeat_duration())
    {
        my $repeat = $this->repeat_duration();
        $repeat =~ /^(\d)+\s+(.*)$/;
        my $count = $1;
        my $units = $2;

        # I.e. copy due_date
        my $new_due_date = Metiisto::Util::DateTime->new(
            epoch => $this->due_date()->epoch());

        $new_due_date->add(count => $count, units => $units);

        my $new_todo = $this->copy({due_date => $new_due_date});
    }

    $this->completed_date(Metiisto::Util::DateTime->now());
    $this->completed(1);
    $this->update();
}
################################################################################
1;
