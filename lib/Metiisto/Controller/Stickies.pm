package Metiisto::Controller::Stickies;
################################################################################
use strict;

use Dancer ':syntax';

use base 'Metiisto::Controller::Base';

use Metiisto::Note;
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
sub convert_to_note
{
    my $this  = shift;
    my %args  = @_;

    my $sticky = Metiisto::Sticky->retrieve($args{id});
    my $note   = Metiisto::Note->insert({
        title => substr($sticky->body(), 0, 30),
        body  => $sticky->body()
    });

    redirect "/notes/" . $note->id();
}
################################################################################
1;
