package Metiisto::Countdown;
################################################################################
use strict;

use constant UNIT_YEAR   => 'year';
use constant UNIT_MONTH  => 'month';
use constant UNIT_WEEK   => 'week';
use constant UNIT_DAY    => 'day';
use constant UNIT_HOUR   => 'hour';
use constant UNIT_MINUTE => 'minute';
use constant UNIT_SECOND => 'second';
    
use constant UNITS =>
{
    UNIT_YEAR()   => 0,
    UNIT_MONTH()  => 1,
    UNIT_WEEK()   => 2,
    UNIT_DAY()    => 3,
    UNIT_HOUR()   => 4,
    UNIT_MINUTE() => 5,
    UNIT_SECOND() => 6,
};
my %UNITS_INDEX = map {UNITS->{$_} => $_} keys %{UNITS()};

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('countdowns');
__PACKAGE__->columns(All => qw/
    id title start_date end_date units on_homepage is_real_time
/);
__PACKAGE__->has_a_datetime('start_date');
__PACKAGE__->has_a_datetime('end_date');
################################################################################
sub has_started {
    my $this = shift;
    my $now  = time();
    
    my $has_started = $now >= $this->start_date()->epoch() ? 1 : 0;
    
    return ($has_started);
}
################################################################################
sub is_ongoing {
    my $this = shift;
    
    my $is_ongoing = $this->has_started() && !$this->has_ended() ? 1 : 0;

    return ($is_ongoing);
}
################################################################################
sub has_ended {
    my $this = shift;
    my $now  = time();

    my $has_ended = $now >= $this->end_date()->epoch() ? 1 : 0;    

    return ($has_ended);
}
################################################################################
sub _interval
{
    my $this = shift;
    my $date = shift;

    my $now = time();
    my $secs_diff = $date->epoch() - $now;

    my $time_left;
    if ($this->units() eq UNIT_YEAR) {
        $time_left = $secs_diff / (86400*365);
    }
    elsif ($this->units() eq UNIT_MONTH) {
        $time_left = $secs_diff / (86400*30);
    }
    elsif ($this->units() eq UNIT_WEEK) {
        $time_left = $secs_diff / (86400*7);
    }
    elsif ($this->units() eq UNIT_DAY) {
        $time_left = $secs_diff / 86400;
    }
    elsif ($this->units() eq UNIT_HOUR) {
        $time_left = $secs_diff / 3600;
    }
    elsif ($this->units() eq UNIT_MINUTE) {
        $time_left = $secs_diff / 60;
    }
    elsif ($this->units() eq UNIT_SECOND) {
        $time_left = $secs_diff;
    }

    # Auto-adjust units
    if ($this->units() ne UNIT_SECOND && abs($time_left) < 1)
    {
        my $new_unit = UNITS->{$this->units()} + 1;
        $this->units($UNITS_INDEX{$new_unit});
        $this->update();
        $time_left = $this->_interval($date);
    }
    else #Round to the nearest quarter unit
    {
        # my $is_neg = ($time_left < 0.0) ? 1 : 0;

        my $base = int abs($time_left);
        my $frac = abs($time_left) - $base;

        if ($frac >= 0.00 && $frac < 0.25) {
            $time_left = $base + 0.00;
        }
        elsif ($frac >= 0.25 && $frac < 0.50) {
            $time_left = $base + 0.25;
        }
        elsif ($frac >= 0.50 && $frac< 0.75) {
            $time_left = $base + 0.50;
        }
        elsif ($frac >= 0.75 && $frac< 1.00) {
            $time_left = $base + 0.75;
        }

        # $time_left *= -1 if $is_neg;
    }

    return (abs($time_left));
}
################################################################################
sub english_units
{
    my $this = shift;
    my $date = shift;

    my $units = ucfirst $this->units();
    $units .= 's' if abs($this->_interval($date)) > 1;
    
    return ($units);
}
################################################################################
sub format
{
    my $this  = shift;
    my %parts = (
        title       => $this->title(),
        has_started => 0,
        is_ongoing  => 0,
        has_ended   => 0
    );

    if ($this->has_ended()) {
        $parts{units}       = $this->english_units($this->end_date());
        $parts{interval}    = $this->_interval($this->end_date());
        $parts{has_started} = 1;
        $parts{has_ended}   = 1;
    }
    elsif ($this->is_ongoing()) {
        $parts{units}       = $this->english_units($this->end_date());
        $parts{interval}    = $this->_interval($this->end_date());
        $parts{has_started} = 1;
        $parts{is_ongoing}  = 1;
    }
    else {
        $parts{units}       = $this->english_units($this->start_date());
        $parts{interval}    = $this->_interval($this->start_date());
    }

    return (\%parts);
}
################################################################################
# sub to_string
# {
#     my $this = shift;
# }
################################################################################
1;
