#!/usr/bin/perl -w

require Validator;

my $check_tld = 0; # можно включить проверку tld, поскольку в задании нет четких указаний реализовано фичей без гарантий
my $file = shift @ARGV;

unless ($file) {
	print "Не у казан входной файл";
	exit;
}

my $domains = {};
my $invalid = 0;

if (-e $file) {
	Validator::validator($file, $invalid, $check_tld, $domains);

	print "OK\n";

	map {
		print "$_\t$domains->{$_}\n";
	} (sort {$domains->{$b} <=> $domains->{$a}} keys %{$domains});

	print "INVALID $invalid";
}
else {
	print "Указанного файла не существует";
}

