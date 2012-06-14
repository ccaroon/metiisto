################################################################################
# TODO: This does not work b/c Dancer and/or Dancer::Plugin::Database is not
#       playing well with Test::BDD::Cucumber (or something).
#       In any case Dancer does not seem to be loading the config and thus
#       Dancer::Plugin::Database can't get a connection.
# ------------------------------------------------------------------------------
#Use of uninitialized value in concatenation (.) or string at /usr/local/share/perl/5.10.1/Dancer/Plugin/Database.pm line 115, <DATA> line 998.
#Use of uninitialized value $driver in string eq at /usr/local/share/perl/5.10.1/Dancer/Plugin/Database.pm line 125, <DATA> line 998.
################################################################################
use strict;

BEGIN
{
    $ENV{METIISTO_ENV}       = 'test';
    $ENV{DANCER_ENVIRONMENT} = $ENV{METIISTO_ENV};
}

use Test::More;
use Test::BDD::Cucumber::StepFile;
use Method::Signatures;

# NOTE: Order here is *very* important
use Dancer qw(:script !pass !load);
use Dancer::Plugin::Database;

use lib "$ENV{METIISTO_HOME}/lib";
use metiisto;
use Dancer::Test;
################################################################################
require 'routing.pl';
################################################################################
When qr/^I POST data to '\/entries'$/,
func ($c)
{
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
    
    $c->stash->{scenario}->{response} = $response;
};
################################################################################
Then qr/^the response should be '(\d+)'$/,
func($c)
{
    my $code = $1;
    my $r = $c->stash->{scenario}->{response};
    is $r->status(), $1;
};
################################################################################
Then qr/a new Entry should be created in the database/,
func($c)
{
    # TODO: get new Entry ID from header->Location->path
    # TODO: load entry from database and inspect fields
};
################################################################################
