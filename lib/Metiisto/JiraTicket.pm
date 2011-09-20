package Metiisto::JiraTicket;
################################################################################
use strict;
use feature 'switch';

use Dancer ':syntax';
use LWP::Simple qw();
use Moose;
use XML::Simple;

use constant JIRA_URL => "http://_JIRA_HOST_/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?jqlQuery=_JIRA_QUERY_&tempMax=1000&os_username=_JIRA_USER_&os_password=_JIRA_PASS_";

use constant SUB_TASK_TYPES => {
    'Sub-task'    => 1,
    'Spec Review' => 1,
    'Bug found'   => 1
};
################################################################################
has key => (
    is  => 'rw',
    isa => 'Str',
);

has summary => (
    is  => 'rw',
    isa => 'Str',
);

has type => (
    is  => 'rw',
    isa => 'Str',
);

has status => (
    is  => 'rw',
    isa => 'Str',
);

has link => (
    is  => 'rw',
    isa => 'Str',
);

#has description => (
#    is  => 'rw',
#    isa => 'Str',
#);

has sub_tasks => (
    is      => 'rw',
    isa     => 'ArrayRef[Metiisto::JiraTicket]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        add_sub_task => 'push',
    }
);

has points => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

#has assignee => (
#    is  => 'rw',
#    isa => 'Maybe[Str]',
#);

has fix_version => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);
################################################################################
sub search
{
    my $class = shift;
    my %args = @_;
    
    my %tickets;
    my @sub_tasks;
    
    my $url = JIRA_URL;
    my $query = $args{query};

    $url =~ s/_JIRA_HOST_/session->{user}->jira_host()/e;
    $url =~ s/_JIRA_USER_/session->{user}->jira_username()/e;
    $url =~ s/_JIRA_PASS_/session->{user}->jira_password()/e;
    $url =~ s/_JIRA_QUERY_/$query/;

    my $xml = LWP::Simple::get($url);
    if ($xml)
    {
        my $data = XMLin($xml,
            KeyAttr    => [],
            NoAttr     => 1,
            ForceArray => ['item', 'fixVersion', 'subtask', 'customfield']
        );

        foreach my $item (@{$data->{channel}->{item}})
        {
            my $t = Metiisto::JiraTicket->new(
                key     => $item->{key},
                summary => $item->{summary},
                link    => $item->{link},
                status  => $item->{status},
                type    => $item->{type},
                fix_version => $item->{fixVersion}->[0],
            );

            foreach my $cf (@{$item->{customfields}->{customfield}})
            {
                if ($cf->{customfieldname} eq 'Points')
                {
                    $t->points($cf->{customfieldvalues}->{customfieldvalue});
                    last;
                }
            }

            if ($t->is_sub_task())
            {
                push @sub_tasks, {ticket => $t, parent => $item->{parent}};
            }
            else
            {
                $tickets{$t->key()} = $t;
            }
        }

        # Match sub-tasks to parent ticket.
        foreach my $st (@sub_tasks)
        {
            $tickets{$st->{parent}}->add_sub_task($st->{ticket});
        }
    }

    my @tickets = values %tickets;
    return (wantarray ? @tickets : \@tickets);    
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
    given ($this->status())
    {
        when(/Design\/Verify/) {
            $color = '#999900';
        }
        when(/Coding/) {
            $color = 'green';
        }
        when(/In Progress/) {
            $color = 'green';
        }
        when(/Hold/) {
            $color = 'red';
        }
        when(/Code Review/) {
            $color = 'blue';
        }
        when(/Ready for QA/) {
            $color = 'purple';
        }
        when(/Verified/) {
            $color = 'darkgreen';
        }
    }

    return ($color);
}
################################################################################
1;
