package Metiisto::Workday;
################################################################################
use strict;
use feature 'switch';

use base 'Metiisto::Base';

use constant DEFAULT_IN_TIME  =>'09:00';
use constant DEFAULT_OUT_TIME =>'17:00';

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
__PACKAGE__->has_a_datetime('time_lunch');
################################################################################
sub set_day_type
{
    my $this = shift;
    my $type = shift;
    
    # First Clear all Flags (Also same as REGULAR)
    $this->is_vacation(0);
    $this->is_holiday(0);
    $this->is_sick_day(0);
    
    given ($type)
    {
        when (DAY_TYPE_HOLIDAY) {
            $this->is_holiday(1);
        }
        when (DAY_TYPE_VACATION) {
            $this->is_vacation(1);
        }
        when (DAY_TYPE_SICK) {
            $this->is_sick_day(1);
        }
    }
}
################################################################################
sub total_hours
{
    my $this = shift;
    
    my $seconds = $this->time_out()->epoch() - $this->time_in()->epoch();
    my $hours = $seconds / 3600;
    
    return (sprintf("%0.2f", $hours));
}
################################################################################
1;
