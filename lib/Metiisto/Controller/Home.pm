package Metiisto::Controller::Home;
################################################################################
use strict;

use Date::Format;
use Dancer ':syntax';

use Metiisto::JiraTicket;
use Metiisto::Todo;

use base 'Metiisto::Controller::Base';
################################################################################
sub home
{
    my $this = shift;

    my @todos = Metiisto::Todo->search(completed => 0, list_id => undef);
    
    my $tickets = Metiisto::JiraTicket->search(
        query => "filter=".session->{user}->jira_filter_id());

    # Figure out date of Monday
    my $wday = time2str("%w", time());
    my $monday = time() - ($wday * 86400);
    my @entries = Metiisto::Entry->search_where(
        {
            task_date => {'>=', time2str("%Y-%m-%d", $monday)}
        },
        { order_by => 'task_date,entry_date' }
    );

    my $out = template 'home/index', {
        tickets => $tickets,
        todos   => \@todos,
        entries => \@entries,
    };

    return ($out);
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
    get '/home' => sub {

        my $c = Metiisto::Controller::Home->new();
        my $out = $c->home();

        return ($out);
    };

}
################################################################################
1;
