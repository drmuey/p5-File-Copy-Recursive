package File::Copy::Recursive;

use strict;
use warnings;
use Carp qw(carp croak);
use File::Path::Tiny ();
use File::Copy ();
use Path::Iter ();
our $VERSION = 0.39;

## TODO: modern interface goes here

# ATTRs:
# make_parent 0
# overwrite_file 0
# overwrite_symlink 1
# overwrite_dir 0 == no, 1 == on top of existing stuff 2 = clean it out first; default 0
# continue_on_fail default false
# mode_fail: undef == warn, 0 == skip, 1 fail
# attr_fail: undef == warn, 0 == skip, 1 fail


# TODO: “somehow fell through to an unhandled type, please report me!” when given one does not exist (arg sanity just fails w/ detaisl in trace()

# something else or:
#   handle_warning(sub { carp(…) })
#   handle_error(sub {})
#   handle_success(sub {})
# or
#   trace_*() or event_*()
# or:
#   trace() default false, only set to array ref (?also do coderef?)
sub _trace_step {
    my ($self, $type, $call) = @_;
    return if !$self->trace;

    # TODO: if($type is not skip/good/warn/fail/?info?) { carp()  }
    my $meta = $type eq 'fail' ? { '$!' => int($!), '$@' => $@, '$^E' => $^E, '$?' => $?, trace_caller => [caller()] } : { trace_caller => [caller()] };
    ref($self->trace) eq 'CODE' ? $self->trace->([$type, $info, $meta]) : push(@{$self->trace}, [$type, $info, $meta]);
    return;
}

sub copy_file {
    my ($self, $file, $new) = @_;
    return if !$self->_basic_arg_sanity(\$file, \$new, {type => "f"});
    
    if (File::Copy::copy($file,$new)) {
        $self->_trace_step(good => "File::Copy::copy($file,$new)");
    }
    else {
        $self->_trace_step(fail => "File::Copy::copy($file,$new)");
        return;
    }

    return if !$self->_copy_mode($file, $new, {type => "f"});
    return if !$self->_copy_attributes($file, $new, {type => "f"});
    return 1;
}

sub copy_symlink {
    my ($self, $symlink, $new) = @_;
    return if !$self->_basic_arg_sanity(\$symlink, \$new, {type => "l"});
    
    my $target = readlink($symlink);
    ($target) = $target =~ m/(.*)/; # untaint since we need to work w/ what the file system allows
    # TODO: resolve target relative to new parent if !-e or nope
    
    unlink $new unless !$self->overwrite_symlink;
    return if !symlink $new, $target;
    return if !$self->_copy_mode($file, $new, {type => "l"});
    return if !$self->_copy_attributes($file, $new, {type => "l"});
    return 1;
}

sub copy_symlink_target {
    my ($self, $symlink, $new) = @_;
    return if !$self->_basic_arg_sanity(\$symlink, \$new, {type => "l"});

    my $target = readlink($symlink);
    ($target) = $target =~ m/(.*)/; # untaint since we need to work w/ what the file system allows
    # resolve target relative to current parent if !-e or nope
    
    if (-l $target) {
        return $self->copy_symlink($target, $new);
    }
    elsif (-d _) {
        return $self->copy_dir($target, $new);
    }
    elsif (-f _) {
        return $self->copy_file($target, $new);
    }
    else {
        # nope
    }
    
    return;
}

sub copy_dir {
    my ($self, $dir, $into) = @_;
    return if !$self->_basic_arg_sanity(\$dir, \$into, {type => "d"});

    my $into_real = "$into/$dirtop"; # TODO
    return if !$self->copy_dir_content($dir, $into_real);
    return if !$self->_copy_mode($file, $new, {type => "d"});
    return if !$self->_copy_attributes($file, $new, {type => "d"});
    return 1;
}

sub copy_dir_content {
    my ($self, $dir, $into) = @_;
    return if !$self->_basic_arg_sanity(\$dir, \$into, {type => "d"});

    my $iter = Path::Iter::get_iterator($into);
    while(my $next = $iter->()) {
        next if $next eq $into;

        if (-l $next) {
            $self->copy_symlink($next, $new) || or nope;
            # if ($self->copy_symlink($next, $new)) {
            #     $self->_trace_step(good => "copy_symlink($next, $new)");
            # }
            # else {
            #     if ($self->continue_on_fail) {
            #          $self->_trace_step(skip => "copy_symlink($next, $new)");
            #     }
            #     else {
            #          $self->_trace_step(fail => "copy_symlink($next, $new)");
            #          last;
            #     }
            # }
        }
        elsif (-d _) {
            $self->copy_dir($next, $new) || or nope;
        }
        elsif (-f _) {
            $self->copy_file($next, $new) || or nope;
        }
        else {
            # nope
        }
    }
    
    return 1; # ???
}

sub copy {
    my ($self, $src, $new) = @_;
    return if !$self->_basic_arg_sanity(\$src, \$new);

    if (-l $target) {
        return $self->copy_symlink($src, $new);
    }
    elsif (-d _) {
        return $self->copy_dir($src, $new);
    }
    elsif (-f _) {
        return $self->copy_file($src, $new);
    }
    else {
        croak("copy($src, $new) somehow fell through to an unhandled type, please report me!");
    }
    
    return;
}

sub move_file {
    my ($self, $file, $new) = @_;
    return $self->copy_file($file, $new) && $self->remove($file);
}

sub move_symlink {
    my ($self, $symlink, $new) = @_;
    return $self->copy_symlink($symlink, $new) && $self->remove($file);
}

sub move_symlink_target {
    my ($self, $symlink, $new) = @_;
    return $self->copy_symlink_target($symlink, $trg) && $self->remove($symlink);
}

sub move_dir {
    my ($self, $dir, $into) = @_;
    return $self->copy_dir($dir, $trg) && $self->remove($dir);
}

sub move_dir_content {
    my ($self, $dir, $into) = @_;
    return $self->copy_dir_content($dir, $trg) && $self->remove($dir);
}

sub move {
    my ($self, $src, $new) = @_;
    return if !$self->_basic_arg_sanity(\$src, \$new);

    if (-l $target) {
        return $self->move_symlink($src, $new);
    }
    elsif (-d _) {
        return $self->move_dir($src, $new);
    }
    elsif (-f _) {
        return $self->move_file($src, $new);
    }
    else {
        croak("move($src, $new) somehow fell through to an unhandled type, please report me!");
    }
    
    return;
}

sub remove {
    my ($self, $item) = @_;
    return if !$self->_basic_arg_sanity(\$item, undef, {type => "e"});
    
    if (-l $item || -f _) {
        return unlink($item);
    }
    elsif(-d _) {
        return File::Path::Tiny::rm($item);
    }
    else {
        croak("remove($item) somehow fell through to an unhandled type, please report me!");
    }
}

sub _copy_mode {
    my ($self, $src, $trg, $opts) = @_;
    
    return 1;
}

sub _copy_attributes {
    my ($self, $src, $trg, $opts) = @_;
    
    return 1;
}

sub _basic_arg_sanity {
    my ($self, $src, $trg, $opts) = @_;
    # flush op_report (TODO: better name/mechanism) unless $self->aggregate ATM

    # nope if !defined ||!length
    # Trim trailing /
    # nope if not normal l/f/d (sockets, pipes, etc)
    # nope if type is given and src is not type (e.g. f == !-l && -f)
    # nope if $new already exists unless $self->overwrite_$type();
    # nope if same/recursive
    # File::Path::Tiny::mk_parent() or nope if $self->make_parent();
    
    return 1;
}

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

L<File::Path::Tiny>

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