package rename_countdowns_target_date_to_end_date;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table countdowns change target_date start_date datetime not null;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table countdowns change start_date target_date datetime not null;
EOF
################################################################################
1;
