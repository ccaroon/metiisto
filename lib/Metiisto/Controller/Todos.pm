package Metiisto::Controller::Todos;
################################################################################
use strict;

use Dancer ':syntax';
use SQL::Abstract;

use Metiisto::List;
use Metiisto::Todo;
use Metiisto::Util::DateTime;

use base 'Metiisto::Controller::Base';

__PACKAGE__->setup_list_handler(
    filter_fields      => ['title'],
    order_by           => 'completed, completed_date desc, priority',
    default_conditions => { list_id => undef, parent_id => undef },
);
################################################################################
sub new_record
{
    my $this = shift;
    my %args = @_;
    
    my @lists = Metiisto::List->retrieve_all();
    @lists = sort {lc $a->name() cmp lc $b->name() } @lists;

    my $list = Metiisto::List->retrieve(params->{list_id});
    my $todo = {
        priority  => 1,
        list      => $list,
        completed => 0,
    };
    my $avail_tags = Metiisto::Tag->names();

    my $out = $this->SUPER::new_record(
        %args,
        item          => $todo,
        template_vars => {
            lists      => \@lists,
            avail_tags => $avail_tags,
        }
    );

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my @lists = Metiisto::List->retrieve_all();
    @lists = sort {lc $a->name() cmp lc $b->name() } @lists;
    my $avail_tags = Metiisto::Tag->names();
    
    my $out = $this->SUPER::edit(
        %args,
        template_vars => {
            lists       => \@lists,
            avail_tags  => $avail_tags,
        }
    );

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;

    my $out = $this->SUPER::update(%args,
        pre_obj_update => sub {
            my $todo = shift;
            if ($todo->completed() and !$todo->completed_date())
            {
                $todo->completed_date(Metiisto::Util::DateTime->now());
            }
        }
    );

    return ($out);
}
################################################################################
sub mark_complete
{
    my $this = shift;
    my %args = @_;

    my $todo = Metiisto::Todo->retrieve(id => $args{id});
    $todo->mark_complete();

    return (redirect request->referer);
}
################################################################################
sub _munge_params
{
    my $this = shift;
    my %args = @_;

    my $params = $args{params};

    my $count = delete $params->{'todo.repeat_duration.count'};
    my $units = delete $params->{'todo.repeat_duration.units'};

    $params->{'todo.repeat_duration'} = undef;
    unless ($units eq 'none')
    {
        $params->{'todo.repeat_duration'} = $count . ' ' . $units;
    }

    return ($params);
}
################################################################################
1;
