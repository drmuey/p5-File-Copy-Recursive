use strict;
use warnings;

use Test::More tests => 57;
use Test::Exception;

use File::Copy::Recursive;
diag("Testing File::Copy::Recursive $File::Copy::Recursive::VERSION");

ok( !exists $INC{"File/Copy/Recursive/Legacy.pm"}, "legacy code not loaded prior to call to legacy function" );

no strict "refs";
for my $lfunc (qw(fcopy rcopy dircopy fmove rmove dirmove pathmk pathrm pathempty pathrmdir rcopy_glob rmove_glob)) {
    ok( !defined &{ 'File::Copy::Recursive::' . $lfunc }, "$lfunc() not defined prior to call" );
}

for my $lvar (qw(MaxDepth KeepMode CPRFComp CopyLink PFSCheck RemvBase NoFtlPth ForcePth CopyLoop RMTrgFil RMTrgDir CondCopy BdTrgWrn SkipFlop DirPerms)) {
    ok( !defined ${ 'File::Copy::Recursive::' . $lvar }, "\$$lvar not defined prior to call" );
}

for my $lfunc (qw(fcopy rcopy dircopy fmove rmove dirmove pathmk pathrm pathempty pathrmdir rcopy_glob rmove_glob)) {
    local $SIG{__WARN__} = sub { };
    "File::Copy::Recursive::$lfunc"->( '', '' );
    ok( defined &{ 'File::Copy::Recursive::' . $lfunc }, "$lfunc() defined after calls to legacy function" );
}

for my $lvar (qw(MaxDepth KeepMode CPRFComp CopyLink PFSCheck RemvBase NoFtlPth ForcePth CopyLoop RMTrgFil RMTrgDir CondCopy BdTrgWrn SkipFlop DirPerms)) {
    ok( defined ${ 'File::Copy::Recursive::' . $lvar }, "\$$lvar defined after calls to legacy function" );
}

ok( exists $INC{"File/Copy/Recursive/Legacy.pm"}, "legacy code loaded after calls to legacy function" );

my $line = __LINE__ + 2;
throws_ok {
    File::Copy::Recursive::derp();
}
qr/Undefined subroutine \&File::Copy::Recursive::derp called at .* line $line\./, "calling unkown function errors out (and is from caller perspective)";
