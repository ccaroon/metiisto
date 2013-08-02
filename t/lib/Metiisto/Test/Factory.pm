package Metiisto::Test::Factory;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use lib "$ENV{METIISTO_HOME}/t/lib";
use Metiisto::Util::DateTime;

use constant CLASS_MAP => {
    countdown => 'Metiisto::Test::Factory::Countdown',
    todo      => 'Metiisto::Test::Factory::Todo',
};

my @INSTANCE_CACHE;
################################################################################
sub create
{
    my $class = shift;
    my $thing = shift;
    my $attrs = shift;

    my $factory = CLASS_MAP->{$thing};
    die "Factory: Don't know how to create '$thing'." unless $factory;
    eval "require $factory";

    my $obj = $factory->instance($attrs);
    push @INSTANCE_CACHE, $obj;

    return ($obj);
}
################################################################################
sub cleanup
{
    my $class = shift;

    foreach my $inst (@INSTANCE_CACHE)
    {
        $inst->delete();
    }

    @INSTANCE_CACHE = ();
}
################################################################################
1;
