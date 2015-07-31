package Metiisto::Test::Factory::Countdown;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use Metiisto::Countdown;
use Metiisto::Util::DateTime;
################################################################################
sub instance
{
    my $class     = shift;
    my $overrides = shift;

    my $attrs = $class->_default_attrs();
    map { $attrs->{$_} = $overrides->{$_} } keys %$overrides;

    my $obj = Metiisto::Countdown->insert($attrs);

    return ($obj);
}
################################################################################
sub _default_attrs
{
    my $class = shift;

    my $start_date = Metiisto::Util::DateTime->now();
    $start_date->add_days(days => 5);
    
    my $end_date = Metiisto::Util::DateTime->now();
    $end_date->add_days(days => 10);

    return ({
        title       => 'Countdown '.int rand 1_000,
        start_date  => $start_date,
        end_date    => $end_date,
        units       => Metiisto::Countdown->UNIT_DAY,
        on_homepage => 1,
    });
}
################################################################################
1;
