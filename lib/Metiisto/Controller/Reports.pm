package Metiisto::Controller::Reports;
################################################################################
use strict;

use Dancer ':syntax';
use Text::Markdown 'markdown';

use Metiisto::Entry;
use Metiisto::Workday;
use Metiisto::Util::DateTime;

use base 'Metiisto::Controller::Base';
################################################################################
sub daily
{
    my $this = shift;

    # Workdays
    my $days = Metiisto::Workday->find_week(date => params->{date});

    # Entries
    my $iterator = Metiisto::Entry->find_week(date => params->{date});
    # Fetch and organize into a ARRAY of ARRAYs ordered by week day number
    # Sunday == 0, Monday == 1, etc..
    my @entries;
    while (my $e = $iterator->next())
    {
        my $index = $e->task_date()->format("%w");
        my $day_list = $entries[$index];
        unless ($day_list)
        {
            $day_list = [];
            $entries[$index] = $day_list;
        }
        
        push @$day_list, $e;
    }

    my $out = template "/reports/daily",
    {
        name  => 'Daily Report',
        work_days => $days,
        entries => \@entries,
    },
    {layout => undef};

    return (markdown($out));
}
################################################################################
sub weekly
{
    my $this = shift;

    # Workdays
    my $days = Metiisto::Workday->find_week(date => params->{date});

    # Entries by Category
    my %entries;
    foreach my $category (@{Metiisto::Entry->CATEGORIES()})
    {
        my @entries = Metiisto::Entry->find_week(
            date  => params->{date},
            where => {
                category => { '=' => $category }
            }
        );
        
        # Flatten multiple entries with the same subject into a single entry
        my %entry_filter;
        foreach my $e (@entries)
        {
            my $main_entry = $entry_filter{$e->subject()};
            if ($main_entry)
            {
                my $new_desc = $main_entry->description();
                $new_desc .= "\n\n----------\n\n" . $e->description();
                $main_entry->description($new_desc);
            }
            else
            {
                $entry_filter{$e->subject()} = $e;
            }
        }
        
        @entries = sort {$a->entry_date()->epoch() <=> $b->entry_date->epoch() }
            values %entry_filter;
        $entries{$category} = \@entries;;
    }

    my $out = template "/reports/weekly",
    {
        name  => 'Weekly Report',
        work_days => $days,
        entries => \%entries,
    },
    {layout => undef};

    return (markdown($out));
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
     get "/reports/:name" => sub {
        my $c = $class->new();
        
        my $out;
        my $method = params->{name};
        if ($c->can($method))
        {
            $out = $c->$method();
        }
        else
        {
            $out = template 'error', {
                message => "Unknown report name: '$method'.",
            };
        }

        return ($out);
    };

    $class->SUPER::declare_routes();
}
################################################################################
1;
