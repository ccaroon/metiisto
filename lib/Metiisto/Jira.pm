package Metiisto::Jira;
################################################################################
use strict;

use LWP::UserAgent;
use HTTP::Request;
use Moo;
use XML::Simple;
$XML::Simple::PREFERRED_PARSER='XML::LibXML::SAX::Parser';

use Metiisto::JiraTicket;

use constant DEFAULT_TIMEOUT => 30;
use constant JIRA_URL => "https://_JIRA_HOST_/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?jqlQuery=_JIRA_QUERY_&tempMax=1000&os_username=_JIRA_USER_&os_password=_JIRA_PASS_";
################################################################################
has name => (
    is => 'rw'
);

has host => (
    is  => 'rw',
);

has username => (
    is => 'rw'
);

has password => (
    is  => 'rw',
);

has filter => (
    is  => 'rw',
);
################################################################################
sub BUILD
{
    my $this = shift;

    my $url = JIRA_URL;
    $url =~ s/_JIRA_HOST_/$this->host()/e;
    $url =~ s/_JIRA_USER_/$this->username()/e;
    $url =~ s/_JIRA_PASS_/$this->password()/e;

    $this->{_url} = $url;

    $this->{_UA} = LWP::UserAgent->new(
        timeout => DEFAULT_TIMEOUT,
        ssl_opts => {
            verify_hostname => 1,
            SSL_ca_file     => "$ENV{METIISTO_HOME}/public/certs/atlassian.net"
        }
    );
}
################################################################################
sub search
{
    my $this = shift;
    my %args = @_;

    my %tickets;
    my @sub_tasks;

    my $url = $this->{_url};
    my $query = $args{query};
    $url =~ s/_JIRA_QUERY_/$query/;

    my $req = HTTP::Request->new( GET => $url );

    my $timeout = $args{timeout} || DEFAULT_TIMEOUT;
    $this->{_UA}->timeout($timeout);
    my $response = $this->{_UA}->request($req);

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
                parent_key  => $item->{parent},
                summary     => $item->{summary},
                link        => $item->{link},
                status      => $item->{status},
                type        => $item->{type},
                fix_version => $item->{fixVersion}->[0],
                points      => 0.0,
            );

            foreach my $cf (@{$item->{customfields}->{customfield}})
            {
                # customfield_10002
                if ($cf->{customfieldname} eq 'Flagged')
                {
                    $t->is_flagged(1);
                }
                elsif ($cf->{customfieldname} eq 'Story Points')
                {
                    $t->points($cf->{customfieldvalues}->{customfieldvalue});
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
1;
