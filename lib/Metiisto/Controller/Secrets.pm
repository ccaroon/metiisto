package Metiisto::Controller::Secrets;
################################################################################
use strict;

use Dancer ':syntax';

use base 'Metiisto::Controller::Base';

use Metiisto::Secret;

__PACKAGE__->setup_list_handler(
    entries_per_page => 15,
    order_by         => 'category',
    filter_fields    => ['category', 'username', 'note']
);
################################################################################
sub _post_create_action
{
    my $this = shift;
    my $obj  = shift;

    return (redirect "/".vars->{controller});
}
################################################################################
1;
