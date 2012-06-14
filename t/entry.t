#!/bin/env perl
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";

BEGIN
{
    $ENV{METIISTO_ENV}       = 'test';
    $ENV{DANCER_ENVIRONMENT} = $ENV{METIISTO_ENV};
}

use Dancer qw(:script !pass);
use Dancer::Plugin::Database;
use metiisto;
use Dancer::Test;

use Test::More;

my $response = dancer_response('POST', '/entries',
    {
        params => {
            'entry.task_date'   => '2012-06-13',
            'entry.ticket_num'  => 'MIDEV-1234',
            'entry.category'    => 'Ticket',
            'entry.subject'     => 'Test to create a new entry',
            'entry.description' => 'just testing create with cucumber',
            'tags'              => ['Test','Cucumber', 'Create']
        }
    }
);

is $response->status(), 302;

use Data::Dumper;

my $uri = $response->header('Location');
my $path = $uri->path;

# TODO: get ID from path
# TODO: load entry from database and inspect fields
# TODO: clean up database

done_testing();
