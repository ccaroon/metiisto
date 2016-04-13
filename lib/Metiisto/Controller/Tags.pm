package Metiisto::Controller::Tags;
################################################################################
use strict;

use Dancer ':syntax';
use base 'Metiisto::Controller::Base';

use Metiisto::Tag;

__PACKAGE__->setup_list_handler(
    order_by => 'name',
    entries_per_page => 25,
    filter_fields      => ['name']
);
################################################################################
sub declare_routes
{
    my $class = shift;

    # List
    get "/tags" => sub {
        my $c = $class->new();
        my $out = $c->list();
        return ($out);
    };
}
################################################################################
1;
