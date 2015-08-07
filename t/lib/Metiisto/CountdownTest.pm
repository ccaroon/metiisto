package Metiisto::CountdownTest;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/t/lib";
use Metiisto::Test::Factory;

use Test::More;

use base 'Metiisto::BaseTest';
use constant TESTED_CLASS => 'Metiisto::Countdown';
################################################################################
sub test_has_started : Test(2)
{
    my $this = shift;
    
    my $not_started = Metiisto::Test::Factory->create(countdown => {
        start_date => "2025-12-31"
    });
    is $not_started->has_started(), 0, "Countdown should not have started";
    
    my $has_started = Metiisto::Test::Factory->create(countdown => {
        start_date => "2015-07-03 08:00:00",
    });
    is $has_started->has_started(), 1, "Countdown should have started";
}
################################################################################
sub test_has_ended : Test(2)
{
    my  $this = shift;
    
    my $not_ended = Metiisto::Test::Factory->create(countdown => {
        start_date => "2015-01-01",
        end_date   => "2025-12-31"
    });
    is $not_ended->has_ended(), 0, "Countdown should not have ended";
    
    my $has_ended = Metiisto::Test::Factory->create(countdown => {
        start_date => "2015-07-03 08:00:00",
        end_date   => "2015-07-06 23:59:59"
    });
    is $has_ended->has_ended(), 1, "Countdown should have ended";
}
################################################################################
sub test_is_ongoing : Test(3)
{
    my $this = shift;
    
    my $the_day = Metiisto::Test::Factory->create(countdown => {
        start_date => Metiisto::Util::DateTime->now(),
        end_date   => Metiisto::Util::DateTime->now()->add(units => 'hours', count => 8)
    });
    is $the_day->is_ongoing(), 1, "Countdown should be ongoing.";
    
    my $spring_break = Metiisto::Test::Factory->create(countdown => {
        start_date => "2015-03-30",
        end_date   => "2015-04-03"
    });
    is $spring_break->is_ongoing(), 0, "Countdown should not be ongoing";
    
    my $future_day = Metiisto::Test::Factory->create(countdown => {
        start_date => "2025-03-30",
        end_date   => "2025-12-31"
    });
    is $future_day->is_ongoing(), 0, "Countdown should not be ongoing";
}
################################################################################
sub test_english_units : Test(2)
{
    my $this = shift;

    my $c = Metiisto::Test::Factory->create(countdown => {});

    is $c->english_units($c->start_date()), 'Days',  '1 - should return correct units as english string';
    is $c->english_units($c->end_date()),   'Weeks', '2 - should return correct units as english string';
}
################################################################################
1;
