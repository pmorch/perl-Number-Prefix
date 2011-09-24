use warnings;
use strict;
use Test::More tests => 16;

use Number::Prefix;

my $np = Number::Prefix->new();

sub testString {
    my ($header, $options, $sets) = @_;
    foreach my $set (@$sets) {
        my ($number, $string) = @$set;
        is($np->string($number, %$options), $string,
           "$header: $number works ($string)");
    }
}

testString(
    'Default formatting',
    {
        # defaults to maxSignificantDigits => 4
    },
    [
        [ 0            => '0' ],
        [ 1            => '1' ],
        [ 200          => '200' ],
        [ 3.1415192654 => '3.142' ],
        [ 31.415192654 => '31.42' ],
        [ 314.15192654 => '314.2' ],
        [ 31.4         => '31.4' ],
        [ 2000         => '2 k' ],
        [ 2345         => '2.345 k' ],
        [ 23450        => '23.45 k' ],
        [ 234500       => '234.5 k' ],
    ]
);

testString(
    'width => 8',
    {width => 8},
    [
        [ 0            => '       0' ],
        [ 1            => '       1' ],
        [ 2345         => ' 2.345 k' ],
        [ 23450        => ' 23.45 k' ],
        [ 234500       => ' 234.5 k' ],
    ]
);
