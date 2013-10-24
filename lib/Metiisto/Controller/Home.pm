package Metiisto::Controller::Home;
################################################################################
use strict;

use Date::Format;
use Dancer ':syntax';

use Metiisto::Countdown;
use Metiisto::JiraTicket;
use Metiisto::Note;
#use Metiisto::Tag;
use Metiisto::Todo;
use Metiisto::Util::Cache;

use base 'Metiisto::Controller::Base';
################################################################################
sub home
{
    my $this = shift;

    my @todos;
    # With Due date, orderd by due_date, priority
    push @todos, Metiisto::Todo->search_where(
        {
            completed => 0,
            list_id   => undef,
            due_date  => {'is not', undef},
        },
        { order_by => 'due_date, priority' }
    );
    # No Due date, ordered by priority
    push @todos, Metiisto::Todo->search(
        completed => 0,
        list_id   => undef,
        due_date  => undef,
        { order_by => 'priority' }
    );

    my $tickets = Metiisto::Util::Cache->get(key => 'my_tickets');
    unless ($tickets)
    {
        $tickets = Metiisto::JiraTicket->search(
            query => "filter=".session->{user}->preferences('jira_tickets_filter_id'));
        Metiisto::Util::Cache->set(key => 'my_tickets', value => $tickets, ttl => 60);
    }

    my $release_data = Metiisto::Util::Cache->get(key => 'release_data');
    unless ($release_data)
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

        $release_data = {
            name         => $release_name,
            tickets      => $release_tickets,
            ready_points => $ready_points,
            total_points => $total_points,
        };

        Metiisto::Util::Cache->set(
            key   => 'release_data',
            value => $release_data,
            ttl   => 10 * 60,
        );
    }

    my @recent_notes = Metiisto::Note->search_where(
        {
            is_favorite => {'=', 0},
            deleted_date  => {'is', undef},
        },
        {
            order_by => 'created_date desc',
            limit_dialect => 'LimitOffset',
            limit => 5,
        }
    );
    
    my @fav_notes = Metiisto::Note->search_where(
        {
            is_favorite => {'=', 1},
            deleted_date  => {'is', undef},
        },
        { order_by => 'created_date asc' }
    );

    my @countdowns = Metiisto::Countdown->search_where(
        { on_homepage => {'=', 1},  },
        { order_by => 'target_date' }
    );

    # Figure out date of Monday
    # TODO: replace with call to DateTime->monday()?
    my $wday = time2str("%w", time());
    my $monday = time() - ($wday * 86400);
    my @entries = Metiisto::Entry->search_where(
        {
            task_date => {'>=', time2str("%Y-%m-%d", $monday)}
        },
        { order_by => 'task_date,entry_date' }
    );

    ## Data for Tag Cloud
    #my $cloud_data = Metiisto::Util::Cache->get(key => 'tag_cloud_data');
    #unless ($cloud_data)
    #{
    #    $cloud_data = Metiisto::Tag->cloud_data();
    #
    #    Metiisto::Util::Cache->set(
    #        key   => 'tag_cloud_data',
    #        value => $cloud_data,
    #        ttl   => 15 * 60,
    #    );
    #}

    my $out = template 'home/index', {
        tickets         => $tickets,
        todos           => \@todos,
        entries         => \@entries,
        recent_notes    => \@recent_notes,
        favorite_notes  => \@fav_notes,
        countdowns      => \@countdowns,
        #cloud_data      => $cloud_data,
        current_release => $release_data,
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
