package Metiisto::Controller::Workdays;
################################################################################
use strict;

use Dancer ':syntax';

use base 'Metiisto::Controller::Base';

use Metiisto::Workday;
################################################################################
sub list
{
    my $this = shift;

    my @days = Metiisto::Workday->search_where(
        {
            work_date => {'>=','2011-10-03'}
        },
        {
            order_by => 'work_date, time_in',
        }
    );

    my $out = template 'workdays/list', {
        days => \@days,
    };

    return ($out);
}
################################################################################
sub new_record
{
    my $this = shift;

    my $entry = {
        ticket_num => params->{ticket_num},
        subject    => params->{subject},
        category   => params->{category},
        task_date  => Metiisto::Util::DateTime->new(epoch => time)
    };
    my $subjects = Metiisto::Workday->recent_subjects();

    my $out = template 'workdays/new_edit', {
        entry => $entry,
        recent_subjects => $subjects,
        categories => Metiisto::Workday->CATEGORIES,
    };

    return ($out);
}
################################################################################
sub create
{
    my $this = shift;

    my $data = {};
    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^entry\.(.*)$/;
        my $attr = $1;
        $data->{$attr} = params->{$p};
    }
    $data->{entry_date} = Metiisto::Util::DateTime->now()->format_db();

    my $entry = Metiisto::Workday->insert($data);
    die "Error creating Entry" unless $entry;

    my $out = redirect "/work_days/".$entry->id();

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;

    my $entry = Metiisto::Workday->retrieve($args{id});
    my $out = template 'workdays/show', { entry => $entry };

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my $entry = Metiisto::Workday->retrieve($args{id});
    my $subjects = Metiisto::Workday->recent_subjects();

    my $out = template 'workdays/new_edit', {
        entry => $entry,
        recent_subjects => $subjects,
        categories => Metiisto::Workday->CATEGORIES,
    };

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;
    
    my $entry = Metiisto::Workday->retrieve(id => $args{id});

    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^entry\.(.*)$/;
        my $attr = $1;
        $entry->$attr(params->{$p});
    }
    my $cnt = $entry->update();
    die "Error saving Entry($args{id})" unless $cnt;

    my $out = redirect "/work_days/$args{id}";

    return ($out);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $entry = Metiisto::Workday->retrieve(id => $args{id});
    $entry->delete();
    
    my $url = '/work_days';
    $url .= "?filter_text=".params->{filter_text} if params->{filter_text};

    my $out = redirect $url;

    return ($out);
}
################################################################################
sub set_day_type
{
    my $this = shift;
    my %args = @_;

    my $day = Metiisto::Workday->retrieve(id => $args{id});
    my $type = 'DAY_TYPE_'.uc params->{type};
    $day->set_day_type(Metiisto::Workday->$type);
    $day->update();

    return (redirect '/workdays');
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
    $class->SUPER::declare_routes();
    
    
}
################################################################################
1;
