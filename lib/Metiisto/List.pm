package Metiisto::List;
################################################################################
use strict;

use base qw(Metiisto::Base Metiisto::Taggable);
################################################################################
__PACKAGE__->table('lists');

__PACKAGE__->columns(Primary   => qw/id/);
__PACKAGE__->columns(Essential => qw/name/);

__PACKAGE__->has_many(items => 'Metiisto::Todo', { order_by => 'completed,priority' });

__PACKAGE__->init_tagging();
################################################################################
sub item_count
{
    my $this = shift;

    my $count = $this->items();
    return ($count);
}
################################################################################
sub completed_items
{
    my $this = shift;

    my @items = $this->items();
    @items = grep {$_->completed()} @items;
    
    return (wantarray ? @items : \@items);
}
################################################################################
sub incomplete_items
{
    my $this = shift;

    my @items = $this->items();
    @items = grep {!$_->completed()} @items;
    
    return (wantarray ? @items : \@items);    
}
################################################################################
1;
