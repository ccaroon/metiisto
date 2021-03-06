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
        'DBD::mysql'                 => 4.050,
        'DBI'                        => 1.631,
        'Dancer'                     => 1.3134,
        'Dancer::Plugin::Database'   => 2.10,
        'Data::Page'                 => 2.02,
        'Digest::SHA1'               => 2.13,
        'File::Slurp'                => 9999.19,
        'IO::Socket::SSL'            => 1.77,
        'JSON'                       => 2.90,
        'JSON::XS'                   => 3.01,
        'LWP::Protocol::https'       => 6.07,
        'LWP::Simple'                => 6.00,
        'LWP::UserAgent'             => 6.43,
        'Lingua::EN::Inflect'        => 1.895,
        'Moo'                        => 1.004002,
        'Net::SMTP::SSL'             => 1.01,
        'Net::SSLeay'                => 1.49,
        'Plack'                      => 1.0034,
        'Starman'                    => 0.4011,
        'Template'                   => 2.26,
        'Template::Plugin::Markdown' => 0.02,
        'Text::Markdown'             => 1.000031,
        'URI::Encode'                => "1.1.1",
        'XML::LibXML'                => 2.0008,
        'XML::Simple'                => 2.20,
        'YAML'                       => 1.15,
    },
    BUILD_REQUIRES => {
        'Test::Class' => 0.41,
        'Test::More'  => 1.001003
    },
    test  => { TESTS    => 't/models.t' },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'metiisto-*' },
);
