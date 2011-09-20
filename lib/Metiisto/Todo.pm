package Metiisto::Todo;
################################################################################
use strict;

use base 'Metiisto::Base';
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
1;
