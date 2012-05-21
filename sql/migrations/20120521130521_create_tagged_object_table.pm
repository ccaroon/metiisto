package create_tagged_object_table;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
CREATE TABLE tagged_object
(
    id        bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    tag_id    bigint(20) unsigned NOT NULL,
    obj_class varchar(64) NOT NULL,
    obj_id    bigint(20) unsigned NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT fk_tags_assoc_tag_id FOREIGN KEY (tag_id) REFERENCES tags (id),
    UNIQUE KEY uk_tag_obj (tag_id,obj_class,obj_id)
) ENGINE=InnoDB;
EOF
################################################################################
use constant DOWN => <<'EOF';
drop table tagged_object;
EOF
################################################################################
1;
