package Metiisto::Util::DateTime;
################################################################################
use strict;

use Date::Format;
use Date::Parse;
use Moose;
################################################################################
has epoch => (
    is  => 'rw',
    isa => 'Int',
);
################################################################################
sub parse
{
    my $class    = shift;
    my $date_str = shift;

    return($class->new(epoch => str2time($date_str)));
}
################################################################################
sub format
{
    my $this   = shift;
    my $format = shift;

    return(time2str($format,$this->epoch()));
}
################################################################################
1;
