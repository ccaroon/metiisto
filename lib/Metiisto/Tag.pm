package Metiisto::Tag;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('tags');
__PACKAGE__->columns(All => qw/
    id name
/);
__PACKAGE__->has_many(objects => 'Metiisto::TaggedObject');
################################################################################
sub names
{
    my $class = shift;
    
    my @names = map { $_->name() } $class->retrieve_all();
    
    return (wantarray ? @names : \@names);
}
################################################################################
1;
