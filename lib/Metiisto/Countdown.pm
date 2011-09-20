package Metiisto::Countdown;
################################################################################
use strict;

use feature 'switch';

use constant UNIT_YEAR   => 'year';
use constant UNIT_MONTH  => 'month';
use constant UNIT_WEEK   => 'week';
use constant UNIT_DAY    => 'day';
use constant UNIT_HOUR   => 'hour';
use constant UNIT_MINUTE => 'minute';
use constant UNIT_SECOND => 'second';
    
use constant UNITS =>
[
    UNIT_YEAR,
    UNIT_MONTH,
    UNIT_WEEK,
    UNIT_DAY,
    UNIT_HOUR,
    UNIT_MINUTE,
    UNIT_SECOND,
];
    
use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('countdowns');
__PACKAGE__->columns(All => qw/
    id title target_date units on_homepage created_at updated_at
/);
__PACKAGE__->has_a_datetime('target_date');
__PACKAGE__->has_a_datetime('created_at');
__PACKAGE__->has_a_datetime('updated_at');
################################################################################
sub time_left
{
    my $this = shift;

    my $now = time();
    my $secs_diff = $this->target_date()->epoch() - $now;

    my $time_left;
    given ($this->units())
    {
        when (UNIT_YEAR)   { $time_left = $secs_diff / (86400*365); }
        when (UNIT_MONTH)  { $time_left = $secs_diff / (86400*30); }
        when (UNIT_WEEK)   { $time_left = $secs_diff / (86400*7); }
        when (UNIT_DAY)    { $time_left = $secs_diff / 86400; }
        when (UNIT_HOUR)   { $time_left = $secs_diff / 3600; }
        when (UNIT_MINUTE) { $time_left = $secs_diff / 60; }
        when (UNIT_SECOND) { $time_left = $secs_diff; }
    }

    # Auto-adjust units
    if ($this->units() ne UNIT_SECOND && abs($time_left) < 1)
    {
        my $u_index = UNITS->[$this->units()] + 1;
        $this->units() = UNITS->[$u_index];
        $time_left = $this->time_left();
    }
    else #Round to the nearest quarter unit
    {
        #time_left = time_left.ceil;
        my $is_neg = ($time_left < 0.0) ? 1 : 0;

        my $base = abs($time_left);
        my $frac = abs($time_left) - $base;

        given ($frac)
        {
            when ($_ >= 0.00 && $_ < 0.25) { $time_left = $base + 0.00; }
            when ($_ >= 0.25 && $_ < 0.50) { $time_left = $base + 0.25; }
            when ($_ >= 0.50 && $_< 0.75)  { $time_left = $base + 0.50; }
            when ($_ >= 0.75 && $_< 1.00)  { $time_left = $base + 0.75; }
        }

        $time_left = $time_left * -1 if $is_neg;
    }

    return ($time_left);
}
################################################################################
1;
