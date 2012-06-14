################################################################################
Then qr/^the application should respond to '(GET|POST|PUT|DELETE) ([^']*)'$/,
func ($c)
{
    my $verb  = $1;
    my $route = $2;
    route_exists [$verb => $route];
};
################################################################################
