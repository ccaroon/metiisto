package Metiisto::Util::DateTime;
################################################################################
use strict;

use Date::Format;
use Date::Parse;
use Moo;

use constant DAY   => 86_400;

use constant FORMAT_DB_DATE     => '%Y-%m-%d';
use constant FORMAT_DB_DATETIME =>  FORMAT_DB_DATE . ' %H:%M:%S';
use constant FORMAT_TIME        => "%I:%M%p";
use constant DAYS_OF_THE_WEEK   => {
    sunday    => 0,
    monday    => 1,
    tuesday   => 2,
    wednesday => 3,
    thursday  => 4,
    friday    => 5,
    saturday  => 6
};
use constant MONTHS => [
    {name => 'January',   days => 31},
    {name => 'February',  days => 28},
    {name => 'March',     days => 31},
    {name => 'April',     days => 30},
    {name => 'May',       days => 31},
    {name => 'June',      days => 30},
    {name => 'July',      days => 31},
    {name => 'August',    days => 31},
    {name => 'September', days => 30},
    {name => 'October',   days => 31},
    {name => 'November',  days => 30},
    {name => 'December',  days => 31}
];
################################################################################
has epoch => (
    is  => 'rw',
    isa => sub { die "'epoch' must be an integer." unless $_[0] =~ /^\d+$/ },
);
################################################################################
sub parse
{
    my $class    = shift;
    my $date_str = shift;

    my $dt = $class->new();
    if (defined $date_str)
    {
        $dt->epoch(str2time($date_str));
    }

    return($dt);
}
################################################################################
sub sunday
{
    my $class = shift;
    my %args = @_;

    return($class->day_of_the_week(%args, day => 'sunday'));
}
################################################################################
sub monday
{
    my $class = shift;
    my %args = @_;

    return($class->day_of_the_week(%args, day => 'monday'));
}
################################################################################
sub day_of_the_week
{
    my $class = shift;
    my %args = @_;

    my $day_name = lc $args{day};
    my $day_num  = DAYS_OF_THE_WEEK->{$day_name};

    my $for_date = $args{for_date}
        ? Metiisto::Util::DateTime->parse($args{for_date})
        : Metiisto::Util::DateTime->now();
    my $week_day = $for_date->format("%w");
    my $day_epoch = $for_date->epoch() - (DAY * ($week_day-$day_num));

    return (Metiisto::Util::DateTime->new(epoch => $day_epoch));

}
################################################################################
sub add
{
    my $this = shift;
    my %args = @_;

    if ($args{units} =~ /hours?/i) {
        $this->add_days(days => $args{count} / 24);
    }
    elsif ($args{units} =~ /days?/i) {
        $this->add_days(days => $args{count});
    }
    elsif ($args{units} =~ /weeks?/i) {
        $this->add_days(days => $args{count} * 7);
    }
    elsif ($args{units} =~ /months?/i) {
        $this->add_days(days => $args{count} * 30);
    }
    elsif ($args{units} =~ /years?/i) {
        $this->add_days(days => $args{count} * 365);
    }
}
################################################################################
sub add_days
{
    my $this = shift;
    my %args = @_;

    my $current_epoch = $this->epoch();
    $this->epoch($current_epoch + ($args{days} * DAY));

    return($this);
}
################################################################################
sub now
{
    my $class = shift;
    return($class->new(epoch => time()));
}
################################################################################
sub format
{
    my $this   = shift;
    my $format = shift || '%b %d, %Y';

    my $formatted_dt = undef;
    if (defined $this->epoch())
    {
        $formatted_dt = time2str($format,$this->epoch());
    }

    return($formatted_dt);
}
################################################################################
sub format_time
{
    my $this = shift;
    return ($this->format(FORMAT_TIME));
}
################################################################################
sub format_db
{
    my $this = shift;
    my %args = @_;

    return (
        $args{date_only}
            ? $this->format(FORMAT_DB_DATE)
            : $this->format(FORMAT_DB_DATETIME)
    );
}
################################################################################
sub timestr_to_minutes
{
    my $class = shift;
    my %args  = @_;
    
    my ($h, $m, undef) = split /:/, $args{time_str};
    
    my $min = $m + ($h * 60);
    
    return ($min);
}
################################################################################
1;
