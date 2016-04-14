package Metiisto::TaggedObject;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('tagged_object');

__PACKAGE__->columns(Primary  => qw/id/);
__PACKAGE__->columns(Tag      => qw/tag_id/);
__PACKAGE__->columns(Object   => qw/obj_class obj_id/);

__PACKAGE__->has_a(tag_id => 'Metiisto::Tag');

__PACKAGE__->set_sql(tags_by_type => qq{
SELECT id,tag_id FROM tagged_object
WHERE obj_class = ?
GROUP BY tag_id
});
################################################################################
sub tag
{
    my $this = shift;
    return ($this->tag_id());
}
################################################################################
sub object
{
    my $this = shift;
    
    my $obj_class = $this->obj_class();
    
    eval "require $obj_class;";
    my $object = $obj_class->retrieve($this->obj_id());
    
    return ($object);
}
################################################################################
1;
