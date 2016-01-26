use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use File::Temp ();
my $dir =  File::Temp->newdir();

use File::Copy::Recursive qw(pathrm);
diag("Testing legacy File::Copy::Recursive::pathrm() $File::Copy::Recursive::VERSION");

ok("TODO: test pathrm()");