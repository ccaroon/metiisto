package Metiisto::Controller::Entries;
################################################################################
use strict;

use Data::Page;
use Dancer ':syntax';

use constant ENTRIES_PER_PAGE => 25;

use base 'Metiisto::Controller::Base';

use Metiisto::Entry;
################################################################################
sub list
{
    my $this = shift;

    my $conditions = {1=>1};
    if (params->{filter_text})
    {
        # TODO: should be OR'ing subject and desc. but not working
        $conditions = {
            #subject     => { 'regexp', params->{filter_text} },
            description => { 'regexp', params->{filter_text} },
        };
    }
# TODO: make pagination work with filtering
    my $page = Data::Page->new();
    $page->total_entries(Metiisto::Entry->count());
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
            current_page => $page->current_page(),
            first_page => $page->first_page(),
            last_page => $page->last_page(),
            previous_page => $page->previous_page(),
            next_page => $page->next_page(),
        }
    };

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;
    
    my $entry = Metiisto::Entry->retrieve($args{id});
    
    return ("Entry: ".$entry->subject());
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
    
    get '/entries/:id' => sub {
    
        my $c = Metiisto::Controller::Entries->new();
        my $out = $c->show(id => param('id'));
    
        return ($out);
    };
}
################################################################################
1;
