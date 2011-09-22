use inc::Module::Install;

name           'Number-Prefix';
repository     'https://github.com/pmorch/perl-Number-Prefix';
all_from       'lib/Number/Prefix.pm';

test_requires  'Test::More' => '0.84';

WriteAll;
