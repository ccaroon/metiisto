use Test::More tests => 2;
use strict;
use warnings;

use lib "$ENV{METIISTO_HOME}/lib";

# the order is important
use metiisto;
use Dancer::Test;

route_exists [GET => '/'], 'a route handler is defined for /';
response_status_is ['GET' => '/'], 200, 'response status is 200 for /';
