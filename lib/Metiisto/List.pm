package Metiisto::List;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('lists');
__PACKAGE__->columns(All => qw/
    id name
/);
__PACKAGE__->has_many(items => 'Metiisto::Todo');
################################################################################
sub completed_items
{
    my $this = shift;

    my @items = $this->items();
    @items = grep {$_->completed()} @items;
    
    return (wantarray ? @items : \@items);
}
################################################################################
1;
