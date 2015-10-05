package Metiisto::Preference;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use Metiisto::User;

use base 'Metiisto::Base';

use constant THEMES => [
    'black-tie',
    'blitzer',
    'cupertino',
    'dark-hive',
    'dot-luv',
    'eggplant',
    'excite-bike',
    'flick',
    'hot-sneaks',
    'humanity',
    'le-frog',
    'mint-choc',
    'overcast',
    'pepper-grinder',
    'redmond',
    'smoothness',
    'south-street',
    'start',
    'sunny',
    'swanky-purse',
    'trontastic',
    'ui-darkness',
    'ui-lightness',
    'vader'
];

use constant DEFAULT_PREFS => [
    {theme                 => 'humanity'},
    {track_time            => 'false'},

    {jira_host                      => 'www.yourjirahost.com'},
    {jira_username                  => 'Jira Username Here'},
    {jira_password                  => 'Jira Password Here'},
    {jira_tickets_filter_id         => '1'},
    {jira_current_release_filter_id => '2'},
    {jira_project_id                => '3'},
    {jira_my_tickets_cache_ttl      => 5 * 60},      # 5 minutes
    {jira_current_release_cache_ttl => 1 * (60*60)}, # 1 hour

    {report_recipients     => 'name@email.com,other_name@emai.com'},
    {encryption_passphrase => 'CURRENTLY NOT USED'},

    {smtp_host             => 'smtp.google.com'},
    {smtp_port             => '142'},
    {smtp_user             => 'SMTP Username'},
    {smtp_pass             => 'SMTP Password'},
];
################################################################################
__PACKAGE__->table('preferences');
__PACKAGE__->columns(All => qw/
    id name value user_id
/);
__PACKAGE__->has_a(user_id => 'Metiisto::User');
################################################################################
sub init_defaults_for_user
{
    my $class = shift;
    my %args = @_;

    my $user = $args{user};

    foreach my $pref (@{DEFAULT_PREFS()})
    {
        my ($name, $value) = each %$pref;
        $class->insert({
            user_id => $user->id,
            name => $name,
            value => $value
        });
    }
}
################################################################################
1;
