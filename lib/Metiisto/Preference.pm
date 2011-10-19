package Metiisto::Preference;
################################################################################
use strict;

use Metiisto::User;

use base 'Metiisto::Base';

use constant SMTP_AUTHS => ['none','plain','login','cram_MD5'];

use constant THEMES => [
    'cupertino',
    'overcast',
    'pepper-grinder',
    'redmond',
    'seafoam',
    'smoothness',
    'start',
    'trontastic',
    'ui-lightness',
    'vader'
];
################################################################################
__PACKAGE__->table('preferences');
__PACKAGE__->columns(All => qw/
    id name value user_id
/);
__PACKAGE__->has_a(user_id => 'Metiisto::User');
################################################################################
1;
