package Metiisto::Todo;
################################################################################
use strict;

use base 'Metiisto::Base';

use constant DUE_SOON => 86_400*7;
################################################################################
__PACKAGE__->table('todos');
__PACKAGE__->columns(All => qw/
    id priority title completed completed_date due_date list_id
    description
/);
__PACKAGE__->has_a_datetime('completed_date');
__PACKAGE__->has_a_datetime('due_date');
################################################################################
# TODO: add relationship to list (list_id)
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
