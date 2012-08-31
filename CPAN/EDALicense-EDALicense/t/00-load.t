#!perl -T

use Test::More tests => 4;

BEGIN {
    use_ok( 'EDALicense::EDALicense' ) || print "Bail out!\n";
    use_ok( 'EDALicense::EDALicenseFeature' ) || print "Bail out!\n";
    use_ok( 'ActiveLicense' ) || print "Bail out!\n";
    use_ok( 'ActiveLicenseFeature' ) || print "Bail out!\n";
}

diag( "Testing EDALicense::EDALicense $EDALicense::EDALicense::VERSION, Perl $], $^X" );
