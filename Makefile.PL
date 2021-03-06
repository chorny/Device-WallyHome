use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker;

WriteMakefile1(
    NAME      => 'Device::WallyHome',
    PREREQ_PM => {
        'Data::Dumper'                 => '2.161',
        'HTTP::Headers'                => '6.11',
        'HTTP::Request'                => '6.11',
        'JSON::MaybeXS'                => '1.003008',
        'List::Util'                   => '1.46',
        'LWP::Protocol::https'         => '6.06',
        'LWP::UserAgent'               => '6.15',
        'Module::Loader'               => '0.03',
        'Moo'                          => '2.003000',
        'Moo::Role'                    => '2.000002',
        'MooX::Types::MooseLike::Base' => '0.029',
        'namespace::autoclean'         => '0.16',
    },
    TEST_REQUIRES => {
        'Test::Exception'              => '0.43',
        'Test::More'                   => '1.302067',
    },
    VERSION_FROM => 'lib/Device/WallyHome.pm',
    LICENSE => 'perl',
    MIN_PERL_VERSION => '5.010',
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url => 'git://github.com/cjhamil/Device-WallyHome.git',
                web => 'https://github.com/cjhamil/Device-WallyHome',
            },
        },
    },
);

sub WriteMakefile1 {  #Compatibility code for old versions of EU::MM. Written by Alexandr Ciornii, version 2. Added by eumm-upgrade.
    my %params=@_;
    my $eumm_version=$ExtUtils::MakeMaker::VERSION;
    $eumm_version=eval $eumm_version;
    die "EXTRA_META is deprecated" if exists $params{EXTRA_META};
    die "License not specified" if not exists $params{LICENSE};
    if ($params{AUTHOR} and ref($params{AUTHOR}) eq 'ARRAY' and $eumm_version < 6.5705) {
        $params{META_ADD}->{author}=$params{AUTHOR};
        $params{AUTHOR}=join(', ',@{$params{AUTHOR}});
    }
    if ($params{TEST_REQUIRES} and $eumm_version < 6.64) {
        $params{BUILD_REQUIRES}={ %{$params{BUILD_REQUIRES} || {}} , %{$params{TEST_REQUIRES}} };
        delete $params{TEST_REQUIRES};
    }
    if ($params{BUILD_REQUIRES} and $eumm_version < 6.5503) {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM}={ %{$params{PREREQ_PM} || {}} , %{$params{BUILD_REQUIRES}} };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES} if $eumm_version < 6.52;
    delete $params{MIN_PERL_VERSION} if $eumm_version < 6.48;
    delete $params{META_MERGE} if $eumm_version < 6.46;
    delete $params{META_ADD} if $eumm_version < 6.46;
    delete $params{LICENSE} if $eumm_version < 6.31;

    WriteMakefile(%params);
}

