package Metiisto::Controller::TaggedObjects;
################################################################################
use strict;

use Dancer ':syntax';
use base 'Metiisto::Controller::Base';

use Lingua::EN::Inflect qw(PL);

use Metiisto::Tag;
use Metiisto::TaggedObject;
################################################################################
sub list
{
    my $this = shift;
    my $tag_name = params()->{tag};
    my $tag_type = params()->{type};
    
    my $tag = Metiisto::Tag->retrieve(name => $tag_name);
    
    my $out;
    if (defined $tag)
    {
        my %tickets;
        my @objects = $tag->objects();
        my $count   = 0;
        my %valid_types;

        my %template_data = (tag_name => $tag->name(), tag_type => $tag_type);
        foreach my $obj (@objects)
        {
            my $type = $obj->obj_class();
            $type =~ s/^Metiisto:://;
            $type = lc $type;
            $valid_types{$type} = ucfirst PL($type);

            if ($tag_type) {
                next unless $type eq $tag_type;                
            }

            $count++;

            $template_data{$type} = [] unless defined $template_data{$type};
            push @{$template_data{$type}}, $obj->object();
            
            if ($type eq 'entry'
                and
                $obj->object()->category() eq Metiisto::Entry->CATEGORY_TICKET
            )
            {
                $tickets{$obj->object()->ticket_num()} = $obj->object()->subject();
            }
        }

        my @types = sort keys %valid_types;
        $template_data{types} = \%valid_types;
        $template_data{count} = $count;
        $template_data{tickets} = \%tickets;
        if ($tag_type) {
            $out = template "tagged_objects/list_by_type", \%template_data;
        }
        else {
            $out = template 'tagged_objects/list', \%template_data;
        }
    }
    else
    {
        my $dym_html = '';

        my @matches = Metiisto::Tag->search_like(name => "%$tag_name%");
        if (@matches)
        {
            my %cloud_data;
            map {$cloud_data{$_->name()} = $_->objects()->count()} @matches;

            my $cloud_html = template 'tags/cloud.tt',
                {
                    cloud_data => \%cloud_data
                },
                { layout => undef };

            $dym_html =<<EOF;
<p>
    Did You Mean:
    <br>
    $cloud_html
</p>
EOF
        }

        $out = template 'error', {
            title => "Tag Search Error",
            message => <<EOF,
<p>Tag not found: '$tag_name'</p>
$dym_html
<a href="/tags">View All Tags</a>
EOF
        }
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
