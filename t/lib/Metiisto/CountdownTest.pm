package Metiisto::CountdownTest;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/t/lib";
use Metiisto::Test::Factory;

use Test::More;

use base 'Metiisto::BaseTest';
use constant TESTED_CLASS => 'Metiisto::Countdown';
################################################################################
sub test_time_left : Test(7)
{
    my $this = shift;

    my $c = Metiisto::Test::Factory->create(class => TESTED_CLASS);
    my %expected = (
        year   => 5,
        month  => 5,
        week   => 5,
        day    => 5,
        hour   => 5 * 24,
        minute => 7_200,
        second => 432_000,
    );
    foreach my $unit (sort keys %{TESTED_CLASS->UNITS})
    {
        my $adjustment = 0.25;
        $adjustment = 1 if $unit eq 'second';

        $c->units($unit);

        ok((
            $c->time_left() == $expected{$unit} - $adjustment
                            or
            $c->time_left() == $expected{$unit}),
            "time left should be correct for '$unit'"
        );
    }
}
################################################################################
sub test_english_units : Test(1)
{
    my $this = shift;

    my $c = Metiisto::Test::Factory->create(class => TESTED_CLASS);
    is $c->english_units(), 'Days', 'should return correct units as english string';
}
################################################################################
1;
