package add_location_to_users;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
    alter table users add location varchar(64) null default null;
EOF
################################################################################
use constant DOWN => <<'EOF';
    alter table users drop column location;
EOF
################################################################################
1;
