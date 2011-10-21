package Metiisto::Goal;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('goals');
__PACKAGE__->columns(All => qw/
    id priority name description completed completed_date percent_complete
/);
__PACKAGE__->has_a_datetime('completed_date');
################################################################################
1;
