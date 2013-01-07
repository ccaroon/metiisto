package Metiisto::Controller::Tags;
################################################################################
use strict;

use Dancer ':syntax';
use base 'Metiisto::Controller::Base';

use Metiisto::Tag;
################################################################################
sub list
{
    my $this = shift;

    my $data = Metiisto::Tag->cloud_data();

    my $out = template 'tags/list', { cloud_data => $data };

    return ($out);
}
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
