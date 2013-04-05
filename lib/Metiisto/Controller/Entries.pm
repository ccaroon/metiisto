package Metiisto::Controller::Entries;
################################################################################
use strict;

use Data::Page;
use Dancer ':syntax';
use SQL::Abstract;

use constant ENTRIES_PER_PAGE => 20;

use base 'Metiisto::Controller::Base';

use Metiisto::Entry;
################################################################################
sub list
{
    my $this = shift;

    my $total_entries = 0;
    my $conditions;
    if (params->{filter_text})
    {
        $conditions = [
            { subject => { 'regexp', params->{filter_text} } },
            # OR
            { description => { 'regexp', params->{filter_text} } },
        ];
    }
    else
    {
        $conditions    = {1=>1};
    }

    my $sql_abs = SQL::Abstract->new();
    my ($where, @binds) = $sql_abs->where($conditions);
    $total_entries = Metiisto::Entry->count_where($where, \@binds);

    my $page = Data::Page->new();
    $page->total_entries($total_entries);
    $page->entries_per_page(ENTRIES_PER_PAGE);
    $page->current_page(params->{page} || 1);

    my @entries = Metiisto::Entry->search_where(
        $conditions,
        {
            limit_dialect => 'LimitOffset',
            limit    => ENTRIES_PER_PAGE,
            offset  => $page->first() ? $page->first() - 1 : 0,
            order_by => 'task_date desc, entry_date desc',
        }
    );

    my $out = template 'entries/list', {
        entries => \@entries,
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

    my $entry = {
        ticket_num => params->{ticket_num},
        subject    => params->{subject},
        category   => (params->{category} || Metiisto::Entry->CATEGORY_MEETING),
        task_date  => Metiisto::Util::DateTime->new(epoch => time),
        time_spent => '0:0'
    };
    my $subjects = Metiisto::Entry->recent_subjects();
    my $avail_tags = Metiisto::Tag->names();
    
    my $out = template 'entries/new_edit', {
        entry           => $entry,
        recent_subjects => $subjects,
        categories      => Metiisto::Entry->CATEGORIES,
        avail_tags      => $avail_tags,
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
        next unless $p =~ /^entry\.(.*)$/;
        my $attr = $1;
        $data->{$attr} = params->{$p};
    }
    $data->{time_spent} = delete($data->{'time_spent.hours'})
        . ':' . delete($data->{'time_spent.minutes'});
    $data->{entry_date} = Metiisto::Util::DateTime->now()->format_db();

    my $entry = Metiisto::Entry->insert($data);
    die "Error creating Entry" unless $entry;

    $entry->update_tags(tags => params()->{'entry[tags][]'});

    my $out = redirect "/entries/".$entry->id();

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;

    my $entry = Metiisto::Entry->retrieve($args{id});
    
    my $out = template 'entries/show', { entry => $entry };

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my $entry      = Metiisto::Entry->retrieve($args{id});
    my $subjects   = Metiisto::Entry->recent_subjects();
    my $avail_tags = Metiisto::Tag->names();
    
    my $out = template 'entries/new_edit', {
        entry           => $entry,
        recent_subjects => $subjects,
        categories      => Metiisto::Entry->CATEGORIES,
        avail_tags      => $avail_tags,
    };

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;
    
    my $entry = Metiisto::Entry->retrieve(id => $args{id});
    $entry->update_tags(tags => params()->{'entry[tags][]'});

    my $params = params();
    my $time_spent = (delete $params->{'entry.time_spent.hours'})
        . ':' . (delete$params->{'entry.time_spent.minutes'});
    $entry->time_spent($time_spent);

    foreach my $p (keys %{$params})
    {
        next unless $p =~ /^entry\.(.*)$/;
        my $attr = $1;
        $entry->$attr($params->{$p});
    }

    my $cnt = $entry->update();
    die "Error saving Entry($args{id})" unless $cnt;

    my $out = redirect "/entries/$args{id}";

    return ($out);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $entry = Metiisto::Entry->retrieve(id => $args{id});
    $entry->delete();

    my $url = '/entries';
    $url .= "?filter_text=".params->{filter_text} if params->{filter_text};

    my $out = redirect $url;

    return ($out);
}
################################################################################
1;
