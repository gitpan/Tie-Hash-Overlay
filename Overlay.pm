# Copyright (C) 1997 Ashley Winters <jql@accessone.com>. All rights reserved.
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.

package Tie::Hash::Overlay;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);

use Carp;
require Exporter;

@ISA = qw(Exporter);
@EXPORT_OK = qw(&overlay);

$VERSION = '0.02';

sub new {
    my $class = shift;
    my $hash = {};
    tie(%{$hash}, $class);
    overlay($hash, @_) if @_;

    return $hash;
}

sub overlay {
    my $self = shift;
    my $obj = tied %{$self};

    unless($obj) { carp "Untied object passed to overlay()"; return }
    if(ref $_[0] eq "ARRAY") {
	foreach(@{$_[0]}) { push @{$$obj{'hashes'}}, $_ }
    } elsif(ref $_[0] eq "HASH") { push @{$$obj{'hashes'}}, $_[0] }
    else {
	carp "Argument 2 of overlay() must be a HASH or ARRAY reference";
	return;
    }
    if(@_ > 1) {
	if(ref $_[1] eq "HASH") { $$obj{'remainder'} = $_[1] }
	else {
	    carp "Argument 3 of overlay() must be a HASH reference";
	    return;
	}
    }

    return $self;
}


sub TIEHASH {
    my $class = shift;
    my $self =
	bless { 'hashes' => [], 'remainder' => {}, 'count' => 0 }, $class;

    return $self;
}

sub CLEAR {
    my $self = shift;

    foreach(@{$$self{'hashes'}}, $$self{'remainder'}) { %{$_} = () }
}

sub FETCH {
    my $self = shift;
    my $key = shift;

    foreach(@{$$self{'hashes'}}, $$self{'remainder'}) {
	return $$_{$key} if exists $$_{$key};
    }

    return undef;
}

sub STORE {
    my $self  = shift;
    my($key, $value) = @_;

    foreach(@{$$self{'hashes'}}, $$self{'remainder'}) {
	if(exists $$_{$key}) { $$_{$key} = $value; return }
    }
    $$self{'remainder'}{$key} = $value;
}

sub DELETE {
    my $self = shift;
    my $key = shift;

    foreach(@{$$self{'hashes'}}, $$self{'remainder'}) {
	if(exists $$_{$key}) { delete $$_{$key} }
    }
}

sub EXISTS {
    my $self = shift;
    my $key = shift;

    foreach(@{$$self{'hashes'}}, $$self{'remainder'}) {
	return 1 if exists $$_{$key};
    }

    return 0;
}

sub FIRSTKEY {
    my $self = shift;
    my $key;

    foreach(@{$$self{'hashes'}}, $$self{'remainder'}) {
	$key = scalar keys %{$_};       # This resets the key counter
	$key = each %{$_};
	return $key if $key;
	$$self{'count'}++;
    }

    $$self{'count'} = 0;
    return undef;
}

sub NEXTKEY {
    my $self = shift;
    my $key;
    my $count = 0;
    my @ignore;

    foreach(@{$$self{'hashes'}}, $$self{'remainder'}) {
	if($count++ < $$self{'count'}) { push @ignore, $_; next }
	$key = each %{$_};
	return $key if $key &&
	    ((map { redo if exists $$_{$key}; 1 } @ignore) || 1); # always true
	$$self{'count'}++;
    }

    $$self{'count'} = 0;
    return undef;
}

sub DESTROY {}

1;
__END__

=head1 NAME

Tie::Hash::Overlay - Perl module for overlaying hashes

=head1 SYNOPSIS

  use Tie::Hash::Overlay;
  $a = new Tie::Hash::Overlay($hashlist [, $remainder]);

  use Tie::Hash::Overlay qw(&overlay);
  $a = new Tie::Hash::Overlay($hashlist [, $remainder]);
  overlay($a, $hashlist [, $remainder]);

=head1 DESCRIPTION

This module provides a standardized method for interfacing multiple hashes
through one variable using tie().

The new() function runs tie() transparently on a newly created hash reference,
and if given arguments, runs overlay() with whatever arguments are given to it.
You are returned a baby hash reference which you can bless into your class, or
do any number of cool things with.

The overlay() function is the most important function. It must be explicitly
imported into your namespace by adding C<qw(&overlay)> to the arguments of
use() if you want to avoid calling it as Tie::Hash::Overlay::overlay(). 

The first argument must be a reference to the hash being modified. overlay()
cannot be a member-function of the hash reference because the reference must
be able to be blessed into another class, because that is the main purpose
of this whole package.

If the second parameter is a hash reference, it will be pushed to the
end of an internal list of overlayed hashes. If the second parameter is
an array reference, then each element of the list will be pushed onto
the list of overlayed hashes. Note that the first hashes overlayed will
have higher priority than the hashes overlayed afterwards.

The optional third argument is a 'catchall' hash reference. If a hash
key is accessed which none of the overlayed hashes think exists, a
fall-through hash stores that value to make sure it isn't lost. If
you want control over that fall-through hash, just pass a reference to
the hash you want the unrecognized keys to access. This hash is guaranteed
to always be searched last, and can have elements in it when you pass it
to overlay(). This can be useful when you want to capture certain accesses
to a dbm hash. Just tie() your own hash that captures whatever elements
you like, and run C<*dbm = new Tie::Hash::Overlay($mine, \%dbm);> or
something equally effective. You probably get the idea.

B<Tie::Hash::Overlay> does I<not> copy the hashes passed to it. Everything
is kept completely intact on purpose, in order to allow the programmer the
most flexibility. Perhaps you have DBM hash that you want to capture all
of the accesses to a certain element? Or maybe you have a diabolical plan to
take over the Earth and need to overlay tied hashes in Perl for it to work?
It's reasons like that which caused me not to fiddle with what is passed to
overlay().

=head1 EXAMPLES

Go ahead and consider me a show-off, but I think a little demonstration is
in order.

	use Tie::Hash::Overlay qw(&overlay);  # import &overlay manually

	$hashes = [ { a => 1, b => 200 }, { foo => bar, blurfle => z } ];
	*a = new Tie::Hash::Overlay($hashes);
	$b = new Tie::Hash::Overlay($hashes);

	print "$a{b}\n";		# This prints 200
	$$b{what} = 'is that?';
	print "what $$b{what}\n";	# This prints "what is that?"
	$x = join ", ", sort keys %a;
	print "$x\n";		# This prints "a, b, blurfle, foo, what"
	$a{b}++;
	print "$$b{b}\n";	# This prints 201? Interesting.
	overlay($b, { "good guys" => "never win" });
	print "$a{good guys}\n";	# Print "never win"

Getting the idea? Basically they're identical to any other hash, except
they're extremely different. Makes sense to me.

=head1 BUGS

Bugs? If there was a bug, do you think it would exist long enough to be put
in here? Having to manually import overlay() is a I<good> thing!

Anyways, the mere fact that this thing has a version-number of 0.02 nearly
qualifies as a bug in and of itself.

Oh, and blame any other bugs on tie(). :)

If you actually I<find> a bug, or have a suggestion, go ahead and e-mail me.
See the B<AUTHOR> section for my contact address.

=head1 AUTHOR

Ashley Winters <jql@accessone.com>

=head1 SEE ALSO

perl(1).

=cut
