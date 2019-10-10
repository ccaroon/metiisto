package create_secrets_table;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
create table secrets 
(
    id           bigint(20) unsigned NOT NULL AUTO_INCREMENT,

    category     varchar(256) NOT NULL,
    username     varchar(256) NOT NULL,
    password     varchar(256) NOT NULL,
    note         text NULL,
    created_date datetime NOT NULL,
    updated_date datetime NOT NULL,

    PRIMARY KEY (id)
) ENGINE=innodb;
EOF
################################################################################
use constant DOWN => <<'EOF';
drop table secrets;
EOF
################################################################################
1;
