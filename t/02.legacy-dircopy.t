use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use File::Temp ();
my $dir =  File::Temp->newdir();

use File::Copy::Recursive qw(dircopy);
diag("Testing legacy File::Copy::Recursive::dircopy() $File::Copy::Recursive::VERSION");

ok("TODO: test dircopy()");