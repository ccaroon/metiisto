use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'metiisto',
    AUTHOR              => q{Craig N. Caroon <youremail@example.com>},
    VERSION_FROM        => 'lib/metiisto.pm',
    ABSTRACT            => 'YOUR APPLICATION ABSTRACT',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'                 => 0,
        'YAML'                       => 0,
        'Dancer'                     => 1.3072,
        'Dancer::Plugin::Database'   => 0,
        'Class::DBI'                 => 0,
        'Class::DBI::AbstractSearch' => 0,
        'Digest::SHA1'               => 2.13,
        'Data::Page'                 => 2.02,
        'Text::Markdown'             => 1.0,
        'Template::Plugin::Markdown' => 0,
        'Mail::SendEasy'             => 1.2,
		'Crypt::Blowfish'            => 2.12,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'metiisto-*' },
);
