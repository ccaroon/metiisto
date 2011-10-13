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
    my $days = Metiisto::Workday->this_week();

    # Entries
    my $iterator = Metiisto::Entry->this_week();
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
    my $days = Metiisto::Workday->this_week();

    # Entries by Category
    my %entries;
    foreach my $category (@{Metiisto::Entry->CATEGORIES()})
    {
        my @entries = Metiisto::Entry->this_week(where => {
            category => { '=' => $category }
        });
        $entries{$category} = \@entries;
    }
use Data::Dumper;
local $Data::Dumper::Maxdepth=1;
print STDERR Dumper \%entries;
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
