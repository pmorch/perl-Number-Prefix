use warnings;
use strict;
use Test::More tests => 11;

use Number::Prefix;

my $np = Number::Prefix->new();

is($np->string(0),                                    '0');
is($np->string(3454),                                 '3.454 k');
is($np->string(3454, maxSignificantDigits => 5),      '3.454 k');
is($np->string(3454, significantDigits => 5),         '3.4540 k');
is($np->string(3454.345),                             '3.454 k');
is($np->string(3454.345, significantDigits => 5),     '3.4543 k');
is($np->string(3454.345, maxSignificantDigits => 5),  '3.4543 k');
is($np->string(1024), '1.024 k');

$np = Number::Prefix->new(binaryPrefix => 1);

is( $np->string(0),    '0' );
is( $np->string(1024), '1 Ki' );
is( $np->string(2000), '1.953 Ki' );
