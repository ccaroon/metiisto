package Metiisto::Util::Cache;
################################################################################
use strict;

my %CACHE;
################################################################################
sub set
{
    my $class = shift;
    my %args  = @_;

    $args{ttl} ||= 60;

    my $data = {
        ttl       => $args{ttl},
        cached_at => time(),
        value     => $args{value}
    };

    $CACHE{$args{key}} = $data;
}
################################################################################
sub get
{
    my $class = shift;
    my %args  = @_;
    
    my $data = $CACHE{$args{key}};

    my $value = undef;
    if (defined $data and time() <= $data->{cached_at} + $data->{ttl})
    {
        $value = $data->{value};
    }
    else
    {
        # Expired. Clear from cache.
        $class->clear(key => $args{key});
    }

    return ($value);
}
################################################################################
sub clear
{
    my $class = shift;
    my %args  = @_;

    undef $CACHE{$args{key}};
}
################################################################################
sub destroy
{
    my $class = shift;

    %CACHE = ();
}
################################################################################
1;
