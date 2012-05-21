package Metiisto::Tag;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('tags');
__PACKAGE__->columns(All => qw/
    id name
/);
__PACKAGE__->has_many(objects => 'Metiisto::TaggedObject');
################################################################################
1;
