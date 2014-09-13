package Metiisto::Workday;
################################################################################
use strict;

use base 'Metiisto::Base';

use Metiisto::Util::DateTime;

use constant DEFAULT_TIME_IN  =>'09:00';
use constant DEFAULT_TIME_OUT =>'17:00';

use constant DAY_TYPE_REGULAR  => 0;
use constant DAY_TYPE_HOLIDAY  => 1;
use constant DAY_TYPE_VACATION => 2;
use constant DAY_TYPE_SICK     => 3;
################################################################################
__PACKAGE__->table("work_days");
__PACKAGE__->columns(All => qw/
    id work_date time_in time_out time_lunch note is_vacation is_holiday
    is_sick_day
/);
__PACKAGE__->has_a_datetime('work_date');
__PACKAGE__->has_a_datetime('time_in');
__PACKAGE__->has_a_datetime('time_out');
################################################################################
sub find_week
{
    my $class = shift;
    my %args = @_;

    my $date = Metiisto::Util::DateTime->sunday(for_date => $args{date});
    my $start_str = $date->format_db(date_only => 1);
    $date->add_days(days => 6);
    my $end_str = $date->format_db(date_only => 1);

    my @days = $class->search_where(
        {
            work_date => {'between' => [$start_str, $end_str]}
        },
        {
            order_by      => 'work_date, time_in',
        }
    );

    return(wantarray ? @days : \@days);
}
################################################################################
sub day_type
{
    my $this = shift;
    my $new_type = shift;

    my $type;

    # Set
    if (defined $new_type)
    {
        # First Clear all Flags (Also same as REGULAR)
        $this->is_vacation(0);
        $this->is_holiday(0);
        $this->is_sick_day(0);
        
        if ($new_type == DAY_TYPE_HOLIDAY) {
            $this->is_holiday(1);
        }
        elsif ($new_type == DAY_TYPE_VACATION) {
            $this->is_vacation(1);
        }
        elsif ($new_type == DAY_TYPE_SICK) {
            $this->is_sick_day(1);
        }

        $type = $new_type;
    }
    # Get
    else
    {
        $type = DAY_TYPE_REGULAR;
        if ($this->is_holiday())
        {
            $type = DAY_TYPE_HOLIDAY;
        }
        elsif ($this->is_vacation())
        {
            $type = DAY_TYPE_VACATION;
        }
        elsif ($this->is_sick_day())
        {
            $type = DAY_TYPE_SICK;
        }
    }
    
    return ($type);
}
################################################################################
sub total_hours
{
    my $this = shift;

    my ($lh, $lm, $ls) = split /:/, $this->time_lunch(), 3;
    my $lunch_seconds = ($lh * 60 * 60) + ($lm * 60) + $ls;

    my $seconds = $this->time_out()->epoch() - $this->time_in()->epoch();
    my $hours = ($seconds - $lunch_seconds) / 3600;

    return (sprintf("%0.2f", $hours));
}
################################################################################
1;
