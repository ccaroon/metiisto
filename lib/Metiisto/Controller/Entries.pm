package Metiisto::Controller::Entries;
################################################################################
use strict;

use Data::Page;
use Dancer ':syntax';

use constant ENTRIES_PER_PAGE => 21;

use base 'Metiisto::Controller::Base';

use Metiisto::Entry;
################################################################################
sub list
{
    my $this = shift;

    my $total_entries = 0;
    my $conditions    = {1=>1};
    if (params->{filter_text})
    {
        # TODO: should be OR'ing subject and desc. but not working
        $conditions = {
            #subject     => { 'regexp', params->{filter_text} },
            description => { 'regexp', params->{filter_text} },
        };
        $total_entries
            = Metiisto::Entry->count_where("description regexp '".params->{filter_text}."'");
    }
    else
    {
        $total_entries = Metiisto::Entry->count();
    }

    my $page = Data::Page->new();
    $page->total_entries($total_entries);
    $page->entries_per_page(ENTRIES_PER_PAGE);
    $page->current_page(params->{page} || 1);

    my @entries = Metiisto::Entry->search_where(
        $conditions,
        {
            limit_dialect => 'LimitOffset',
            limit    => ENTRIES_PER_PAGE,
            offset  => $page->first(),
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
sub new_entry
{
    my $this = shift;

    my $entry = {
        task_date => Metiisto::Util::DateTime->new(epoch => time)
    };
    my $subjects = Metiisto::Entry->recent_subjects();

    my $out = template 'entries/new_edit', {
        entry => $entry,
        recent_subjects => $subjects,
        categories => Metiisto::Entry->CATEGORIES,
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
    $data->{entry_date} = Metiisto::Util::DateTime->now()->format_db();
    my $entry = Metiisto::Entry->insert($data);
    die "Error creating Entry" unless $entry;

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

    my $entry = Metiisto::Entry->retrieve($args{id});
    my $subjects = Metiisto::Entry->recent_subjects();

    my $out = template 'entries/new_edit', {
        entry => $entry,
        recent_subjects => $subjects,
        categories => Metiisto::Entry->CATEGORIES,
    };

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;
    
    my $entry = Metiisto::Entry->retrieve(id => $args{id});

    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^entry\.(.*)$/;
        my $attr = $1;
        $entry->$attr(params->{$p});
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
}
################################################################################
sub declare_routes
{
    my $class = shift;

    get '/entries' => sub {
    
        my $c = Metiisto::Controller::Entries->new();
        my $out = $c->list();
    
        return ($out);
    };
    
    post '/entries' => sub {
    
        my $c = Metiisto::Controller::Entries->new();
        my $out = $c->create();
    
        return ($out);
    };

    get '/entries/:id/:action' => sub {
    
        my $c = Metiisto::Controller::Entries->new();
        my $action = params->{action};
        my $out = $c->$action(id => params->{id});

        return ($out);
    };

    get '/entries/new' => sub {
        my $c = Metiisto::Controller::Entries->new();
        my $out = $c->new_entry();
    
        return ($out);
    };

    get '/entries/:id' => sub {
    
        my $c = Metiisto::Controller::Entries->new();
        my $out = $c->show(id => params->{id});

        return ($out);
    };
    
    post '/entries/:id' => sub {
    
        my $c = Metiisto::Controller::Entries->new();
        my $out = $c->update(id => params->{id});
    
        return ($out);
    };

}
################################################################################
1;
