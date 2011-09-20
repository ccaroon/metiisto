package Metiisto::Note;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('notes');
__PACKAGE__->columns(All => qw/
    id title created_on updated_on body is_favorite is_encrypted deleted_on
/);
__PACKAGE__->has_a_datetime('created_on');
__PACKAGE__->has_a_datetime('updated_on');
__PACKAGE__->has_a_datetime('deleted_on');
################################################################################
1;
