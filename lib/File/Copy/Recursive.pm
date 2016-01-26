package File::Copy::Recursive;

use strict;
use warnings;
use Carp qw(carp croak);
our $VERSION = 0.39;

## TODO: modern interface goes here

LEGACY_SUPPORT: {
    our $AUTOLOAD;

    my %legacy_funcs = ( fcopy => 1, rcopy => 1, dircopy => 1, fmove => 1, rmove => 1, dirmove => 1, pathmk => 1, pathrm => 1, pathempty => 1, pathrmdir => 1, rcopy_glob => 1, rmove_glob => 1, );

    sub import {
        my ( $self, @lfuncs ) = @_;
        my $caller = caller();
        for my $legacy_func (@lfuncs) {
            if ( exists $legacy_funcs{$legacy_func} ) {
                require File::Copy::Recursive::Legacy;
                no strict 'refs';  ## no critic
                *{$caller . "::$legacy_func"} = \&{ "File::Copy::Recursive::$legacy_func" };
            }
            else {
                die qq{"$legacy_func" is not exported by the File::Copy::Recursive module\n};
            }
        }
    }

    sub AUTOLOAD {
        my $legacy_func = $AUTOLOAD;
        $legacy_func =~ s/.*:://;
        if ( exists $legacy_funcs{$legacy_func} ) {
            require File::Copy::Recursive::Legacy;
            no strict 'refs';  ## no critic
            goto &{$AUTOLOAD};
        }
        else {
            croak "Undefined subroutine &$AUTOLOAD called";
        }
    }
}

1;

__END__

=head1 NAME

File::Copy::Recursive - Recursively copy/move files, directories, and symlinks.

=head1 VERSION

This document describes File::Copy::Recursive version 0.39

=head2 LEGACY INTERFACE

The legacy interface still works with no changes to existing code.

The legacy interface documentation can be found at L<File::Copy::Recursive::Legacy>.

=head1 SYNOPSIS

    use File::Copy::Recursive;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

File::Copy::Recursive requires no configuration files or environment variables.

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.

=head1 BUGS AND FEATURES

Please report any bugs or feature requests (and a pull request for bonus points)
 through the issue tracker at L<https://github.com/drmuey/p5-File-Copy-Recursive/issues>.

=head1 AUTHOR

Daniel Muey  C<< <http://drmuey.com/cpan_contact.pl> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2016, Daniel Muey C<< <http://drmuey.com/cpan_contact.pl> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.