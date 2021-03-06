package Metiisto::Util::DateTimeTest;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";

use Date::Format;
use Test::More;
use base 'Test::Class';

use constant TESTED_CLASS => 'Metiisto::Util::DateTime';
################################################################################
sub startup : Test(startup => 1)
{
    use_ok TESTED_CLASS;
}
################################################################################
sub test_parse : Test(3)
{
    my $this = shift;
    
    my $dt = TESTED_CLASS->parse('Feb 19, 1971');
    
    is ref $dt, TESTED_CLASS, 'return value should be a DateTime instance';
    is $dt->epoch(), 35787600, 'should parse date to correct epoch';
    
    # Test Date format 'MM/DD/YYYY'
    $dt = TESTED_CLASS->parse('02/19/1971');
    is $dt->epoch(), 35787600, 'MM/DD/YYYY should parse date to correct epoch';
}
################################################################################
sub test_undef_dt: Test(4)
{
    my $this = shift;
    
    my $dt = TESTED_CLASS->new();
    is $dt->epoch(), undef, "new() with no params should create an 'empty' instance";
    is $dt->format("%c"), undef, "formatting an 'empty' instance should return undef";

    $dt = TESTED_CLASS->parse(undef);
    is $dt->epoch(), undef, "parse(undef) should return an 'empty' instance";
    is $dt->format("%c"), undef, "formatting an 'empty' instance should return undef";
}
################################################################################
sub test_day_of_the_week : Test(7)
{
    my $this = shift;

    foreach my $day (qw|sunday monday tuesday wednesday thursday friday saturday|) {
        my $date = TESTED_CLASS->day_of_the_week(day => $day);
        my $day_name = time2str("%A", $date->epoch());
        is $day_name, (ucfirst $day), "Should indicate that the day is '$day'";
    }
}
################################################################################
sub test_sunday : Test(2)
{
    my $this = shift;
    
    my $date = TESTED_CLASS->sunday();
    
    my $week_day = time2str("%w", time);
    my $sunday = time - (86_400 * ($week_day-0));
    is $date->format_db(date_only => 1), time2str("%Y-%m-%d", $sunday),
        "Should find this Sunday if not given 'for_date'";

    $date = TESTED_CLASS->sunday(for_date => "2013-09-25");
    is $date->format_db(date_only => 1), '2013-09-22',
        "Should find correct sunday for a given date.";
}
################################################################################
sub test_monday : Test(2)
{
    my $this = shift;
    
    my $date = TESTED_CLASS->monday();
    my $week_day = time2str("%w", time);
    my $monday = time - (86_400 * ($week_day-1));
    is $date->format_db(date_only => 1), time2str("%Y-%m-%d", $monday),
        "Should find this monday if not given 'for_date'";

    $date = TESTED_CLASS->monday(for_date => "2011-10-06");
    is $date->format_db(date_only => 1), '2011-10-03',
        "Should find correct monday for a given date.";
}
################################################################################
1;
