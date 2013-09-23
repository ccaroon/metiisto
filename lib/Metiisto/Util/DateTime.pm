package Metiisto::Util::DateTime;
################################################################################
use strict;

use feature 'switch';

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

    given ($args{units})
    {
        when (/days?/i) {
            $this->add_days(days => $args{count});
        }
        when (/weeks?/i) {
            $this->add_days(days => $args{count} * 7);
        }
        when (/months?/i) {
            $this->add_days(days => $args{count} * 30);
        }
        when (/years?/i) {
            $this->add_days(days => $args{count} * 365);
        }
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
    my $this = shift;
    my %args = @_;
    
    my ($h, $m, undef) = split /:/, $args{time_str};
    
    my $min = $m + ($h * 60);
    
    return ($min);
}
################################################################################
sub minutes_to_timestr
{
    my $this = shift;
    my %args = @_;
    
    my $total_min = $args{min};
    
    my $hours = int ($total_min / 60);
    my $min   = $total_min % 60;
    
    return ("${hours}h ${min}m");
}
################################################################################
1;
