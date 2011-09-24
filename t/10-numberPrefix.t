use warnings;
use strict;
use Test::More tests => 47;

BEGIN { use_ok('Number::Prefix') }

my $np;

$@ = '';
eval {
    $np = Number::Prefix->new();
};
ok(defined $np && ! $@, '$np could be created');

ok($np->isa('Number::Prefix'), 'Type of $np is good');

sub testValueSets {
    my ($header, $sets) = @_;
    foreach my $set (@$sets) {
        my ($number, $return) = @$set;
        is_deeply([$np->numberPrefix($number)], $return,
                  "$header: $number works (" . join(', ', @$return) . ')');
    }
}

testValueSets(
    'SI',
    [
        [ 0.000_000_9,    [ 900,     'n' ] ],
        [ 0.9,            [ 900,     'm' ] ],
        [ 0,              [ 0,       ''  ] ],
        [ 1,              [ 1,       ''  ] ] ,
        [ 23,             [ 23,      ''  ] ],
        [ 12_345,         [ 12.345 , 'k' ] ],
        [ 134_000,        [ 134,     'k' ] ],
        [ -12_345,        [ -12.345, 'k' ] ],
        [ 12_345_000,     [ 12.345 , 'M' ] ],
        [ 12_345_000_000, [ 12.345 , 'G' ] ],
        [ 1e100,          [              ] ],
    ]
);

$@ = '';
eval {
    $np = Number::Prefix->new(binaryPrefix=>1);
};
ok(defined $np && ! $@, '$np could be created');
ok($np->isa('Number::Prefix'), 'Type of $np is good');

testValueSets(
    'IEC Binary Prefixes',
    [
        [ 0.9,            [          ] ],
        [ 0,              [ 0,  ''   ] ],
        [ 1,              [ 1,  ''   ] ] ,
        [ 23,             [ 23, ''   ] ],
        [ 1024,           [ 1,  'Ki' ] ],
        [ 2048,           [ 2,  'Ki' ] ],
        [ -2048,          [ -2, 'Ki' ] ],
        [ 3221225472,     [ 3,  'Gi' ] ],
        [ 1e100,          [          ] ],
    ]
);

is_deeply([$np->numberPrefix(1e100)], [], "too large works");

$@ = '';
eval {
    $np = Number::Prefix->new(factor => 1024);
};
ok(defined $np && ! $@, '$np could be created');

testValueSets(
    'SI Prefixes, factor 1024',
    [
        # What do we expect to see here? We'll leave it undefined
        # [ 0.9,          [ ??????  ] ],
        [ 0,              [ 0,  ''  ] ],
        [ 1,              [ 1,  ''  ] ] ,
        [ 23,             [ 23, ''  ] ],
        [ 1024,           [ 1,  'k' ] ],
        [ 2048,           [ 2,  'k' ] ],
        [ -2048,          [ -2, 'k' ] ],
        [ 3221225472,     [ 3,  'G' ] ],
        [ 1e100,          [         ] ],
    ]
);

# Test numberPrefixOrEng
$np = Number::Prefix->new();
is_deeply(
    [ $np->numberPrefixOrEng('0.3') ],
    [ '300', 'm' ],
    "numberPrefixOrEng 1"
);
is_deeply(
    [ $np->numberPrefixOrEng('1024') ],
    [ '1.024', 'k' ],
    "numberPrefixOrEng 2"
);
is_deeply(
    [ $np->numberPrefixOrEng(1.2e-80) ],
    [ '12', 'E-81' ],
    "numberPrefixOrEng 3"
);
is_deeply(
    [ $np->numberPrefixOrEng(1.2e80) ],
    [ '120', 'E78' ],
    "numberPrefixOrEng 4"
);

$np = Number::Prefix->new( binaryPrefix => 1 );
is_deeply(
    [ $np->numberPrefixOrEng('0.3') ],
    [ '300', 'E-3' ],
    "numberPrefixOrEng 5"
);
is_deeply(
    [ $np->numberPrefixOrEng('1024') ],
    [ '1', 'Ki' ],
    "numberPrefixOrEng 6"
);
is_deeply(
    [ $np->numberPrefixOrEng(1.2e-80) ],
    [ '12', 'E-81' ],
    "numberPrefixOrEng 7"
);
is_deeply(
    [ $np->numberPrefixOrEng(1.2e80) ],
    [ '120', 'E78' ],
    "numberPrefixOrEng 8"
);

# Error conditions
$@ = '';
eval { my $ret = $np->numberPrefix() };
like($@, qr/^numberPrefix needs a number/, 'die if no input');

$@ = '';
eval { my $ret = $np->numberPrefix('hello world') };
like($@, qr/^numberPrefix needs a number/, 'die if given a string');

$@ = '';
eval { my $ret = $np->numberPrefix([]) };
like($@, qr/^numberPrefix needs a number/, 'die if given an arrayref');

$@ = '';
eval { my $ret = $np->numberPrefix({}) };
like($@, qr/^numberPrefix needs a number/, 'die if given a hashref');
