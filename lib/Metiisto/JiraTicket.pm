package Metiisto::JiraTicket;
################################################################################
use strict;

use Dancer2 appname => 'metiisto';
use LWP::UserAgent;
use HTTP::Request;
use Moo;
use Scalar::Util qw(looks_like_number);
use XML::Simple;
$XML::Simple::PREFERRED_PARSER='XML::LibXML::SAX::Parser';

use constant JIRA_URL => "https://_JIRA_HOST_/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?jqlQuery=_JIRA_QUERY_&tempMax=1000&os_username=_JIRA_USER_&os_password=_JIRA_PASS_";

# No user/pass in URL. Use Basic Auth. instead...see below
#use constant JIRA_URL => "http://_JIRA_HOST_/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?jqlQuery=_JIRA_QUERY_";

# customfield_10020 == Points
#use constant FIELDS => '&field=key&field=summary&field=link&field=status&field=type&field=fixVersions&field=parent&field=customfield_10020';

use constant SUB_TASK_TYPES => {
    'Sub-task'    => 1,
    'Spec Review' => 1,
    'Bug found'   => 1
};

use constant DEFAULT_TIMEOUT => 30;

my $UA = LWP::UserAgent->new(
    timeout => DEFAULT_TIMEOUT,
    ssl_opts => {
        verify_hostname => 1,
        SSL_ca_file     => "$ENV{METIISTO_HOME}/public/certs/atlassian.net"
    }
);
################################################################################
has key => (
    is  => 'rw',
);

has summary => (
    is  => 'rw',
);

has type => (
    is  => 'rw',
);

has state => (
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
################################################################################
sub search
{
    my $class = shift;
    my %args = @_;
    my %tickets;
    my @sub_tasks;
    
    my $url = JIRA_URL;
    my $query = $args{query};

    $url =~ s/_JIRA_HOST_/session('user')->preferences('jira_host')/e;
    $url =~ s/_JIRA_USER_/session('user')->preferences('jira_username')/e;
    $url =~ s/_JIRA_PASS_/session('user')->preferences('jira_password')/e;
    $url =~ s/_JIRA_QUERY_/$query/;
    #$url .= FIELDS;
    my $req = HTTP::Request->new( GET => $url );
    
    # Use Basic Auth. instead of user/pass in URL
    #$req->headers()->authorization_basic(
    #    session('user')->preferences('jira_username'),
    #    session('user')->preferences('jira_password')
    #);

    my $timeout = $args{timeout} || DEFAULT_TIMEOUT;
    $UA->timeout($timeout);
    my $response = $UA->request($req);

    my $xml = ($response->is_success()) ? $response->content() : undef;
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
                key         => $item->{key},
                summary     => $item->{summary},
                link        => $item->{link},
                state       => $item->{state},
                type        => $item->{type},
                fix_version => $item->{fixVersion}->[0],
                points      => 0.0,
            );

            foreach my $cf (@{$item->{customfields}->{customfield}})
            {
                if ($cf->{customfieldname} eq 'Story Points')
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
        foreach my $st (sort {$a->{ticket}->key() cmp $b->{ticket}->key()} @sub_tasks)
        {
            if ($tickets{$st->{parent}})
            {
                $tickets{$st->{parent}}->add_sub_task($st->{ticket});
            }
            # Parent ticket is not part of the loaded ticket list. Add to top-level
            # ticket list instead of to parent as sub-task.
            else
            {
                $tickets{$st->{ticket}->key()} = $st->{ticket};
            }
        }
    }
    else
    {
        print STDERR "WARN - Unable to complete Jira Search Request: "
            . $response->message() ."\n";
    }

    my @tickets = map {$tickets{$_}} (sort {$a cmp $b} keys %tickets);
    return (wantarray ? @tickets : \@tickets);    
}
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
    if ($this->state() =~ /In Progress/) {
        $color = 'blue';
    }
    elsif ($this->state() =~ /In Testing/) {
        $color = '#bbbb00';
    }
    elsif ($this->state() =~ /Hold/) {
        $color = 'red';
    }
    elsif ($this->state() =~ /CI\/Build Deployment /) {
        $color = 'purple';
    }
    elsif ($this->state() =~ /Ready for Release/) {
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
        key       => $this->key(),
        summary   => $this->summary(),
        type      => $this->type(),
        points    => $this->points(),
        link      => $this->link(),
        state    => $this->state(),
        sub_tasks => \@sub_tasks,
        color     => $this->color()
    });
}
################################################################################
1;
