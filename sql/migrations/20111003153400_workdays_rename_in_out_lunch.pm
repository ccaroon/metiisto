package workdays_rename_in_out_lunch;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table work_days change `in` time_in time not null;
alter table work_days change `out` time_out time not null;
alter table work_days change `lunch` time_lunch time not null;
EOF
################################################################################
use constant DOWN => <<'EOF';
alter table work_days change `time_in` `in` time not null;
alter table work_days change `time_out` `out` time not null;
alter table work_days change `time_lunch` `lunch` time not null;
EOF
################################################################################
1;
