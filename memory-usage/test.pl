#!/usr/bin/perl -w

use strict;
use JSON::XS;

my ($get_info, @out, @names, @vals, %templ, %out);
%templ = (
	"cached" => '',
	"total" => '',
	"free" => '',
	"used" => '',
);

$get_info = `free -b`;

@out = split("\n", $get_info);
$out[0] =~ s/\s+/\t/goi;
$out[1] =~ s/\s+/\t/goi;

@names = split("\t", $out[0]);
@vals = split("\t", $out[1]);

%out = ();
foreach (0..(@names - 1)) {
	if ($_ && $names[$_] && $vals[$_]) {
		$names[$_] =~ s/buff.cache/cached/;
		if (exists $templ{$names[$_]}) {
			print "$_ : $names[$_] = $vals[$_]\n";
			$out{$names[$_]} = $vals[$_];
		}
	}
}
print encode_json({ 'memory' => { %out} });
exit;


