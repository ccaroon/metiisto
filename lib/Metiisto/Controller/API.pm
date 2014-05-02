package Metiisto::Controller::API;
################################################################################
use strict;

use Dancer ':syntax';

use Metiisto::JiraTicket;
use Metiisto::Util::Cache;

# TTLs in seconds
use constant DEFAULT_TTL_MY_TICKETS      => 5 * 60;      # 5 minutes
use constant DEFAULT_TTL_CURRENT_RELEASE => 1 * (60*60); # 1 hour

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

        my $ttl = session->{user}->preferences('jira_my_tickets_cache_ttl') || DEFAULT_TTL_MY_TICKETS;
        Metiisto::Util::Cache->set(key => 'my_tickets', 
            value => $tickets, ttl => $ttl);
    }

    return ($tickets);
}
################################################################################
sub current_release_data
{
    my $this = shift;

    my $data = Metiisto::Util::Cache->get(key => 'current_release_data');
    unless ($data)
    {
        my $release_tickets = Metiisto::JiraTicket->search(
            query => "filter=".session->{user}->preferences('jira_current_release_filter_id'));

        my $total_points = 0;
        my $ready_points = 0;
        foreach my $t (@$release_tickets)
        {
            $total_points += $t->points();
            if ($t->status() =~ /(Ready for Release|Closed|Rejected)/)
            {
                $ready_points += $t->points();
            }
        }

        my $release_name = '?????';
        foreach my $ticket (@$release_tickets)
        {
            if ($ticket->fix_version()) {
                $release_name = $ticket->fix_version();
                last;
            }
        }

        $data = {
            name         => $release_name,
            tickets      => $release_tickets,
            ready_points => $ready_points,
            total_points => $total_points,
        };

        my $ttl = session->{user}->preferences('jira_current_release_cache_ttl') || DEFAULT_TTL_CURRENT_RELEASE;
        Metiisto::Util::Cache->set(
            key   => 'current_release_data',
            value => $data,
            ttl   => $ttl
        );
    }

    return ($data);
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

    get '/api/current_release_data' => sub {
        my $c = Metiisto::Controller::API->new();
        my $out = $c->current_release_data();

        return ($out);
    };

}
################################################################################
1;
