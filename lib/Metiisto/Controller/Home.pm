package Metiisto::Controller::Home;
################################################################################
use strict;

use Dancer ':syntax';

use base 'Metiisto::Controller::Base';
################################################################################
sub home
{
    my $this = shift;

    my @tickets = (
        {key => 'MIDEV-3719', summary => 'Suppress buy photo link'},
    );
    my $out = template 'home/index', { tickets => \@tickets };

    return ($out);
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
    get '/home' => sub {

        my $c = Metiisto::Controller::Home->new();
        my $out = $c->home();

        return ($out);
    };

}
################################################################################
1;
