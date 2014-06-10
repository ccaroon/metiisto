package Metiisto::Controller::Stickies;
################################################################################
use strict;

use Dancer ':syntax';

use base 'Metiisto::Controller::Base';

use Metiisto::Sticky;

__PACKAGE__->setup_list_handler(
    entries_per_page => 15,
    order_by         => 'created_date desc',
    filter_fields    => ['body']
);
################################################################################
sub _post_create_action
{
    my $this = shift;
    redirect "/home";
}
################################################################################
1;
