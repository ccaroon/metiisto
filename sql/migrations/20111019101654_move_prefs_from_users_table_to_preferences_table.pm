package move_prefs_from_users_table_to_preferences_table;
################################################################################
use strict;
use feature 'switch';

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
sub up
{
    my ($class, $dbh) = @_;
    
    # NOTE: Assumes only 1 user
    my $stmt = $dbh->prepare('select * from users');
    $stmt->execute();
    my $user_info = $stmt->fetchrow_hashref();
    $stmt->finish();
    
    my $user_id = $user_info->{id};
    foreach my $name (sort keys %$user_info)
    {
        next if $name =~ /^(id|name|user_name|password|email|style_calendar|email_type)$/;
        
        given ($name)
        {
            when ('style_main') {
                $dbh->do("insert into preferences (user_id,name,value) values ($user_id, 'theme', '$user_info->{$name}')");
            }
            default {
                $dbh->do("insert into preferences (user_id,name,value) values ($user_id, '$name', '$user_info->{$name}')");
            }
        }
    }
    
    return <<EOF;
alter table users drop column jira_host;
alter table users drop column jira_username;
alter table users drop column jira_password;
alter table users drop column jira_filter_id;
alter table users drop column email_type;
alter table users drop column smtp_host;
alter table users drop column smtp_user;
alter table users drop column smtp_pass;
alter table users drop column smtp_auth;
alter table users drop column style_main;
alter table users drop column style_calendar;
EOF
}
################################################################################
sub down
{
    my ($class, $dbh) = @_;
}
################################################################################
1;
