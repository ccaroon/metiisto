package add_repeat_duration_to_todos;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table todos add column repeat_duration varchar(16) null default null;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table todos drop column repeat_duration;
EOF
################################################################################
1;
