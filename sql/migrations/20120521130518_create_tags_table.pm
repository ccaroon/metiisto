package create_tags_table;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
CREATE TABLE tags
(
    id   bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL DEFAULT '',

    PRIMARY KEY (id),
    UNIQUE KEY uk_tags_name(name)
) ENGINE=InnoDB;
EOF
################################################################################
use constant DOWN => <<'EOF';
drop table tags;
EOF
################################################################################
1;
