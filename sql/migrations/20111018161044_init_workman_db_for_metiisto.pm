package init_workman_db_for_metiisto;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
update users set style_main='seafoam';
EOF
################################################################################
use constant DOWN => <<'EOF';
EOF
################################################################################
1;
