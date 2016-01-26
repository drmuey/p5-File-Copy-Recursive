use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use File::Temp ();
my $dir =  File::Temp->newdir();

use File::Copy::Recursive qw(rmove_glob);
diag("Testing legacy File::Copy::Recursive::rmove_glob() $File::Copy::Recursive::VERSION");

ok("TODO: test rmove_glob()");