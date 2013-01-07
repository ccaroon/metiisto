package Metiisto::Tag;
################################################################################
use strict;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('tags');

__PACKAGE__->columns(Primary   => qw/id/);
__PACKAGE__->columns(Essential => qw/name/);

__PACKAGE__->has_many(objects => 'Metiisto::TaggedObject');
################################################################################
sub names
{
    my $class = shift;
    
    my @names = map { $_->name() } $class->retrieve_all();
    
    return (wantarray ? @names : \@names);
}
################################################################################
sub cloud_data
{
    my $class = shift;
    my %args  = @_;

    my @tags = Metiisto::Tag->retrieve_all();
    # Tag Name => Used Count
    my %cloud_data = map { $_->name() => scalar($_->objects())->count() } @tags;

    return (wantarray ? %cloud_data : \%cloud_data);
}
################################################################################
1;
