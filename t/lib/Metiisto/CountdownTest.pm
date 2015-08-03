package Metiisto::CountdownTest;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/t/lib";
use Metiisto::Test::Factory;

use Test::More;

use base 'Metiisto::BaseTest';
use constant TESTED_CLASS => 'Metiisto::Countdown';
################################################################################
# sub test_time_remaining : Test(7)
# {
#     my $this = shift;
# 
#     my $c = Metiisto::Test::Factory->create(countdown => {});
#     my %expected = (
#         year   => 5,
#         month  => 5,
#         week   => 5,
#         day    => 5,
#         hour   => 5 * 24,
#         minute => 7_200,
#         second => 432_000,
#     );
#     foreach my $unit (sort keys %{TESTED_CLASS->UNITS})
#     {
#         my $adjustment = 0.25;
#         $adjustment = 1 if $unit eq 'second';
# 
#         $c->units($unit);
# 
#         ok((
#             $c->time_remaining($c->start_date()) == $expected{$unit} - $adjustment
#                             or
#             $c->time_remaining($c->start_date()) == $expected{$unit}),
#             "time left should be correct for '$unit'"
#         );
#     }
# }
################################################################################
sub test_auto_unit_adjust : Tests 
{
    my $this = shift;
    
    my $c = Metiisto::Test::Factory->create(countdown => {
        start_date => "2015-08-03 09:00:00",
        end_date   => "2015-08-03 17:00:00",
        units      => Metiisto::Countdown->UNIT_YEAR
    });
    
    my $parts = $c->as_hash();
use Data::Dumper;
local $Data::Dumper::Maxdepth=2;
print STDERR '=====> Begin Dump \$parts <====='."\n";
print STDERR Dumper $parts;
print STDERR '=====> End Dump \$parts <====='."\n";

}
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
# sub test_english_units : Test(1)
# {
#     my $this = shift;
# 
#     my $c = Metiisto::Test::Factory->create(countdown => {});
#     is $c->english_units(), 'Days', 'should return correct units as english string';
# }
################################################################################
1;
