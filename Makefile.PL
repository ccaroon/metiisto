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
        'Authen::SASL'               => 2.16,
        'Class::DBI'                 => '3.0.17',
        'Class::DBI::AbstractSearch' => 0.07,
        'Crypt::Blowfish'            => 2.14,
        'Crypt::CBC'                 => 2.33,
        'DBD::mysql'                 => 4.032,
        'DBI'                        => 1.634,
        'Dancer2'                    => 0.16300,
        'Dancer2::Plugin::Database'  => 2.13,
        'Data::Page'                 => 2.02,
        'Digest::SHA1'               => 2.13,
        'File::Slurp'                => 9999.19,
        'IO::Socket::SSL'            => 2.020,
        'JSON'                       => 2.90,
        'JSON::XS'                   => 3.01,
        'LWP::UserAgent'             => 6.13,
        'Lingua::EN::Inflect'        => 1.899,
        'Moo'                        => 2.000002,
        'Net::SMTP::SSL'             => 1.03,
        'Net::SSLeay'                => 1.72,
        'Plack'                      => 1.0037,
        'Starman'                    => 0.4014,
        'Template'                   => 2.26,
        'Template::Plugin::Markdown' => 0.02,
        'Text::Markdown'             => 1.000031,
        'XML::LibXML'                => 2.0122,
        'XML::Simple'                => 2.20,
        'YAML'                       => 1.15,
    },
    BUILD_REQUIRES => {
        'Test::Class' => 0.50,
        'Test::More'  => 1.001014
    },
    test  => { TESTS    => 't/models.t' },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'metiisto-*' },
);
