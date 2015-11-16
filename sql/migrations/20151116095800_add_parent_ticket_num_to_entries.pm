package add_parent_ticket_num_to_entries;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table entries add column parent_ticket varchar(255) null default null after ticket_num;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table entries drop column parent_ticket;
EOF
################################################################################
1;
