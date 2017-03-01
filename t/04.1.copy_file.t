use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

use File::Temp ();
my $dir =  File::Temp->newdir();

use File::Copy::Recursive;
diag("Testing FCR->copy_file() $File::Copy::Recursive::VERSION");

my $fcr = File::Copy::Recursive->new;

ok("TODO: test copy_file()");

