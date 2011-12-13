package Metiisto::Test::Factory;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use Metiisto::Util::DateTime;

my @INSTANCE_CACHE;
################################################################################
sub create
{
    my $class = shift;
    my %args = @_;

    my $method = $args{class};
    $method =~ s/::/_/g;
    die "$class does not know how to create '$args{class}'"
        unless $class->can($method);
    my $instance = $class->$method(%args);

    return ($instance);
}
################################################################################
sub Metiisto_Countdown
{
    my $class = shift;
    my %args = @_;
    
    my $iclass = $args{class};
    
    my $target_date = Metiisto::Util::DateTime->now();
    $target_date->add_days(days => 5);
    my $c = $iclass->insert({
        title       => 'Countdown '.int rand 1_000,
        target_date => $target_date,
        units       => $iclass->UNIT_DAY,
        on_homepage => 1,
    });
    push @INSTANCE_CACHE, $c;

    return ($c);
}
################################################################################
sub cleanup
{
    my $class = shift;

    foreach my $inst (@INSTANCE_CACHE)
    {
        $inst->delete();
    }
}
################################################################################
1;
