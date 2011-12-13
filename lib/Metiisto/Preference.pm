package Metiisto::Preference;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use Metiisto::User;

use base 'Metiisto::Base';

use constant THEMES => [
    'cupertino',
    'lime-sherbert',
    'pepper-grinder',
    'redmond',
    'seafoam',
    'smoothness',
    'ui-lightness',
];
################################################################################
__PACKAGE__->table('preferences');
__PACKAGE__->columns(All => qw/
    id name value user_id
/);
__PACKAGE__->has_a(user_id => 'Metiisto::User');
################################################################################
1;
