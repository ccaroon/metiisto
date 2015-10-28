#!/usr/bin/env perl
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use metiisto;
use Metiisto::Controller::API;
use Plack::Builder;

Metiisto::Controller::API->init();

builder {
    mount '/'    => metiisto->to_app;
    mount '/api' => Metiisto::Controller::API->to_app;
};
