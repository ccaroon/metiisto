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

    my @todos = Metiisto::Todo->search(completed => 0, list_id => undef);
    
    my $tickets = Metiisto::JiraTicket->search(
        query => "filter=".session->{user}->jira_filter_id());
    
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
        tickets        => $tickets,
        todos          => \@todos,
        entries        => \@entries,
        recent_notes   => \@recent_notes,
        favorite_notes => \@fav_notes,
        goals          => \@goals,
        countdowns     => \@countdowns,
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
