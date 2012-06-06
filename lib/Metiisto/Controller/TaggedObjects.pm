package Metiisto::Controller::TaggedObjects;
################################################################################
use strict;

use Dancer ':syntax';

use Metiisto::Util::DateTime;

use base 'Metiisto::Controller::Base';

use Metiisto::Tag;
use Metiisto::TaggedObject;
################################################################################
sub list
{
    my $this = shift;
    my $tag_name = params()->{tag};
    
    my $tag = Metiisto::Tag->retrieve(name => $tag_name);
    
    my $out;
    if (defined $tag)
    {
        my @objects = $tag->objects();
        my $count   = $tag->objects()->count();

        my %template_data = (tag_name => $tag->name(), count => $count);
        foreach my $obj (@objects)
        {
            my $type = $obj->obj_class();
            $type =~ s/^Metiisto:://;
            $type = lc $type;
    
            $template_data{$type} = [] unless defined $template_data{$type};
            push @{$template_data{$type}}, $obj->object();
        }
    
        $out = template 'tagged_objects/list', \%template_data;
    }
    else
    {
        $out = template 'error', {
            title => "Tag Search Error",
            message => "Tag not found: '$tag_name'"}
    }

    return ($out);
}
################################################################################
sub declare_routes
{
    my $class = shift;

    # List
    get "/tagged_objects" => sub {
        my $c = $class->new();
        my $out = $c->list();
        return ($out);
    };
}
################################################################################
1;
