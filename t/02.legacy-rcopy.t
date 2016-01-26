use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use File::Temp ();
my $dir =  File::Temp->newdir();

use File::Copy::Recursive qw(rcopy);
diag("Testing legacy File::Copy::Recursive::rcopy() $File::Copy::Recursive::VERSION");

ok("TODO: test rcopy()");