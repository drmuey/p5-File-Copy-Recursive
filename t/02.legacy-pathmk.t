use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use File::Temp ();
my $dir =  File::Temp->newdir();

use File::Copy::Recursive qw(pathmk);
diag("Testing legacy File::Copy::Recursive::pathmk() $File::Copy::Recursive::VERSION");

ok("TODO: test pathmk()");