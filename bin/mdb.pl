#!/usr/bin/env perl
use strict;

use lib "$ENV{METIISTO_HOME}/sql/migrations";

use Date::Format;
use File::Slurp;
use Getopt::Long;

# *MUST* come before 'use Dancer::*' so that Dancer gets the correct environment
BEGIN
{
    my $env;
    GetOptions ("env=s" => \$env);
    $env ||= 'development';
    
    $ENV{METIISTO_ENV} = $env;
    $ENV{DANCER_ENVIRONMENT} = $ENV{METIISTO_ENV};
}
use Dancer ':script';
use Dancer::Plugin::Database;

use constant MIGRATE_NONE  => 'None';
use constant MIGRATE_UP    => 'Up';
use constant MIGRATE_DOWN  => 'Down';
use constant MIGRATION_DIR => "$ENV{METIISTO_HOME}/sql/migrations";
################################################################################
my $cmd = shift || '';

die "$0: Dancer Environment does not match Metiisto Environment."
    unless config->{environment} eq $ENV{METIISTO_ENV};

print STDERR "Using Metiisto '$ENV{METIISTO_ENV}' Environment.\n";
print STDERR "-----------------------------------------\n";

if ($cmd and main->can($cmd))
{
    main->$cmd(@ARGV);
}
else
{
    warn "Unknown command: '$cmd'.\n" if $cmd;
    print STDERR "Usage: $0 [--env env] backup|restore|shell|migrate|create_migration|dump_schema\n";
}
################################################################################
sub backup
{
    my $this = shift;
    
    my $db = config->{plugins}->{Database};

    my $date_stamp = time2str("%Y-%m-%d", time);
    my $out_file = "$db->{database}-$date_stamp.sql";
    my $backup_cmd = "mysqldump -u$db->{username} -p$db->{password} $db->{database} > ~/backups/$out_file";
    print STDERR "Backing up $db->{database} to: $out_file\n";

    system($backup_cmd);
}
################################################################################
sub restore
{
    my $this = shift;
    my $backup_file = shift;

    my $db = config->{plugins}->{Database};
    print STDERR "Restoring '$backup_file' to $db->{database}\n";
    exec("mysql -h$db->{host} -u$db->{username} $db->{database} -p$db->{password} < $backup_file");
}
################################################################################
sub shell
{
    my $this = shift;

    my $db = config->{plugins}->{Database};
    exec("mysql -h$db->{host} -u$db->{username} $db->{database} -p$db->{password}");
}
################################################################################
sub init_migrations
{
    my $class = shift;

    my $dbh = database();

    my $create_table_sql = <<'EOF';
CREATE TABLE `schema_migrations`
(
    `version` bigint(20) unsigned NOT NULL DEFAULT '0',
    `applied_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
    UNIQUE KEY `uk_version` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
EOF

    $dbh->do('DROP TABLE IF EXISTS `schema_migrations`;');
    $dbh->do($create_table_sql);
    
    print STDERR "Database has been initialized for migrations.\n";
}
################################################################################
sub migrate
{
    my $class = shift;
    my $to_version = shift || 99999999999999;

    my $dbh = database();

    my @migrations = grep {/^\d{14}_.*\.pm$/} read_dir(MIGRATION_DIR);
    
    my $cols = $dbh->selectcol_arrayref('select * from schema_migrations order by version');
    my @applied_migs = @$cols;

    foreach my $mig (sort @migrations)
    {
        $mig =~ /^(\d{14})_(.*)\.pm/;
        my $version   = $1;
        my $mig_class = $2;

        my $applied = (grep /$version/, @applied_migs) ? 1 : 0;

        my $direction = MIGRATE_NONE;
        if ($applied)
        {
            if ($version > $to_version)
            {
                $direction = MIGRATE_DOWN;
            }
        }
        else
        {
            if ($version <= $to_version)
            {
                $direction = MIGRATE_UP;
            }
        }

        next if $direction eq MIGRATE_NONE;
        
        eval { require $mig; };
        print STDERR "Error requiring '$mig' [$@]. Skipping.\n" and next if $@;
        print STDERR "$direction => $version - $mig_class...\n";

        my $sql = $direction eq MIGRATE_UP
            ? $mig_class->up($dbh)
            : $mig_class->down($dbh);

        $sql =~ s/\n//g;
        my @statements = split /;/, $sql;
        eval
        {
            map { $dbh->do($_) } @statements;
        };
        if ($@)
        {
            warn "Error applying migration $version - $mig_class: $@";
            next;
        }
        else
        {
            $direction eq MIGRATE_UP
                ? $dbh->do("insert into schema_migrations values ($version, now())")
                : $dbh->do("delete from schema_migrations where version='$version'");
        }
    }
}
################################################################################
sub dump_schema
{
    my $class = shift;
    my $schema_file = 'schema.sql';

    # HEADER
    my $schema = <<EOF;
/*!40014 SET \@OLD_UNIQUE_CHECKS=\@\@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET \@OLD_FOREIGN_KEY_CHECKS=\@\@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- -----------------------------------------------------------------------------

EOF

    # BODY == Create table statements
    my $dbh = database();
    my $stmt = $dbh->prepare("show tables");
    $stmt->execute();
    while ( my $row = $stmt->fetchrow_arrayref() )
    {
        my $cs = $dbh->prepare("show create table $row->[0]");
        $cs->execute();
        my $info = $cs->fetchrow_arrayref();
        my $sql  = $info->[1];
        $cs->finish();

        $sql =~ s/\) ENGINE=(\w*) .*/) ENGINE=$1/m;
        $sql .= ';';

        $schema .= <<EOF;
-- $row->[0]
$sql

EOF
    }
    $stmt->finish();

    # FOOTER
    $schema .= <<EOF;
-- -----------------------------------------------------------------------------

/*!40014 SET FOREIGN_KEY_CHECKS=\@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=\@OLD_UNIQUE_CHECKS */;

EOF

    write_file( $schema_file, $schema );
    
    print STDERR "'$ENV{METIISTO_ENV}' database schema dumped to '$schema_file'\n";
}
################################################################################
sub create_migration
{
    my $class = shift;
    my $name = shift or die "Create Migration Error: Please specify a name.";

    $name =~ s/[^A-Za-z0-9]/_/g;
    my $version = time2str("%Y%m%d%H%M%S", time);
    
    my $mig_template =<<EOT;
package $name;
################################################################################
use strict;

use lib "\$ENV{METIISTO_HOME}/lib";
use base 'Metiisto::Util::DBMigration';
################################################################################
use constant UP => <<'EOF';
EOF
################################################################################
use constant DOWN => <<'EOF';
EOF
################################################################################
#sub up
#{
#    my (\$class, \$dbh) = \@_;
#}
################################################################################
#sub down
#{
#    my (\$class, \$dbh) = \@_;
#}
################################################################################
1;
EOT
    
    my $filename = MIGRATION_DIR."/${version}_$name.pm";
    write_file($filename, $mig_template);
    
    print STDERR "Wrote '$filename'\n";
}
################################################################################
sub help
{
    my $class = shift;

    print <<EOF;
Usage: $0 <cmd> [--env env]

By default all commands will use the 'development' database. In order to specify
a different database/environment you can use the '--env' parameter.

Environments:
    * development
    * test
    * production

Commands:
    * backup: Create a backup of your metiisto database. Includes schema and data.
        - Example: mdb.pl backup
    * restore: Restores a backup created with the 'backup' command.
        - Args: backup_file_name --> *Required*
        - Example: mdb.pl restore metiisto_prod-2012-03-02.sql
    * shell: Drops you into a mysql shell using your metiisto database.
        - Example: mdb.pl shell --env test
    * migrate: Runs the necessary database migrations to get database schema to
               the specified version.
        - Args: version --> *Optional. Defaults to latest version.*
        - Examples:
            1. mdb.pl migrate
            2. md.pl migrate 20111110142300
    * create_migration: Create a new database migration.
        - Args: name/description
        - Example: mdb.pl create_migration 'add age field to person table'
    * dump_schema: Writes the database schema out to a file called 'schema.sql'
        - Example: mdb.pl dump_schema
EOF
}
################################################################################
