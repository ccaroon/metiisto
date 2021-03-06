package Metiisto::Controller::Lists;
################################################################################
use strict;

use Data::Page;
use Dancer ':syntax';
use SQL::Abstract;

use Metiisto::Tag;
use Metiisto::Util::DateTime;

use constant LISTS_PER_PAGE => 18;

use base 'Metiisto::Controller::Base';

use Metiisto::List;
################################################################################
sub list
{
    my $this = shift;

    my $total      = 0;
    my $conditions = {};
    if (params->{filter_text})
    {
        $conditions->{name} = { 'regexp', params->{filter_text} };
    }
    else
    {
        $conditions->{1} = 1;
    }

    my $sql_abs = SQL::Abstract->new();
    my ($where, @binds) = $sql_abs->where($conditions);
    $total = Metiisto::List->count_where($where, \@binds);

    my $page = Data::Page->new();
    $page->total_entries($total);
    $page->entries_per_page(LISTS_PER_PAGE);
    $page->current_page(params->{page} || 1);

    my @lists = Metiisto::List->search_where(
        $conditions,
        {
            limit_dialect => 'LimitOffset',
            limit    => LISTS_PER_PAGE,
            offset  => $page->first() ? $page->first() - 1 : 0,
            order_by => 'name',
        }
    );

    my $out = template 'lists/list', {
        lists => \@lists,
        pagination => {
            current_page  => $page->current_page(),
            first_page    => $page->first_page(),
            last_page     => $page->last_page(),
            previous_page => $page->previous_page(),
            next_page     => $page->next_page(),
        }
    };

    return ($out);
}
################################################################################
sub new_record
{
    my $this = shift;

    my $list       = {};
    my $avail_tags = Metiisto::Tag->names();
    
    my $out = template 'lists/new_edit', {
        list       => $list,
        avail_tags => $avail_tags,
    };

    return ($out);
}
################################################################################
sub create
{
    my $this = shift;

    my $data = {};
    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^list\.(.*)$/;
        my $attr = $1;
        $data->{$attr} = params->{$p};
    }

    my $list = Metiisto::List->insert($data);
    die "Error creating List" unless $list;

    $list->update_tags(tags => params()->{'list[tags][]'});
    
    my $out = redirect "/lists/".$list->id();

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;

    my $list = Metiisto::List->retrieve($args{id});

    my @items = $list->items();
    my $out = template 'todos/list', {
        list    => $list,
        items   => \@items,
        is_list => 1
    };

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my $list = Metiisto::List->retrieve($args{id});
    my $avail_tags = Metiisto::Tag->names();
    
    my $out = template 'lists/new_edit', {
        list      => $list,
        avail_tags=> $avail_tags,
    };

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;

    my $list = Metiisto::List->retrieve(id => $args{id});
    $list->update_tags(tags => params()->{'list[tags][]'});
    
    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^list\.(.*)$/;
        my $attr = $1;
        $list->$attr(params->{$p});
    }
    my $cnt = $list->update();
    die "Error saving List($args{id})" unless $cnt;

    my $out = redirect "/lists/$args{id}";

    return ($out);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $list = Metiisto::List->retrieve(id => $args{id});
    $list->delete();

    my $url = '/lists';
    $url .= "?filter_text=".params->{filter_text} if params->{filter_text};

    my $out = redirect $url;

    return ($out);
}
################################################################################
1;
