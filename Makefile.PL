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
        'Test::More'                 => 0.98,
        'YAML'                       => 0.77,
        'Dancer'                     => 1.3080,
        'Dancer::Plugin::Database'   => 1.50,
        'Class::DBI'                 => '3.0.17',
        'Class::DBI::AbstractSearch' => 0.07,
        'Digest::SHA1'               => 2.13,
        'Data::Page'                 => 2.02,
        'Text::Markdown'             => 1.0,
        'Template::Plugin::Markdown' => 0.02,
        'Net::SSLeay'                => 1.42,
        'IO::Socket::SSL'            => 1.49,
        'Authen::SASL'               => 2.15,
        'Net::SMTP::SSL'             => 1.01,
        'Crypt::Blowfish'            => 2.12,
        'Crypt::CBC'                 => 2.30,
        'Starman'                    => 0.2014,
        'Moose'                      => 2.0401,
        'File::Slurp'                => 9999.19,
        'XML::Simple'                => 2.18,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'metiisto-*' },
);
