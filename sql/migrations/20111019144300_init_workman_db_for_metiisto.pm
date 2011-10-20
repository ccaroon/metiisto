package init_workman_db_for_metiisto;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table work_days change `in` time_in time not null;
alter table work_days change `out` time_out time not null;
alter table work_days change `lunch` time_lunch time not null;

update preferences set value='seafoam' where name='theme';
insert into preferences (user_id, name, value) values (1, 'report_recipients', 'ccaroon@mcclatchyinteractive.com,craig-web@caroon.org');

drop table user_stories;
drop table user_story_categories;
drop table scenarios;

EOF
################################################################################
use constant DOWN => <<'EOF';
alter table work_days change `time_in` `in` time not null;
alter table work_days change `time_out` `out` time not null;
alter table work_days change `time_lunch` `lunch` time not null;
EOF
################################################################################
1;
