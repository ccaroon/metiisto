package Metiisto::Entry;
################################################################################
use strict;

use base 'Metiisto::Base';

__PACKAGE__->table('entries');
__PACKAGE__->columns(All => qw/id task_date entry_date ticket_num subject description category goal_id/);
__PACKAGE__->has_a_datetime('task_date');
__PACKAGE__->has_a_datetime('entry_date');
################################################################################
1;
