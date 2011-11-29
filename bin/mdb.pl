#!/bin/env perl
use strict;

use lib "$ENV{METIISTO_HOME}/sql/migrations";

use Date::Format;
use File::Slurp;
use Data::Dumper;

# *MUST* come before 'use Dancer::*' so that Dancer gets the correct environment
BEGIN
{
    $ENV{METIISTO_ENV} ||= 'development';
    $ENV{DANCER_ENVIRONMENT} = $ENV{METIISTO_ENV};
}
use Dancer ':script';
use Dancer::Plugin::Database;

use constant MIGRATION_DIR => "$ENV{METIISTO_HOME}/sql/migrations";
################################################################################
my $cmd = shift;

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
    warn "Unknown command: '$cmd'.\n";
    print STDERR "Usage: $0 backup|restore|shell|init_migrations|migrate|create_migration\n";
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
# TODO: migrate currently only supports UP.
################################################################################
sub migrate
{
    my $class = shift;

    my $dbh = database();

    my @migrations = grep {/^\d{14}_.*\.pm$/} read_dir(MIGRATION_DIR);
    
    my $cols = $dbh->selectcol_arrayref('select * from schema_migrations order by version');
    my @applied_migs = @$cols;

    foreach my $mig (sort @migrations)
    {
        $mig =~ /^(\d{14})_(.*)\.pm/;
        my $version = $1;
        my $class   = $2;
        # Skip if migration already applied to DB
        next if grep /$version/, @applied_migs;

        eval { require $mig; };
        print STDERR "Error requiring '$mig' [$@]. Skipping.\n" and next if $@;

        print STDERR "Applying $version - $class...\n";
        my $up = $class->up($dbh);
        $up =~ s/\n//g;
        my @statements = split /;/, $up;
        eval
        {
            map { $dbh->do($_) } @statements;
        };
        if ($@)
        {
            warn "Error applying migration $version - $class: $@";
            next;
        }
        else
        {
            $dbh->do("insert into schema_migrations values ($version, now())");
        }
    }
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

