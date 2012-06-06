package Metiisto::Controller::Home;
################################################################################
use strict;

use Date::Format;
use Dancer ':syntax';

use Metiisto::Countdown;
use Metiisto::JiraTicket;
use Metiisto::Note;
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
            query => "filter=".session->{user}->preferences('jira_filter_id'));
        Metiisto::Util::Cache->set(key => 'my_tickets', value => $tickets, ttl => 60);
    }

    my $ready_points = 0;
    my $total_points = 0;
    my $release_tickets;
    my $release_data = Metiisto::Util::Cache->get(key => 'release_tickets');
    if ($release_data)
    {
        $ready_points    = $release_data->{ready_points};
        $total_points    = $release_data->{total_points};
        $release_tickets = $release_data->{tickets};
    }
    else
    {
        # TODO: don't hardcode current release filter id
        $release_tickets = Metiisto::JiraTicket->search(
            query => "filter=11224 AND assignee=".session->{user}->preferences('jira_username'));
        foreach my $t (@$release_tickets)
        {
            $total_points += $t->points();
            if ($t->status() =~ /(Ready for release|Closed|Rejected)/)
            {
                $ready_points += $t->points();
            }
        }
        
        Metiisto::Util::Cache->set(
            key   => 'release_tickets',
            value => {
                tickets      => $release_tickets,
                ready_points => $ready_points,
                total_points => $total_points,
            },
            ttl   => 10 * 60,
        );
    }

    my $current_release_name = (scalar @$release_tickets != 0)
        ? $release_tickets->[0]->fix_version()
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

    # Data for Tag Cloud
    my $tag_cloud = Metiisto::Util::Cache->get(key => 'tag_cloud');
    unless ($tag_cloud)
    {
        my @tags = Metiisto::Tag->retrieve_all();
        # Tag Name => Used Count
        my %tag_data = map { $_->name() => scalar($_->objects())->count() } @tags;
        $tag_cloud = \%tag_data;

        Metiisto::Util::Cache->set(
            key   => 'tag_cloud',
            value => $tag_cloud,
            ttl   => 15 * 60,
        );
    }

    my $out = template 'home/index', {
        tickets         => $tickets,
        todos           => \@todos,
        entries         => \@entries,
        recent_notes    => \@recent_notes,
        favorite_notes  => \@fav_notes,
        countdowns      => \@countdowns,
        tag_cloud       => $tag_cloud,
        current_release => {
            name         => $current_release_name,
            ready_points => $ready_points,
            total_points => $total_points,
            tickets      => $release_tickets,
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
