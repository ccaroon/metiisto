package Metiisto::Controller::Home;
################################################################################
use strict;

use Date::Format;
use Dancer ':syntax';

use Metiisto::Countdown;
use Metiisto::Note;
use Metiisto::Tag;
use Metiisto::Todo;
use Metiisto::Util::DateTime;

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
        { order_by => 'start_date' }
    );

    my $date = Metiisto::Util::DateTime->sunday();
    my @entries = Metiisto::Entry->search_where(
        {
            task_date => {'>=', $date->format_db(date_only => 1)}
        },
        { order_by => 'task_date,entry_date' }
    );

    my $cloud_data = Metiisto::Tag->cloud_data(limit => 25);

    my $out = template 'home/index', {
        todos           => \@todos,
        entries         => \@entries,
        recent_notes    => \@recent_notes,
        favorite_notes  => \@fav_notes,
        countdowns      => \@countdowns,
        cloud_data      => $cloud_data
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
