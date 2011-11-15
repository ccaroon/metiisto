package metiisto;
################################################################################
use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '1.0';

use Metiisto::Controller::Home;
Metiisto::Controller::Home->declare_routes();

use Metiisto::Controller::Entries;
Metiisto::Controller::Entries->declare_routes();

use Metiisto::Controller::Users;
Metiisto::Controller::Users->declare_routes();

use Metiisto::Controller::Workdays;
Metiisto::Controller::Workdays->declare_routes();

use Metiisto::Controller::Todos;
Metiisto::Controller::Todos->declare_routes();

use Metiisto::Controller::Lists;
Metiisto::Controller::Lists->declare_routes();

use Metiisto::Controller::Notes;
Metiisto::Controller::Notes->declare_routes();

use Metiisto::Controller::Countdowns;
Metiisto::Controller::Countdowns->declare_routes();

use Metiisto::Controller::Reports;
Metiisto::Controller::Reports->declare_routes();
################################################################################
hook before => sub
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
