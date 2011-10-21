package normalize_date_field_names;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
alter table countdowns drop column created_at;
alter table countdowns drop column updated_at;

alter table goals drop column created_on;
alter table goals drop column updated_on;
alter table goals change completed_on completed_date datetime DEFAULT NULL;

alter table notes change created_on created_date datetime NOT NULL;
alter table notes change updated_on updated_date datetime NOT NULL;
alter table notes change deleted_on deleted_date datetime DEFAULT NULL;

alter table obstacles drop column created_at;
alter table obstacles drop column updated_at;

alter table todos drop column created_on;
alter table todos change completed_on completed_date datetime DEFAULT NULL;
alter table todos change due_on due_date date DEFAULT NULL;
EOF
################################################################################
use constant DOWN => <<'EOF';
EOF
################################################################################
1;
