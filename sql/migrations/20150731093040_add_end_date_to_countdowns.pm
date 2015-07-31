package add_end_date_to_countdowns;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table countdowns add end_date datetime not null after start_date;
update countdowns set end_date = start_date;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table countdowns drop end_date;
EOF
################################################################################
1;
