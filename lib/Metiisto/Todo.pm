package Metiisto::Todo;
################################################################################
use strict;

use base qw(Metiisto::Base Metiisto::Taggable);

use constant DUE_SOON => 86_400*7;
################################################################################
__PACKAGE__->table('todos');

__PACKAGE__->columns(Primary   => qw/id/);
__PACKAGE__->columns(Essential => qw/priority title completed_date due_date/);
__PACKAGE__->columns(Other     => qw/completed list_id description/);

__PACKAGE__->has_a(list_id => 'Metiisto::List');
__PACKAGE__->has_a_datetime('completed_date');
__PACKAGE__->has_a_datetime('due_date');

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
1;
