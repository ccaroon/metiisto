package Metiisto::Util::DateTime;
################################################################################
use strict;

use Date::Format;
use Date::Parse;
use Moose;

use constant FORMAT_DB_DATE     => '%Y-%m-%d';
use constant FORMAT_DB_DATETIME =>  FORMAT_DB_DATE . ' %H:%M:%S';
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
sub monday
{
    my $class = shift;
    
    my $week_day = Metiisto::Util::DateTime->now()->format("%w");
    my $monday = time() - (86_400 * ($week_day-1));
    
    return (Metiisto::Util::DateTime->new(epoch => $monday));
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
    my %args = @_;

    return (
        $args{date_only}
            ? $this->format(FORMAT_DB_DATE)
            : $this->format(FORMAT_DB_DATETIME)
    );
}
################################################################################
1;
