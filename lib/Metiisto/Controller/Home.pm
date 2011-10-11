package Metiisto::Controller::Home;
################################################################################
use strict;

use Date::Format;
use Dancer ':syntax';

use Metiisto::Countdown;
use Metiisto::Goal;
use Metiisto::JiraTicket;
use Metiisto::Note;
use Metiisto::Todo;

use base 'Metiisto::Controller::Base';
################################################################################
sub home
{
    my $this = shift;

    my @todos = Metiisto::Todo->search(completed => 0,
        list_id => undef,
        { order_by => 'due_on, priority, created_on' }
    );
    
    # TODO: put some caching around ticket info.
    my $tickets = Metiisto::JiraTicket->search(
        query => "filter=".session->{user}->jira_filter_id());
    
    # TODO: put some caching around current_release info
    my $ready_points = 0;
    my $total_points = 0;
    # TODO: don't hardcode current release filter id
    my @release_tickets = Metiisto::JiraTicket->search(
        query => "filter=11224 AND assignee=".session->{user}->jira_username());
    foreach my $t (@release_tickets)
    {
        $total_points += $t->points();
        if ($t->status() =~ /(Ready for release|Closed|Rejected)/)
        {
            $ready_points += $t->points();
        }
    }

    my $current_release_name = (scalar @release_tickets != 0)
        ? $release_tickets[0]->fix_version()
        : '?????';

    my @recent_notes = Metiisto::Note->search_where(
        {
            is_favorite => {'=', 0},
            deleted_on  => {'is', undef},
        },
        {
            order_by => 'created_on desc',
            limit_dialect => 'LimitOffset',
            limit => 5,
        }
    );
    
    my @fav_notes = Metiisto::Note->search_where(
        {
            is_favorite => {'=', 1},
            deleted_on  => {'is', undef},
        },
        { order_by => 'created_on asc' }
    );

    my @goals = Metiisto::Goal->search_where(
        { completed => {'!=', 1}, },
        { order_by => 'priority' }
    );
    
    my @countdowns = Metiisto::Countdown->search_where(
        { on_homepage => {'=', 1},  },
        { order_by => 'target_date' }
    );

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
        tickets         => $tickets,
        todos           => \@todos,
        entries         => \@entries,
        recent_notes    => \@recent_notes,
        favorite_notes  => \@fav_notes,
        goals           => \@goals,
        countdowns      => \@countdowns,
        current_release => {
            name         => $current_release_name,
            ready_points => $ready_points,
            total_points => $total_points,
            tickets      => \@release_tickets,
        }
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
