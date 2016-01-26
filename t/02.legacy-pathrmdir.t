use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use File::Temp ();
my $dir =  File::Temp->newdir();

use File::Copy::Recursive qw(pathrmdir);
diag("Testing legacy File::Copy::Recursive::pathrmdir() $File::Copy::Recursive::VERSION");

ok("TODO: test pathrmdir()");