package add_time_spent_to_entries;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table entries add column time_spent time not null default '00:00:00'
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table entries drop column time_spent;
EOF
################################################################################
1;
