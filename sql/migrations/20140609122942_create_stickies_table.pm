package create_stickies_table;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
create table stickies 
(
    id           bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    body         text NOT NULL,
    created_date datetime NOT NULL,
    updated_date datetime NOT NULL,

    PRIMARY KEY (id)
) ENGINE=innodb;
EOF
################################################################################
use constant DOWN => <<'EOF';
drop table stickies;
EOF
################################################################################
1;
