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
    my %args = @_;

    my $where = "list_id = ?";
    my @ph    = ($this->id());

    foreach my $k (keys %args) {
        $where .= " AND $k = ?";
        push @ph, $args{$k};
    }

    my $count = Metiisto::Todo->count_where($where, \@ph);

    return ($count);
}
##############################################################################
sub percent_complete
{
    my $this = shift;

    my $pc = int(($this->item_count(completed => 1) / $this->item_count()) * 100);

    return($pc);
}
################################################################################
sub completed_items
{
    my $this = shift;

    my @items = $this->items(completed => 1);

    return (wantarray ? @items : \@items);
}
################################################################################
sub incomplete_items
{
    my $this = shift;

    my @items = $this->items(completed => 0);
    
    return (wantarray ? @items : \@items);    
}
################################################################################
1;
