package Metiisto::Controller::Entries;
################################################################################
use strict;

use Dancer ':syntax';

use base 'Metiisto::Controller::Base';

use Metiisto::Entry;
################################################################################
sub list
{
    my $this = shift;

    my @entries = Metiisto::Entry->search_where(
        {1=>1},
        {limit_dialect => 'LimitOffset',
         limit => 20,
         offset => 0,
         order_by => 'task_date desc'}
    );

    my $out = template 'entries/list', {
        entries => \@entries,
        count => Metiisto::Entry->count()
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
