package add_auto_adjust_flag_to_countdowns;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table countdowns add column auto_adjust tinyint not null default 1;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table coundowns drop column auto_adjust;
EOF
1;
