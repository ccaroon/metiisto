package metiisto;
################################################################################
use Dancer ':syntax';
use Dancer::Plugin::Database;

use Metiisto::Controller::Entries;

our $VERSION = '1.0';
# TODO: move routes somewhere else????
################################################################################
get '/' => sub {
    template 'index';
};
################################################################################
get '/entries' => sub {

    my $c = Metiisto::Controller::Entries->new();
    my $out = $c->list();

    return ($out);
};
################################################################################
get '/entries/:id' => sub {

    my $c = Metiisto::Controller::Entries->new();
    my $out = $c->show(id => param('id'));

    return ($out);
};
################################################################################
1;

    