package Validator;

use utf8;
use strict;

use File::Slurp;
use Email::Valid;

sub validator {
	my ($file, $invalid, $check_tld, $domains, @mails, %opt);
	($file, $invalid, $check_tld, $domains) = @_;

	@mails = read_file($file, chomp => 1);

	map {
		# проверка валидности email
		%opt = (-address => $_, -mxcheck => 1);
		if ($check_tld) {
			$opt{-tldcheck} = 1;
		}
		if (Email::Valid->address(%opt)) {
			# выкусываем домен
			s/.*\@//;
			if ($_) {
				$domains->{$_}++;
			}
		}
		else {
			$invalid++;
		}

	} (@mails);

	return $domains;
}

1;