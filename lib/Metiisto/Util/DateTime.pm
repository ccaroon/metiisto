package Metiisto::Util::DateTime;
################################################################################
use strict;

use Date::Format;
use Date::Parse;
use Moose;

use constant FORMAT_DB => '%Y-%m-%d %H:%M:%S';
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
sub now
{
    my $class = shift;
    return($class->new(epoch => time()));
}
################################################################################
sub format
{
    my $this   = shift;
    my $format = shift;

    return(time2str($format,$this->epoch()));
}
################################################################################
sub format_db
{
    my $this = shift;
    return ($this->format(FORMAT_DB));
}
################################################################################
1;
