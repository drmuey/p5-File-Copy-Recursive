use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'File::Copy::Recursive',
    license           => 'artistic2',
    dist_author       => 'Daniel Muey <http://drmuey.com/cpan_contact.pl>',
    dist_version_from => 'lib/File/Copy/Recursive.pm',
    requires          => {
        'Test::More' => 0,
        'Test::Exception' => 0,
        'File::Temp' => 0,
        
        # Legacy only
        'File::Copy' => 0,
        'File::Spec' => 0,
    },

    # delete_share => '.', # NYI https://rt.cpan.org/Ticket/Display.html?id=92863
    # install_share => 'share',
    add_to_cleanup => ['File-Copy-Recursive-*'],
);

$builder->create_build_script();

# package MY;
# use File::ShareDir::Install 0.07 qw(postamble);
# File::ShareDir::Install::delete_share('.');
