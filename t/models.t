#!/bin/env perl
################################################################################
use strict;

BEGIN
{
    $ENV{METIISTO_ENV}       = 'test';
    $ENV{DANCER_ENVIRONMENT} = $ENV{METIISTO_ENV};
}
use Dancer2 appname => 'metiisto';

use lib "$ENV{METIISTO_HOME}/t/lib";

use Test::Class;
################################################################################
use Metiisto::CountdownTest;
#use Metiisto::PreferenceTest;
use Metiisto::Util::DateTimeTest;
use Metiisto::TodoTest;
################################################################################
Test::Class->runtests();
