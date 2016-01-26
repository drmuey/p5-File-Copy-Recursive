use strict;
use warnings;

use Test::More tests => 57;
use Test::Exception;

use File::Copy::Recursive;
diag("Testing File::Copy::Recursive $File::Copy::Recursive::VERSION");

ok( !exists $INC{"File/Copy/Recursive/Legacy.pm"}, "legacy code not loaded prior to call to import of legacy function" );

no strict "refs";
for my $lvar (qw(MaxDepth KeepMode CPRFComp CopyLink PFSCheck RemvBase NoFtlPth ForcePth CopyLoop RMTrgFil RMTrgDir CondCopy BdTrgWrn SkipFlop DirPerms)) {
    ok( !defined ${ 'File::Copy::Recursive::' . $lvar }, "\$$lvar not defined prior to call" );
    ${ 'File::Copy::Recursive::' . $lvar } = $$;
}

for my $lfunc (qw(fcopy rcopy dircopy fmove rmove dirmove pathmk pathrm pathempty pathrmdir rcopy_glob rmove_glob)) {
    ok( !defined &{$lfunc}, "$lfunc() not defined prior to import of legacy function" );
}

File::Copy::Recursive->import(qw(fcopy rcopy dircopy fmove rmove dirmove pathmk pathrm pathempty pathrmdir rcopy_glob rmove_glob));

for my $lfunc (qw(fcopy rcopy dircopy fmove rmove dirmove pathmk pathrm pathempty pathrmdir rcopy_glob rmove_glob)) {
    ok( defined &{$lfunc}, "$lfunc() defined after import of legacy function" );
}

ok( exists $INC{"File/Copy/Recursive/Legacy.pm"}, "legacy code loaded after call to import of legacy function" );
for my $lvar (qw(MaxDepth KeepMode CPRFComp CopyLink PFSCheck RemvBase NoFtlPth ForcePth CopyLoop RMTrgFil RMTrgDir CondCopy BdTrgWrn SkipFlop DirPerms)) {
    is( ${ 'File::Copy::Recursive::' . $lvar }, $$, "\$$lvar value prior to import call was left in tact" );
}

throws_ok {
    File::Copy::Recursive->import('derp');
}
qr/"derp" is not exported by the File::Copy::Recursive module\n/, "importing unkown function errors out";
