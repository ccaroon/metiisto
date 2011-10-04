package Metiisto::Controller::Workdays;
################################################################################
use strict;

use Dancer ':syntax';

use base 'Metiisto::Controller::Base';

use Metiisto::Util::DateTime;
use Metiisto::Workday;
################################################################################
sub list
{
    my $this = shift;

    my $monday = Metiisto::Util::DateTime->monday();
    my @days = Metiisto::Workday->search_where(
        {
            work_date => {'>=', $monday->format_db(date_only => 1)}
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

    my $day = {
        ticket_num => params->{ticket_num},
        subject    => params->{subject},
        category   => params->{category},
        task_date  => Metiisto::Util::DateTime->new(epoch => time)
    };

    my $out = template 'workdays/new_edit', {
        entry => $day,
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

    my $day = Metiisto::Workday->insert($data);
    die "Error creating Entry" unless $day;

    my $out = redirect "/work_days/".$day->id();

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;

    my $day = Metiisto::Workday->retrieve($args{id});
    my $out = template 'workdays/show', { entry => $day };

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my $day = Metiisto::Workday->retrieve($args{id});
    my $subjects = Metiisto::Workday->recent_subjects();

    my $out = template 'workdays/new_edit', {
        entry => $day,
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
    
    my $day = Metiisto::Workday->retrieve(id => $args{id});

    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^entry\.(.*)$/;
        my $attr = $1;
        $day->$attr(params->{$p});
    }
    my $cnt = $day->update();
    die "Error saving Entry($args{id})" unless $cnt;

    my $out = redirect "/work_days/$args{id}";

    return ($out);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $day = Metiisto::Workday->retrieve(id => $args{id});
    $day->delete();
    
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
    my $note = (Metiisto::Workday->$type == Metiisto::Workday->DAY_TYPE_REGULAR)
        ? ''
        : ucfirst params->{type};
    $day->note($note);
    $day->update();

    return (redirect '/workdays');
}
################################################################################
sub generate_week
{
    my $this = shift;

    my $monday = Metiisto::Util::DateTime->monday();
    for(my $i = 0; $i < 5; $i++)
    {
        my $date = Metiisto::Util::DateTime->new(
            epoch => $monday->epoch() + (86_400 * $i));
# TODO: use find_or_create instead of insert()
        Metiisto::Workday->insert({
            work_date  => $date->format_db(),
            time_in    => Metiisto::Workday->DEFAULT_IN_TIME,
            time_out   => Metiisto::Workday->DEFAULT_OUT_TIME,
            time_lunch => '00:00',
        });
    }

    return (redirect '/workdays');
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
    # Generate Week
    get "/workdays/generate_week" => sub {
        my $c = $class->new();
        my $out = $c->generate_week();
        return ($out);
    };

    $class->SUPER::declare_routes();
}
################################################################################
1;
