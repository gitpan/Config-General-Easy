use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Config::General::Easy',
    license             => 'perl',
    dist_author         => 'Jacquelin Charbonnel <jacquelin.charbonnel at math.cnrs.fr>',
    dist_version_from   => 'lib/Config/General/Easy.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Config-General-Easy-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
