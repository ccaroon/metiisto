package Metiisto::Controller::API;
################################################################################
use strict;

use Dancer ':syntax';

use Metiisto::JiraTicket;
use Metiisto::Util::Cache;

use base 'Metiisto::Controller::Base';
################################################################################
sub my_tickets 
{
    my $this = shift;

    my $tickets = Metiisto::Util::Cache->get(key => 'my_tickets');
    unless ($tickets)
    {
        $tickets = Metiisto::JiraTicket->search(
            query => "filter=".session->{user}->preferences('jira_tickets_filter_id'));
        Metiisto::Util::Cache->set(key => 'my_tickets', value => $tickets, ttl => 60);
    }

    return ($tickets);
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
    get '/api/my_tickets' => sub {
        my $c = Metiisto::Controller::API->new();
        my $out = $c->my_tickets();

        return ($out);
    };

}
################################################################################
1;
