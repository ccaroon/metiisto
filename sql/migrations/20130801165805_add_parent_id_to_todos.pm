package add_parent_id_to_todos;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table todos add column parent_id bigint unsigned NULL default NULL;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table todos drop column parent_id;
EOF
################################################################################
1;
