package Metiisto::Util::DateTimeTest;
################################################################################
use strict;

use lib "$ENV{METIISTO_HOME}/lib";

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
1;