use warnings;
use strict;
use Test::More tests => 32;

use Number::Prefix;

my $np = Number::Prefix->new(binaryPrefix => 1);

sub testFormatNumber {
    my ($header, $options, $sets) = @_;
    foreach my $set (@$sets) {
        my ($number, $string) = @$set;
        is($np->formatNumber($number, %$options), $string,
           "$header: $number works ($string)");
    }
}

testFormatNumber(
    'Default formatting',
    {
        # defaults to maxSignificantDigits => 4
    },
    [
        [ 0 => "0" ],
        [ 1 => "1" ],
        [ 200 => "200" ],
        [ 1023 => "1023" ],
        [ 3.1415192654 => '3.142' ],
        [ 31.415192654 => '31.42' ],
        [ 314.15192654 => '314.2' ],
        [ 31.4 => '31.4' ],
    ]
);

testFormatNumber(
    'width => 5',
    { width => 5 },
    [
        [ 0            => '    0' ],
        [ 1            => '    1' ],
        [ 200          => '  200' ],
        [ 1023         => ' 1023' ],
        [ 3.1415192654 => '3.142' ],
        [ 31.415192654 => '31.42' ],
        [ 314.15192654 => '314.2' ],
        [ 31.4         => ' 31.4' ],
    ]
);

testFormatNumber(
    'maxSignificantDigits => 6',
    { maxSignificantDigits => 6 },
    [
        [ 0 => "0" ],
        [ 1 => "1" ],
        [ 200 => "200" ],
        [ 1023 => "1023" ],
        [ 3.1415192654 => '3.14152' ],
        [ 31.415192654 => '31.4152' ],
        [ 314.15192654 => '314.152' ],
        [ 31.4 => '31.4' ],
    ]
);

testFormatNumber(
    'significantDigits => 6',
    { significantDigits => 6 },
    [
        [ 0 => "0.00000" ],
        [ 1 => "1.00000" ],
        [ 200 => "200.000" ],
        [ 1023 => "1023.00" ],
        [ 3.1415192654 => '3.14152' ],
        [ 31.415192654 => '31.4152' ],
        [ 314.15192654 => '314.152' ],
        [ 31.4 => '31.4000' ],
    ]
);
