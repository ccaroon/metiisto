package add_real_time_to_countdowns;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table countdowns add column is_real_time tinyint(1) not null default 0;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table countdowns drop column is_real_time;
EOF
################################################################################
1;
