use utf8;

=encoding utf-8

=head1 Number::Prefix

Converts a floating point number to a string using the SI prefixes I<k>, I<M>,
I<G> and I<m>, I<u>, I<n> etc. The Binary Prefixes I<Ki>, I<Mi>, I<Gi>, etc.
are also supported.

=head1 SYNOPSIS

    my $np = Number::Prefix->new();

    # returns ('3.434 n');
    my $string = $np->string(0.000_000_003_434_23);

    # returns (134, 'k')
    my ($number, $prefix) = $np->numberPrefix(134_000);

    # returns ('3.4342 u');
    my $string2 = $np->string(0.000_003_434_23, significantDigits => 5);

    # returns () as the number is too large
    my ($number2, $prefix2) = $np->numberPrefix(1e100);

    # returns "10 E99" - string uses "engineering notation" for out-of-bound
    # numbers.
    my $string3 = $np->string(1e100);

One can also use IEC Binary Prefixes

    my $np = Number::Prefix->new(binaryPrefix=>1);
    # returns "2.00 Ki"
    my $string4 = $np->string(2048, significantDigits=>3);

Or one can force a 1024 factor and still use SI Prefixes. But one should use SI
or IEC Binary Prefixes, not fudge with this factor 1024!

    my $np = Number::Prefix->new(factor=>1024);

You may want start with the L</BACKGROUND> chapter describing SI and Binary
Prefixes

=head1 CONSTRUCTOR: Number::Prefix-E<gt>new(%options)

Create a new Number Prefix object. Recognized options are:

=over 4

=item binaryPrefix => 1

The default is to use the SI prefixes I<k M G T P E Z Y> and I<m u n p f a z y>.

With I<binaryPrefix =E<gt> 1>, use the Binary Prefixes I<Ki Mi Gi Ti Pi Ei Zi
Yi>. Also, use a factor of 1024 unless factor is also given, in which case it
takes precedence.

B<Note>: There are no binary prefixes defined for values less than one. One
might need that when describing rates: I<"The file grows with one byte every
other second, or 500 ??B/s">. There is no prefix to use instead of the ??. This
module's C<Number::Prefix-E<gt>new(binaryPrefix =E<gt> 1)-E<gt>string(0.5)>
returns I<"500 E-3">. But hey, the SI version: I<"500 mB/s"> looks/sounds silly
too.

=item factor => 1000 or factor => 1024

Use the SI prefixes, but use a factor of 1024 instead. No reason to specify
factor=>1000, since that is the default.

=back

=head1 METHODS

=head2 $self-E<gt>string($number, %options)

C<$self-E<gt>string($number)> is what you'll probably use most (only?). It accepts the same options as C<$self-E<gt>formatNumber($number)>

C<formatNumber>'s I<width> option is also honored, except that here it makes
sure the width of the entire string remains constant. ( It handles that prefix
strings can be of varying length, e.g. I<k> and I<E99>. )

=head2 $self-E<gt>numberPrefix($number)

This will take the number and return two elements, the number and prefix. The
number $n will be 0 < $n <= 1000 for factor == 100 and 0 < $n <= 1024  for
factor == 1024.

If there is no appropriate prefix for the number, it will return 0 elements.

It will croak if not given a number.

B<Note:> The SI prefix for 1e-6 is really I<µ> the greek character I<mu>. To
avoid problems with non-ASCII character sets, we use I<u> for 1e-6 instead, a
relatively common substitution. Patches that handle UTF-8 and other character
sets properly are welcome. ( I always seem to get bitten by that in perl. )

=head2 $self-E<gt>numberPrefixOrEng($number)

Similar to C<$self-E<gt>numberPrefix($number)>, but if C<numberPrefix> returns 0
elements, this will return I<E$n>" as the prefix instead, where $n is a
multiplum of 3. This is sometimes called I<Engineering notation>.

=head2 $self-E<gt>formatNumber($number, %options)

This formats the number from C<numberPrefix> or C<numberPrefixOrEng> "nicely"
according to these options:

=over 4

=item maxSignificantDigits => $n

Here, $n is a positive integer. Will maximum show $n significant digits. So if
$number is 3.3453459845 and $n is 4 (the default), C<formatNumber> returns
"3.345".

Trailing 0s after the comma are not shown, so 20.0000 is shown as "20" and
20.1000 is shown as "20.1".

If the part of the number to the left of the comma is too big to fit into
C<maxSignificantDigits>, C<maxSignificantDigits> will be ignored.

=item significantDigits => $n

