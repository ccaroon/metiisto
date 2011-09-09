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

    my @entries = Metiisto::Entry->search_where(
        {1=>1},
        {limit_dialect => 'LimitOffset', limit => 15, offset => 0}
    );

    my $out = '';
    foreach my $e (@entries)
    {
        $out .= "<li>" . $e->id() . " - " . $e->subject() . "<br>\n";
    }
    
    return ($out);
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
