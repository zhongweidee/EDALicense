#!perl -T

use Test::More tests => 4;
use Moose;

BEGIN {
    push @INC,"/home/weizhong/Project/EDALicense/CPAN/FLEXlm-EDALicense/lib/";
    use_ok( 'FLEXlm::EDALicense' ) || print "Bail out!\n";
    use_ok( 'FLEXlm::EDALicenseFeature' ) || print "Bail out!\n";
    use_ok( 'FLEXlm::ActiveEDALicense' ) || print "Bail out!\n";
    use_ok( 'FLEXlm::ActiveEDALicenseFeature' ) || print "Bail out!\n";
}

diag( "Testing FLEXlm::EDALicense $FLEXlm::EDALicense::VERSION, Perl $], $^X" );
