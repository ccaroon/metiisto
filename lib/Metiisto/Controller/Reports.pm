package Metiisto::Controller::Reports;
################################################################################
use strict;

use Dancer ':syntax';
use Net::SMTP::SSL;
use Text::Markdown 'markdown';

use Metiisto::Entry;
use Metiisto::Workday;
use Metiisto::Util::DateTime;

use base 'Metiisto::Controller::Base';
################################################################################
sub daily
{
    my $this = shift;
    my %args = @_;

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
        my $entry = $entries[$index];

        unless ($entry)
        {
            $entry = {time_spent => 0, day_list => []};
            $entries[$index] = $entry;
        }

        my $day_list = $entry->{day_list};
        $entry->{time_spent}
            += Metiisto::Util::DateTime->timestr_to_minutes(time_str => $e->time_spent());

        push @$day_list, $e;
    }
    # FIXME: An 'undef' is getting into @entries somehow
    shift @entries unless defined $entries[0];

    map {$_->{time_spent} = Metiisto::Util::DateTime->minutes_to_timestr(min => $_->{time_spent})}
        @entries;

    my $out = template "/reports/daily",
    {
        title       => 'Daily Report',
        name        => 'daily',
        no_controls => $args{no_controls},
        work_days   => $days,
        entries     => \@entries,
    },
    {layout => undef};

    return (markdown($out));
}
################################################################################
sub weekly
{
    my $this = shift;
    my %args = @_;

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
        
        @entries = $this->_consolidate_entries(entries => \@entries);
        $entries{$category} = \@entries;
    }

    my $out = template "/reports/weekly",
    {
        title       => 'Weekly Report',
        name        => 'weekly',
        no_controls => $args{no_controls},
        work_days   => $days,
        entries     => \%entries,
    },
    {layout => undef};

    return (markdown($out));
}
################################################################################
sub summary
{
    my $this = shift;
    my %args = @_;
    
    my $from_date = defined params->{from}
        ? Metiisto::Util::DateTime->parse(params->{from})
        : Metiisto::Util::DateTime->now()->add_days(days => -7);

    my $to_date = defined params->{to}
        ? Metiisto::Util::DateTime->parse(params->{to})
        : Metiisto::Util::DateTime->now();

    my @search_opts = (
        {
            task_date => { 'between' => [
                                            $from_date->format_db(date_only => 1),
                                            $to_date->format_db(date_only => 1)
                                        ]
                         },
            category => { 'in' => ['Ticket','Operational','Other'] }
        },
        {
            order_by => 'task_date, entry_date',
        }
    );

    my @entries = Metiisto::Entry->search_where(@search_opts);
    @entries = $this->_consolidate_entries(entries => \@entries);

    my $out = template "/reports/summary",
    {
        title   => 'Summary Report',
        name    => 'summary',
        no_controls => 0,
        entries => \@entries,
    },
    {layout => undef};

    return (markdown($out));
}
################################################################################
sub email
{
    my $this = shift;
    my %args = @_;

    my $out;

    my $report_name = $args{name};
    my $report_body = $this->$report_name(no_controls => 1);
    my $report_date = Metiisto::Util::DateTime->monday(for_date => params->{date});
    $report_date->add_days(days => 4);

    eval
    {
        my $smtp_user = session->{user}->preferences('smtp_user');
        my $from      = session->{user}->email();
        my $user_name = session->{user}->name();
        my $to        = session->{user}->preferences('report_recipients');

        my $smtp = Net::SMTP::SSL->new(
            session->{user}->preferences('smtp_host'),
            Port  => session->{user}->preferences('smtp_port'),
            Debug => 0
        );
        die "Unable to connect to SMTP server" unless $smtp;

        $smtp->auth($smtp_user, session->{user}->preferences('smtp_pass'))
            or die "Authentication failed!";

        $smtp->mail("$smtp_user\n");
        my @recepients = split /,/, $to;
        foreach my $recp (@recepients)
        {
            $smtp->to("$recp\n");
        }
        $smtp->data();
        $smtp->datasend("From: $user_name <$from>\n");
        $smtp->datasend("To: $to\n");
        $smtp->datasend("Subject: [WR] " . $report_date->format("%Y.%m.%d") . "\n");
        $smtp->datasend("Content-type: text/html\n");
        $smtp->datasend("\n");
        $smtp->datasend($report_body. "\n");
        $smtp->dataend();
        $smtp->quit();
    };
    if ($@)
    {
        $out = template 'error', {
            message => "Error emailing '$report_name' report: $@"
        };
    }
    else
    {
        $out = redirect '/home';
    }

    return($out);
}
################################################################################
# Flattens multiple entries with the same subject into a single entry
################################################################################
sub _consolidate_entries
{
    my $this = shift;
    my %args = @_;

    my $entries = $args{entries};
        
    my %entry_filter;
    foreach my $e (@$entries)
    {
        my $entry_list = $entry_filter{$e->subject()};
        if ($entry_list)
        {
            push @{$entry_list}, $e;
        }
        else
        {
            $entry_filter{$e->subject()} = [$e];
        }
    }
    
    my @consolidated_entries
        = sort {$a->[0]->entry_date()->epoch() <=> $b->[0]->entry_date->epoch() }
            values %entry_filter;

    return (wantarray ? @consolidated_entries : \@consolidated_entries);
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
    get "/reports/:name/:action" => sub {
        my $c = $class->new();
        
        my $out;
        my $method = params->{action};
        if ($c->can($method))
        {
            $out = $c->$method(name => params->{name});
        }
        else
        {
            $out = template 'error', {
                message => "Unknown report action: '$method'.",
            };
        }

        return ($out);
    };
    
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
