package deprecate_goals;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table entries drop column goal_id;
drop table obstacles;
drop table goals;
EOF
################################################################################
use constant DOWN => <<'EOF';
EOF
################################################################################
1;
