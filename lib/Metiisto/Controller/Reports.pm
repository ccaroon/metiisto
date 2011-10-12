package Metiisto::Controller::Reports;
################################################################################
use strict;

use Dancer ':syntax';
use Text::Markdown 'markdown';

use Metiisto::Util::DateTime;
use Metiisto::Workday;

use base 'Metiisto::Controller::Base';
################################################################################
#sub list
#{
#    my $this = shift;
#
#    my $total      = 0;
#    my $conditions = {
#        list_id => undef
#    };
#    if (params->{filter_text})
#    {
#        $conditions->{title} = { 'regexp', params->{filter_text} };
#    }
#
#    my $sql_abs = SQL::Abstract->new();
#    my ($where, @binds) = $sql_abs->where($conditions);
#    $total = Metiisto::Todo->count_where($where, \@binds);
#
#    my $page = Data::Page->new();
#    $page->total_entries($total);
#    $page->entries_per_page(TODOS_PER_PAGE);
#    $page->current_page(params->{page} || 1);
#
#    my @todos = Metiisto::Todo->search_where(
#        $conditions,
#        {
#            limit_dialect => 'LimitOffset',
#            limit    => TODOS_PER_PAGE,
#            offset  => $page->first() - 1,
#            order_by => 'completed, completed_on desc, priority',
#        }
#    );
#
#    my $out = template 'todos/list', {
#        todos => \@todos,
#        pagination => {
#            current_page  => $page->current_page(),
#            first_page    => $page->first_page(),
#            last_page     => $page->last_page(),
#            previous_page => $page->previous_page(),
#            next_page     => $page->next_page(),
#        }
#    };
#
#    return ($out);
#}
################################################################################
sub display_report
{
    my $this = shift;
    my %args = @_;

    my $days = Metiisto::Workday->this_week();
    
    my $out = template "/reports/$args{name}",
    {
        work_days => $days,
        entries => {
            monday => [],
            tuesday => [],
            wednesday => [],
            thursday => [],
            friday => [],
        },
    },
    {layout => undef};

    return (markdown($out));
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
     get "/reports/:name" => sub {
        my $c = $class->new();
        my $out = $c->display_report(name => params->{name});
        return ($out);
    };

    $class->SUPER::declare_routes();
}
################################################################################
1;
