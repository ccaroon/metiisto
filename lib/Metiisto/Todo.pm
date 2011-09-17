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
################################################################################
# TODO: add relationship to list (list_id)
################################################################################
1;
