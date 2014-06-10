package Metiisto::Sticky;
################################################################################
use strict;

use Metiisto::Util::DateTime;

use HTML::Entities;

use base qw(Metiisto::Base Metiisto::Taggable);
################################################################################
__PACKAGE__->table('stickies');

__PACKAGE__->columns(Primary   => qw/id/);
__PACKAGE__->columns(Essential => qw/body created_date/);
__PACKAGE__->columns(Other     => qw/updated_date/);

__PACKAGE__->has_a_datetime('created_date');
__PACKAGE__->has_a_datetime('updated_date');

__PACKAGE__->add_trigger(before_create => \&_trigger_before_create);
__PACKAGE__->add_trigger(before_update => \&_trigger_before_update);

__PACKAGE__->init_tagging();
################################################################################
sub _trigger_before_create
{
    my $this = shift;
    my $now  = Metiisto::Util::DateTime->now();

    $this->body(encode_entities($this->body()));
    $this->created_date($now);
    $this->updated_date($now);
}
################################################################################
sub _trigger_before_update
{
    my $this = shift;
    my $now  = Metiisto::Util::DateTime->now();

    $this->updated_date($now);
}
################################################################################
1;
