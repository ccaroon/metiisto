package metiisto;
################################################################################
use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '1.0';

use Metiisto::Controller::Home;
use Metiisto::Controller::Entries;
use Metiisto::Controller::Users;
use Metiisto::Controller::Workdays;
use Metiisto::Controller::Todos;
use Metiisto::Controller::Lists;
use Metiisto::Controller::Notes;
use Metiisto::Controller::Countdowns;
use Metiisto::Controller::Reports;
use Metiisto::Controller::TaggedObjects;
################################################################################
hook before => sub
{
    # undef is for the leading slash
    my (undef,$controller,$id,$action) = split '/', request->path_info, 4;
    var controller => $controller;
    var id         => $id;
    var action     => $action;
    # NOTE: I want to access the "environment" setting in my templates. I can't
    #       find any other way except to set a 'var'
    var env        => setting('environment');

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
