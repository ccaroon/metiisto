package Metiisto::Controller::Home;
################################################################################
use strict;

use Date::Format;
use Dancer ':syntax';

use Metiisto::Countdown;
use Metiisto::JiraTicket;
use Metiisto::Note;
use Metiisto::Todo;

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

    # TODO: put some caching around ticket info.
    my $tickets = Metiisto::JiraTicket->search(
        query => "filter=".session->{user}->preferences('jira_filter_id'));
    
    # TODO: put some caching around current_release info
    my $ready_points = 0;
    my $total_points = 0;
    # TODO: don't hardcode current release filter id
    my @release_tickets = Metiisto::JiraTicket->search(
        query => "filter=11224 AND assignee=".session->{user}->preferences('jira_username'));
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

    my $out = template 'home/index', {
        tickets         => $tickets,
        todos           => \@todos,
        entries         => \@entries,
        recent_notes    => \@recent_notes,
        favorite_notes  => \@fav_notes,
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
