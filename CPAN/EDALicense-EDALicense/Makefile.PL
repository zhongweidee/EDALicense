use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'EDALicense::EDALicense',
    AUTHOR              => q{Wei Zhong <fanasyiszhongwei@gmail.com	>},
    VERSION_FROM        => 'lib/EDALicense/EDALicense.pm',
    ABSTRACT_FROM       => 'lib/EDALicense/EDALicense.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'GPL')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'EDALicense-EDALicense-*' },
);
