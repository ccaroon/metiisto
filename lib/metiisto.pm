package metiisto;
################################################################################
use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '1.0';

use Metiisto::Controller::Users;
Metiisto::Controller::Users->declare_routes();

use Metiisto::Controller::Entries;
Metiisto::Controller::Entries->declare_routes();

use Metiisto::Controller::Home;
Metiisto::Controller::Home->declare_routes();
################################################################################
before sub
{
    # undef is for the leading slash
    my (undef,$controller,$id,$action) = split '/', request->path_info, 4;
    var controller => $controller;
    var id         => $id;
    var action     => $action;

    if (!session('user') and request->path_info !~ m|^/users/login|)
    {
        redirect '/users/login';
    }
};
################################################################################
# Default Route
################################################################################
get '/' => sub
{
    template 'index';
};
################################################################################
1;
