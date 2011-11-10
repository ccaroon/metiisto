package SMTP_delete_auth_type_and_add_port;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
delete from preferences where name = 'smtp_auth';
insert into preferences (user_id,name,value) values (1,'smtp_port','465');
EOF
################################################################################
use constant DOWN => <<'EOF';
delete from preferences where name = 'smtp_port';
insert into preferences (user_id,name,value) values (1,'smtp_auth','none');
EOF
################################################################################
1;
