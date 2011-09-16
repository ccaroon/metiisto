package Metiisto::User;
################################################################################
use strict;

use Digest::SHA1 qw(sha1_hex);

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('users');
__PACKAGE__->columns(All => qw/
    id name user_name password jira_host jira_username jira_password
    jira_filter_id email_type smtp_host smtp_user smtp_pass smtp_auth style_main
    style_calendar email
/);
################################################################################
sub authenticate
{
    my $class = shift;
    my %args = @_;
    
    my $user = $class->retrieve(user_name => $args{user_name});
    if ($user)
    {
        my $expected_passwd = sha1_hex($args{password});
        unless ($user->password() eq $expected_passwd)
        {
            $user = undef;
        }
    }
    
    return ($user);
}
################################################################################
1;
