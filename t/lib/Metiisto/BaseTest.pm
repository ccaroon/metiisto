package Metiisto::BaseTest;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/t/lib";
use Metiisto::Test::Factory;

use Test::More;

use base 'Test::Class';

__PACKAGE__->SKIP_CLASS(1);
################################################################################
sub base_startup : Test(startup => 1)
{
    my $this = shift;
    use_ok $this->TESTED_CLASS;
}
################################################################################
sub base_shutdown : Test(shutdown)
{
    my $this = shift;
    Metiisto::Test::Factory->cleanup();
}
################################################################################
1;
