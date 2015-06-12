package Template::Plugin::Formatter;
################################################################################
use strict;

use base qw( Template::Plugin );
use Template::Plugin;
use Metiisto::Util::DateTime;
################################################################################
sub new {
    my $class   = shift;
    my $context = shift;
    my $this    = {};

    bless $this, $class;

    return ($this);
}
################################################################################
sub minutes_to_timestr {
    my $this      = shift;
    my $total_min = shift;
    
    my $hours = int ($total_min / 60);
    my $min   = $total_min % 60;
    
    return (sprintf("%dh %02dm", $hours, $min));
}
################################################################################
1;
