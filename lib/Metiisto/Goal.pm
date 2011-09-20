package Metiisto::Goal;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('goals');
__PACKAGE__->columns(All => qw/
    id priority name description created_on updated_on completed completed_on
    percent_complete
/);
__PACKAGE__->has_a_datetime('created_on');
__PACKAGE__->has_a_datetime('updated_on');
__PACKAGE__->has_a_datetime('completed_on');
################################################################################
1;
