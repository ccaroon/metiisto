package change_todos_due_date_to_datetime;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table todos modify column due_date datetime null default null;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table todos modify column due_date date null default null;
EOF
1;
