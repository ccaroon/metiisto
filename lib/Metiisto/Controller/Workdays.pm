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

    my $days = Metiisto::Workday->find_week(date => params->{date});

    my $out = template 'workdays/list', {
        today => Metiisto::Util::DateTime->now(),
        days => $days,
    };

    return ($out);
}
################################################################################
sub new_record
{
    my $this = shift;
    my %args = @_;

    my $day = {
        work_date => Metiisto::Util::DateTime->now(),
        time_in   => Metiisto::Util::DateTime->parse(
            Metiisto::Workday->DEFAULT_TIME_IN),
        time_out  => Metiisto::Util::DateTime->parse(
            Metiisto::Workday->DEFAULT_TIME_OUT),
    };

    my $out = $this->SUPER::new_record(
        item => $day,
    );

    return ($out);
}
################################################################################
sub create
{
    my $this = shift;

    my $data = {};
    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^workday\.(.*)$/;
        my $attr = $1;
        $data->{$attr} = params->{$p};
    }

    $data->{time_in}
        = Metiisto::Util::DateTime->parse($data->{'time_in'})->format('%R');
    $data->{time_out}
        = Metiisto::Util::DateTime->parse($data->{'time_out'})->format('%R');
    $data->{time_lunch} = '00:00';

    my $day = Metiisto::Workday->insert($data);
    die "Error creating Workday" unless $day;

    my $out = redirect "/workdays";

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;

    my $day = Metiisto::Workday->retrieve($args{id});
    my $out = template 'workdays/show', { day => $day };

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my $day = Metiisto::Workday->retrieve($args{id});

    my $out = template 'workdays/new_edit', {
        item => $day,
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
        next unless $p =~ /^workday\.(.*)$/;
        my $attr = $1;
        $day->$attr(params->{$p});
    }
    my $cnt = $day->update();
    die "Error saving Workday($args{id})" unless $cnt;

    my $url = '/workdays';
    $url .= "?date=".params->{date} if params->{date};

    return (redirect $url);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $day = Metiisto::Workday->retrieve(id => $args{id});
    $day->delete();

    my $url = '/workdays';
    $url .= "?date=".params->{date} if params->{date};

    return (redirect $url);
}
################################################################################
sub set_day_type
{
    my $this = shift;
    my %args = @_;

    my $day = Metiisto::Workday->retrieve(id => $args{id});
    my $type = 'DAY_TYPE_'.uc params->{type};
    $day->day_type(Metiisto::Workday->$type);

    if (Metiisto::Workday->$type == Metiisto::Workday->DAY_TYPE_REGULAR)
    {
        $day->note(undef);
        $day->time_in(Metiisto::Workday->DEFAULT_TIME_IN);
        $day->time_out(Metiisto::Workday->DEFAULT_TIME_OUT);
    }
    else
    {
        $day->note(ucfirst params->{type});
        $day->time_in('00:00:00');
        $day->time_out('00:00:00');
        $day->time_lunch('00:00:00');
    }
    $day->update();

    my $url = '/workdays';
    $url .= "?date=".params->{date} if params->{date};

    return (redirect $url);
}
################################################################################
sub generate_week
{
    my $this = shift;

    my $monday = Metiisto::Util::DateTime->monday(for_date => params->{date});
    for(my $i = 0; $i < 5; $i++)
    {
        my $date = Metiisto::Util::DateTime->new(
            epoch => $monday->epoch() + (86_400 * $i));

        Metiisto::Workday->find_or_create({
            work_date  => $date->format_db(date_only => 1),
            time_in    => Metiisto::Workday->DEFAULT_TIME_IN,
            time_out   => Metiisto::Workday->DEFAULT_TIME_OUT,
            time_lunch => '00:00',
        });
    }

    my $url = '/workdays';
    $url .= "?date=".params->{date} if params->{date};

    return (redirect $url);
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
