package Metiisto::Controller::Home;
################################################################################
use strict;

use Dancer ':syntax';

use Metiisto::Todo;

use base 'Metiisto::Controller::Base';
################################################################################
sub home
{
    my $this = shift;

    my @todos = Metiisto::Todo->search(completed => 0, list_id => undef);
    
    my @tickets = (
        {key => 'MIDEV-3719', summary => 'Suppress buy photo link'},
    );

    my $out = template 'home/index', {
        tickets => \@tickets,
        todos   => \@todos,
    };

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
