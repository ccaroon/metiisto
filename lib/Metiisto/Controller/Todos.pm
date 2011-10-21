package Metiisto::Controller::Todos;
################################################################################
use strict;

use Data::Page;
use Dancer ':syntax';
use SQL::Abstract;

use Metiisto::Util::DateTime;

use constant TODOS_PER_PAGE => 15;

use base 'Metiisto::Controller::Base';

use Metiisto::Todo;
################################################################################
sub list
{
    my $this = shift;

    my $total      = 0;
    my $conditions = {
        list_id => undef
    };
    if (params->{filter_text})
    {
        $conditions->{title} = { 'regexp', params->{filter_text} };
    }

    my $sql_abs = SQL::Abstract->new();
    my ($where, @binds) = $sql_abs->where($conditions);
    $total = Metiisto::Todo->count_where($where, \@binds);

    my $page = Data::Page->new();
    $page->total_entries($total);
    $page->entries_per_page(TODOS_PER_PAGE);
    $page->current_page(params->{page} || 1);

    my @todos = Metiisto::Todo->search_where(
        $conditions,
        {
            limit_dialect => 'LimitOffset',
            limit    => TODOS_PER_PAGE,
            offset  => $page->first() - 1,
            order_by => 'completed, completed_date desc, priority',
        }
    );

    my $out = template 'todos/list', {
        todos => \@todos,
        pagination => {
            current_page  => $page->current_page(),
            first_page    => $page->first_page(),
            last_page     => $page->last_page(),
            previous_page => $page->previous_page(),
            next_page     => $page->next_page(),
        }
    };

    return ($out);
}
################################################################################
sub new_record
{
    my $this = shift;

    my $todo = { priority => 1 };
    my $out = template 'todos/new_edit', {
        todo => $todo,
    };

    return ($out);
}
################################################################################
sub create
{
    my $this = shift;

    my $data = {};
    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^todo\.(.*)$/;
        my $attr = $1;
        $data->{$attr} = params->{$p};
    }
    $data->{due_date}     = undef unless $data->{due_date};
    $data->{created_date} = Metiisto::Util::DateTime->now()->format_db();

    my $todo = Metiisto::Todo->insert($data);
    die "Error creating Todo" unless $todo;

    my $out = redirect "/todos/".$todo->id();

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;

    my $todo = Metiisto::Todo->retrieve($args{id});
    my $out = template 'todos/show', { todo => $todo };

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my $todo = Metiisto::Todo->retrieve($args{id});

    my $out = template 'todos/new_edit', {
        todo => $todo,
    };

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;

    my $todo = Metiisto::Todo->retrieve(id => $args{id});

    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^todo\.(.*)$/;
        my $attr = $1;
        $todo->$attr(params->{$p});
    }
    if ($todo->completed() and !$todo->completed_date())
    {
        $todo->completed_date(Metiisto::Util::DateTime->now());
    }
    my $cnt = $todo->update();
    die "Error saving Todo($args{id})" unless $cnt;

    my $out = redirect "/todos/$args{id}";

    return ($out);
}
################################################################################
sub mark_complete
{
    my $this = shift;
    my %args = @_;

    my $todo = Metiisto::Todo->retrieve(id => $args{id});
    $todo->completed_date(Metiisto::Util::DateTime->now());
    $todo->completed(1);
    $todo->update();

    return (redirect request->referer);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $todo = Metiisto::Todo->retrieve(id => $args{id});
    $todo->delete();
    
    my $url = '/todos';
    $url .= "?filter_text=".params->{filter_text} if params->{filter_text};

    my $out = redirect $url;

    return ($out);
}
################################################################################
1;
