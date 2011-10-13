package Metiisto::Util::DateTime;
################################################################################
use strict;

use Date::Format;
use Date::Parse;
use Moose;

use constant DAY => 86_400;

use constant FORMAT_DB_DATE     => '%Y-%m-%d';
use constant FORMAT_DB_DATETIME =>  FORMAT_DB_DATE . ' %H:%M:%S';
use constant FORMAT_TIME        => "%I:%M%p";
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

    my $dt = $class->new();
    if (defined $date_str)
    {
        $dt->epoch(str2time($date_str));
    }

    return($dt);
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
sub add_days
{
    my $this = shift;
    my %args = @_;

    my $current_epoch = $this->epoch();
    $this->epoch($current_epoch + ($args{days} * DAY));
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
    my $format = shift || '%b %d, %Y';

    my $formatted_dt = undef;
    if (defined $this->epoch())
    {
        $formatted_dt = time2str($format,$this->epoch());
    }

    return($formatted_dt);
}
################################################################################
sub format_time
{
    my $this = shift;
    return ($this->format(FORMAT_TIME));
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
