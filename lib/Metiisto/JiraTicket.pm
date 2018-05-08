package Metiisto::JiraTicket;
################################################################################
use strict;

use Moo;
use Scalar::Util qw(looks_like_number);

use constant SUB_TASK_TYPES => {
    'Sub-task'    => 1,
    'Spec Review' => 1,
    'Bug found'   => 1
};

################################################################################
has key => (
    is  => 'rw',
);

has parent_key => (
    is => 'rw'
);

has summary => (
    is  => 'rw',
);

has type => (
    is  => 'rw',
);

has status => (
    is  => 'rw',
);

has link => (
    is  => 'rw',
);

has sub_tasks => (
    is  => 'rw',
    isa => sub {
        my $st = shift;
        die "'sub_tasks' must be an ArrayRef." unless ref($st) eq 'ARRAY';
    },
    default => sub {
        my $this = shift;
        $this->sub_tasks([]);
    },
);

has points => (
    is  => 'rw',
    isa => sub {
        my $p = shift;
        die "'points' must be a number." unless (!defined($p) or looks_like_number($p))
    },
);

has fix_version => (
    is  => 'rw',
);

has is_flagged => (
    is  => 'rw',
);
################################################################################
sub add_sub_task
{
    my $this     = shift;
    my $sub_task = shift;

    push @{$this->sub_tasks()}, $sub_task;
}
################################################################################
sub is_sub_task
{
    my $this = shift;
    return (exists SUB_TASK_TYPES->{$this->type()} ? 1 : 0);
}
################################################################################
sub color
{
    my $this = shift;

    my $color = 'black';
    if ($this->status() =~ /In Progress/) {
        $color = 'blue';
    }
    elsif ($this->status() =~ /In Testing/) {
        $color = '#bbbb00';
    }
    elsif ($this->status() =~ /Hold/) {
        $color = 'red';
    }
    elsif ($this->status() =~ /CI\/Build Deployment /) {
        $color = 'purple';
    }
    elsif ($this->status() =~ /Ready for Release/) {
        $color = 'green';
    }

    return ($color);
}
################################################################################
sub TO_JSON
{
    my $this = shift;

    my @sub_tasks = map {$_->TO_JSON()} @{$this->sub_tasks()};

    return ({
        key        => $this->key(),
        parent_key => $this->parent_key(),
        summary    => $this->summary(),
        type       => $this->type(),
        points     => $this->points(),
        link       => $this->link(),
        status     => $this->status(),
        sub_tasks  => \@sub_tasks,
        color      => $this->color(),
        is_flagged => $this->is_flagged()
    });
}
################################################################################
1;
