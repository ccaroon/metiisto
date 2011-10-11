package Metiisto::Todo;
################################################################################
use strict;

use base 'Metiisto::Base';

use constant DUE_SOON => 86_400*7;
################################################################################
__PACKAGE__->table('todos');
__PACKAGE__->columns(All => qw/
    id priority title created_on completed completed_on due_on list_id
    description
/);
__PACKAGE__->has_a_datetime('created_on');
__PACKAGE__->has_a_datetime('completed_on');
__PACKAGE__->has_a_datetime('due_on');
################################################################################
# TODO: add relationship to list (list_id)
################################################################################
sub due_soon
{
    my $this = shift;
    my $due_soon = 0;
    
    my $now    = time;
    my $due_on = defined $this->due_on() ? $this->due_on()->epoch() : undef;
    if ($due_on and $due_on > $now and ($due_on - $now < DUE_SOON))
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
    my $due_on = defined $this->due_on() ? $this->due_on()->epoch() : undef;
    if ($due_on and $due_on < $now)
    {
        $overdue = 1;
    }

    return($overdue);
}
################################################################################
1;
