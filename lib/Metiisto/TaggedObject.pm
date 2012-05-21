package Metiisto::Tag;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('tagged_object');
__PACKAGE__->columns(All => qw/
    id tag_id obj_class obj_id
/);
__PACKAGE__->has_a(tag_id => 'Metiisto::Tag');
################################################################################
sub tag
{
    my $this = shift;
    return ($this->tag_id());
}
################################################################################
1;