Like C<maxSignificantDigits => $n>, except that trailing zeros are not removed.
So with C<significantDigits => 4>, 20 is shown as "20.00".

=item width => $n

Puts spaces in front of the string to ensure that it has a constant width.
Handy for ensuring constant width if printing to the console or a text file.

If other options cause the string to be longer than $n, (e.g. you use width < 3
or width < 4 for factor == 1024, or you have $significantDigits =>
$highNumber), width will not concatenate it. So beware of width < 3 (or 4).

=back

=head1 BACKGROUND

=head2 SI and SI Prefixes

In the International System of Units (SI)
(L<http://en.wikipedia.org/wiki/SI_prefix>), a quantity is specified as
"I<<number>> I<<prefix>>I<<unit>>", e.g. "2 kg".

This module is about converting a floating point number to I<<number>> and
I<<prefix>>. ( You're on your own with the I<<unit>>, but that should be easy
as concatenating a string to the result from this module.)

=head2 Binary Prefixes

In reality in computers, one often wants to use multiples of 1024 instead of 1000 for storage space.

Historically, people have just used the same SI prefixes also for storage, e.g. 1 kB, 2 MB, 4 TB etc. But that is ambiguous: Is 1 kB 1000 or 1024 bytes?

For that reason, Binary Prefixes
(L<http://en.wikipedia.org/wiki/Binary_prefix>) have been introduced by the
International Electrotechnical Commission (IEC).  E.g. 1 KiB (pronounced "one
kibibyte") means 1024 bytes.

If one uses them, clarity is regained, as 1 kB then means 1000 bytes, where 1
KiB means 1024 bytes.

Many (me, you?) aren't used to hearing I<kibibyte>. I<"What the heck is
that?">. I'm reading I<KiB> more and more, though.

Consider it deprecated to use SI prefixes when you mean powers of 1024.

=head2 When to use 1024

Powers of 1024 (using Binary Prefixes or otherwise) are for storage only. E.g.
bandwidth is in powers of 1000! 1 kB/s means I<1000 bytes per second>!

RAM sizes are shown using powers of 1024 for sure. Hard disk sizes are usually sold describing the size in powers of 1000. (It makes them look bigger!)

At least Windows and Linux both show a 1024 byte file to have a size of I<"1,0
KB"> and I<"1.0K"> respectively. (The Linux one comes from C</bin/ls -lh>. One
can use C</bin/ls -lh --si> to force a factor 1000) Note how they both use the
upper-case I<K>, which isn't standardized by either SI or IEC.

So: Powers of 1024 for RAM and file sizes, and powers of 1000 for everything
else.

=head2 About units: I<B> is for bytes and I<b> is for bits

Please, lets standardize on this, now we're at it here. There is great
confusion here too: I<B> for bytes and I<b> for bits

=head1 RELATED MODULES

I'm not aware of any that does what this module does. But these are related:

=over 4

=item Number::FormatEng

Does the SI thing 'right', but doesn't do Binary Prefixes or any kind of 1024.
I needed that too.

=item Number::Format

It apparently only lets one use powers of 1024, but then lets one choose
whether to 'display' that as SI or Binary prefixes. No support for less than
one (e.g. milli) either.

=item Number::Bytes::Human

Another bytes-only module.

=back

=head1 COPYRIGHT

Copyright (c) 2011 Peter Valdemar Mørch <peter@morch.com>

All right reserved. This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

  Peter Valdemar Mørch <peter@morch.com>

=cut

package Number::Prefix;

use 5.008;
our $VERSION = 0.1;
use strict;

use Scalar::Util qw(looks_like_number);
use Carp;

my %prefixes = (
    SI => {
        lessThanOne    => [qw( m u n p f a z y )],
        greaterThanOne => [qw( k M G T P E Z Y )],
    },
    IEC => {
        lessThanOne    => [],
        greaterThanOne => [qw( Ki Mi Gi Ti Pi Ei Zi Yi )],
    }
);

sub new {
    my ($class, %options) = @_;
    # We could check the options hash here
    my $self = { %options };
    bless $self, $class;
    return $self;
}

sub _getFactor {
    my ($self) = @_;
    if ($self->{factor}) {
        return $self->{factor};
    }
    return $self->{binaryPrefix} ? 1024 : 1000;
}

sub numberPrefix {
    my ($self, $number) = @_;
    defined $number && looks_like_number($number)
        or croak "numberPrefix needs a number";
    my $sign;

    if ($number == 0) {
        return ( 0, '' );
    }
    if ($number < 0) {
        $number = - $number;
        $sign = '-';
    }

    my $prefixSystem = $prefixes{ $self->{binaryPrefix} ? 'IEC' : 'SI' };

    # Factor stays constant: 1000 or 1024
    my $factor = $self->_getFactor();
    # goes 0, 1, 2 ...
    my $index = 0;
    # goes 1, 1_000, 1_000_000 ... (for factor 1000. Or 1,1_024,1_024*1_024...)
    my $multiplier = 1;

    my $prefixArray = $prefixSystem->{
        ($number >= 1) ? 'greaterThanOne' : 'lessThanOne'
    };

    while (exists $prefixArray->[$index]) {
        if ($number >= 1) {
            if ($number < $multiplier * $factor) {
                return ( ( $sign ? -$number : $number ) / ( $multiplier),
                         $index == 0 ? '' : $prefixArray->[$index - 1] );
            }
        } else {
            if ($number > $multiplier / $factor) {
                return ( ( $sign ? -$number : $number ) /
                            ( $multiplier / $factor),
                         $prefixArray->[$index] );
            }
        }
        $index++;
        if ($number >= 1) {
            $multiplier *= $factor;
        } else {
            $multiplier /= $factor;
        }
    }
    # We've run out of entries in $prefixArray. Don't return anything
    return;
}

sub numberPrefixOrEng {
    my ($self, $number) = @_;
    # Default to numberPrefix if possible
    my ($calcNumber, $prefix) = $self->numberPrefix($number);
    if (defined $calcNumber && defined $prefix) {
        return ($calcNumber, $prefix);
    }

    # Nope, we'll need engineering notation
    my $exponent = int(log($number) / log(10));
    $exponent = $exponent - ( $exponent % 3 );

    $calcNumber = $number / ( 10**$exponent );

    # Don't return ( 0.3, 0 ), but ( 300, -3 )
    if ($calcNumber < 1) {
        $calcNumber *= 1000;
        $exponent -= 3;
    }
    return ( $calcNumber, "E$exponent" );
}

# Do we even need this? At this point in time (2011-09-22) it works though...
# sub set {
#     my ($self, %settings) = @_;
#     while (my ($k, $v) = each %settings) {
#         $self->{$k} = $v;
#     }
# }

sub _padMissingSpaces {
    my ($str, $width) = @_;
    my $missingSpaces = $width - length($str);
    if ($missingSpaces > 0) {
        return ( ' ' x $missingSpaces ) . $str;
    }
    return $str;
}

sub formatNumber {
    my ($self, $number, %options) = @_;

    # We know $number is in [ 0 ; 1024 [ for factor => 1024 or binaryPrefix =>
    # 1, or in [ 0; 1000 [ for factor => 1000 (the default)
    defined $number && looks_like_number($number)
        or croak "formatNumber needs a number";
    my $factor = $self->_getFactor();
    if ($number < 0 || $number > $factor) {
        die "Expected number to lie in the interval [ 0 ; $factor [";
    }

    unless ($options{maxSignificantDigits} || $options{significantDigits}) {
        $options{maxSignificantDigits} = 4;
    }

    my $sigDigits = $options{significantDigits} //
                    $options{maxSignificantDigits};

    my $digitsAfterComma;
    if ($number < 10) {
        $digitsAfterComma = $sigDigits - 1;
    } elsif ($number < 100) {
        $digitsAfterComma = $sigDigits - 2;
    } elsif ($number < 1000) {
        $digitsAfterComma = $sigDigits - 3;
    } else {
        $digitsAfterComma = $sigDigits - 4;
    }

    $digitsAfterComma = 0
        if $digitsAfterComma < 0;

    my $str = sprintf "%.${digitsAfterComma}f", $number;

    unless ($options{significantDigits}) {
        # Shave off any trailing 0* after the comma as in "2.00" => "2"
        $str =~ s/(\.\d*?)0+$/$1/;
        $str =~ s/\.$//;
    }
    if ($options{width}) {
        return _padMissingSpaces($str, $options{width});
    }
    return $str;
}

sub string {
    my ($self, $number, %options) = @_;

    my ($calcNumber, $prefix) = $self->numberPrefixOrEng($number);

    # Lets handle width ourselves later...
    my $width = $options{width};
    delete $options{width};

    my $str = $self->formatNumber($calcNumber, %options);
    if ($prefix ne '') {
        $str .= ' ' . $prefix;
    }

    if ($width) {
        return _padMissingSpaces($str, $width);
    }
    return $str;
}
