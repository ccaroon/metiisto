package Metiisto::Note;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('notes');
__PACKAGE__->columns(All => qw/
    id title body is_favorite is_encrypted
    created_date updated_date deleted_date
/);
__PACKAGE__->has_a_datetime('created_date');
__PACKAGE__->has_a_datetime('updated_date');
__PACKAGE__->has_a_datetime('deleted_date');
################################################################################
1;
