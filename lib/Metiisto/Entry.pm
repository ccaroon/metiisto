package Metiisto::Entry;
################################################################################
# $Id: $
################################################################################
use strict;

use base 'Metiisto::Base';

__PACKAGE__->table('entries');
__PACKAGE__->columns(All => qw/id task_date entry_date ticket_num subject description category goal_id/);
################################################################################
1;
