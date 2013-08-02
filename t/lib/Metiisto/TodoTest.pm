package Metiisto::TodoTest;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/t/lib";
use Metiisto::Test::Factory;

use Test::More;

use base 'Metiisto::BaseTest';
use constant TESTED_CLASS => 'Metiisto::Todo';
################################################################################
sub basic : Tests
{
    my $this = shift;

    my $todo = Metiisto::Test::Factory->create(todo => {});
    ok $todo;
}
################################################################################
1;
