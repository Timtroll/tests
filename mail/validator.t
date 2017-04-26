#!/usr/bin/perl -w

use Test::More;

my %test = (
	'Не у казан входной файл'			=> '',
	'Указанного файла не существует'	=> './1.tx',
	'OK'								=> './1.txt',
	'INVALID'							=> './1.txt'
);

foreach (keys %test) {
	my $out = `perl ./validator.pl $test{$_}`;
	ok($out =~ /.*$_.*/, "Check input options");
}

done_testing;
