package metiisto;
################################################################################
use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '1.0';

use Metiisto::Controller::Entries;
Metiisto::Controller::Entries->declare_routes();

use Metiisto::Controller::Home;
Metiisto::Controller::Home->declare_routes();
################################################################################
# Default Route
################################################################################
get '/' => sub {
    template 'index';
};
################################################################################
1;
