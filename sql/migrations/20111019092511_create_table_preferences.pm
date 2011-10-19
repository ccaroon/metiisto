package create_table_preferences;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
create table preferences
(
    id      bigint unsigned NOT NULL AUTO_INCREMENT,
    user_id int             NOT NULL default 0,
    name    varchar(255)    NOT NULL default '',
    value   varchar(255)    NOT NULL default '',
    
    PRIMARY KEY (id),
    UNIQUE KEY uk_prefs_name (name),
    CONSTRAINT fk_prefs_user_id FOREIGN KEY (user_id) REFERENCES users(id)

) ENGINE=InnoDB;
EOF
################################################################################
use constant DOWN => <<'EOF';
drop table preferences;
EOF
################################################################################
1;
