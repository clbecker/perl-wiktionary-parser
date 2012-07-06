use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Wiktionary::Parser',
    AUTHOR              => q{Chris Becker <clbecker@gmail.com>},
    VERSION_FROM        => 'lib/Wiktionary/Parser.pm',
    ABSTRACT_FROM       => 'lib/Wiktionary/Parser.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
	    'XML::Generic' => 0,
	    'LWP'          => 0,
	    'JSON::XS'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Wiktionary-Parser-*' },
);
