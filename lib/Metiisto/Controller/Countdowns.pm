package Metiisto::Controller::Countdowns;
################################################################################
use strict;

use Dancer ':syntax';

use Metiisto::Util::DateTime;

use base 'Metiisto::Controller::Base';

use Metiisto::Countdown;

__PACKAGE__->setup_list_handler(
    order_by => 'start_date',
);
################################################################################
sub new_record
{
    my $this = shift;
    my %args = @_;

    my @units = sort
        { Metiisto::Countdown->UNITS->{$b} <=> Metiisto::Countdown->UNITS->{$a} }
        keys %{Metiisto::Countdown->UNITS()};
    my $countdown = { on_homepage => 0, is_real_time => 0 };

    my $out = $this->SUPER::new_record(
        %args,
        item => $countdown,
        template_vars => {units => \@units}
    );

    return ($out);
}
################################################################################
sub create
{
    my $this = shift;

    # Add the start_time to the start_date db field.
    params->{'countdown.start_date'}
        .= ' '
        # NOTE: Not sure why I have to convert to 24h time.
        . Metiisto::Util::DateTime->parse(delete params->{'countdown.start_time'})
        ->format('%R');
        
    params->{'countdown.end_date'}
        .= ' '
        # NOTE: Not sure why I have to convert to 24h time.
        . Metiisto::Util::DateTime->parse(delete params->{'countdown.end_time'})
        ->format('%R');

    my $out = $this->SUPER::create();

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;
    
    my @units = sort
        { Metiisto::Countdown->UNITS->{$b} <=> Metiisto::Countdown->UNITS->{$a} }
        keys %{Metiisto::Countdown->UNITS()};

    my $out = $this->SUPER::edit(%args,
        template_vars => {units => \@units}
    );

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;

    params->{'countdown.start_date'}
        .= ' ' . delete params->{'countdown.start_time'};
        
    params->{'countdown.end_date'}
        .= ' ' . delete params->{'countdown.end_time'};

    my $out = $this->SUPER::update(%args,
        pre_obj_update => sub {
            my $obj = shift;
            $obj->is_real_time(0) unless params->{'countdown.is_real_time'};
            $obj->on_homepage(0) unless params->{'countdown.on_homepage'};
        }
    );

    return ($out);
}
################################################################################
1;
