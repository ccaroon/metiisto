package Metiisto::Taggable;
################################################################################
use strict;

use Metiisto::Tag;
use Metiisto::TaggedObject;
################################################################################
sub init_tagging
{
    my $class = shift;
    $class->add_trigger(after_delete => \&_after_delete_trigger);
}
################################################################################
# ARGS:
#   - tags => undef, string or ArrayRef of strings
################################################################################
sub update_tags
{
    my $this = shift;
    my %args = @_;
    
    my $class = ref($this);
    # Convert 'tags' input to valid ArrayRef
    my $tags = $this->_normalize_tags(tags => $args{tags});

    # Load existing tags
    my @existing_tags = Metiisto::TaggedObject->search(obj_class => $class,
        obj_id => $this->id());
    
    # Find or create new tags
    my @new_tags;
    foreach my $t (@$tags)
    {
        my $tag = Metiisto::Tag->find_or_create({name => $t});
        push @new_tags, $tag;
    }

    # Tag object with new tags
    foreach my $nt (@new_tags)
    {
        unless (grep { $nt->id() == $_->tag()->id() } @existing_tags)
        {
            Metiisto::TaggedObject->insert({
                tag_id    => $nt->id(),
                obj_class => $class,
                obj_id    => $this->id()
            });
        }
    }

    # Un-tag object with removed tags
    my %tags_to_check;
    foreach my $et (@existing_tags)
    {
        unless (grep { $et->tag()->id() == $_->id() } @new_tags)
        {
            $tags_to_check{$et->tag()->id()} = $et->tag();
            $et->delete();
        }
    }
    
    # Delete unused tags
    foreach my $t (values %tags_to_check)
    {
        $t->delete()
            unless Metiisto::TaggedObject->count_where("tag_id = ?",[$t->id()]) > 0;
    }
}
################################################################################
sub get_tags
{
    my $this = shift;
    my $class = ref($this);
    
    my @tos = Metiisto::TaggedObject->search(obj_class => $class,
        obj_id => $this->id());
    
    my @tags = map { $_->tag() } @tos;
    
    return( wantarray ? @tags : \@tags );
}
################################################################################
sub _after_delete_trigger
{
    my $this = shift;

    my @tos = Metiisto::TaggedObject->search(
        obj_class => ref($this),
        obj_id    => $this->id(),
    );

    foreach my $to (@tos)
    {
        # Only one object is tagged with the tag and it's THIS object.
        # So...delete the Tag and the TaggedObject
        if (Metiisto::TaggedObject->count_where("tag_id = ?",[$to->tag()->id()]) == 1)
        {
            # Deleting the Tag also deletes all it's TaggedObjects
            $to->tag()->delete();
        }
        # More than one object is tagged with the tag...
        # So...only delete the TaggedObject.
        else
        {
            $to->delete();
        }
    }
}
################################################################################
sub _normalize_tags
{
    my $this = shift;
    my %args = @_;

    my $tags = $args{tags};
    
    if (defined $tags)
    {
        unless(ref($tags) eq 'ARRAY')
        {
            $tags = [$tags];
        }
    }
    else
    {
        $tags = [];
    }

    return ($tags);
}
################################################################################
1;
