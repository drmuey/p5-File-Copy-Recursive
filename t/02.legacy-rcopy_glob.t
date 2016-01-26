use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use File::Temp ();
my $dir =  File::Temp->newdir();

use File::Copy::Recursive qw(rcopy_glob);
diag("Testing legacy File::Copy::Recursive::rcopy_glob() $File::Copy::Recursive::VERSION");

ok("TODO: test rcopy_glob()");