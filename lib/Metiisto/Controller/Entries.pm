package Metiisto::Controller::Entries;
################################################################################
# $Id: $
################################################################################
use strict;

use base 'Metiisto::Controller::Base';

use Metiisto::Entry;
################################################################################
sub list
{
    my $this = shift;

    my $entry = Metiisto::Entry->retrieve(77);
    
    return ("Entry: ".$entry->subject());
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;
    
    my $entry = Metiisto::Entry->retrieve($args{id});
    
    return ("Entry: ".$entry->subject());
}
################################################################################
1;
