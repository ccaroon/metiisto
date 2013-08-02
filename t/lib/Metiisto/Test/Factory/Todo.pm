package Metiisto::Test::Factory::Todo;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use Metiisto::Todo;
use Metiisto::Util::DateTime;
################################################################################
sub instance
{
    my $class     = shift;
    my $overrides = shift;

    my $attrs = $class->_default_attrs();
    map { $attrs->{$_} = $overrides->{$_} } keys %$overrides;

    my $todo = Metiisto::Todo->insert($attrs);

    return ($todo);
}
################################################################################
sub _default_attrs
{
    my $now = time;

    return ({
        priority        => 1,
        title           => "Todo - $now",
        completed       => 0,
        completed_date  => undef,
        due_date        => undef,
        list_id         => undef,
        description     => "Description for Todo - $now",
        repeat_duration => undef,
        parent_id       => undef
    });
}
################################################################################
1;
