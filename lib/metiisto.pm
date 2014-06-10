package metiisto;
################################################################################
use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '1.0';

use Metiisto::Controller::API;
use Metiisto::Controller::Home;
use Metiisto::Controller::Entries;
use Metiisto::Controller::Users;
use Metiisto::Controller::Workdays;
use Metiisto::Controller::Todos;
use Metiisto::Controller::Lists;
use Metiisto::Controller::Notes;
use Metiisto::Controller::Countdowns;
use Metiisto::Controller::Reports;
use Metiisto::Controller::Stickies;
use Metiisto::Controller::Tags;
use Metiisto::Controller::TaggedObjects;
use Metiisto::Weather;
################################################################################
hook before => sub
{
    # undef is for the leading slash
    my (undef,$controller,$id,$action) = split '/', request->path_info, 4;
    # Handle action that's not on a specific item: /controller/action
    unless ($action)
    {
        $action = $id;
        $id     = undef;
    }
    var controller => $controller;
    var id         => $id;
    var action     => $action;

    # NOTE: I want to access the "environment" setting in my templates. I can't
    #       find any other way except to set a 'var'
    var env        => setting('environment');

    my $user = session('user');
    if ($user)
    {
        if ($user->location())
        {
            my $weather = Metiisto::Weather->current(location => $user->location());
            var weather => $weather;
        }
    }
    else
    {
        redirect '/users/login' unless request->path_info =~ m|^/users/login|;
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
