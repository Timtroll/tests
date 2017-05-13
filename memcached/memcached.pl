#!/user/bin/perl -w

use utf8;
use Cache::Memcached::Fast;
use JSON::XS qw( decode_json );
use Crypt::Blowfish;
use Crypt::CBC;

use Data::Dumper;

# settings
my $crypt_key = pack("H16", "ghuju765vvfnjh23ghj");
my $expires = 600; # seconds
my $namespace = 'my9siter:';
my $host = 'localhost';
my $port = '11211';

# create crypter method
my $cipher = new Crypt::CBC($crypt_key, 'Blowfish');


my $memd = new Cache::Memcached::Fast({
	servers				=> [
		# '192.168.254.2:11211',
		{
			address => "$host:$port",
			weight => 2.5
		},
		# {
		# 	address => '/path/to/unix.sock',
		# 	noreply => 1
		# }
	],
	namespace			=> $namespace,
	connect_timeout		=> 0.2,
	io_timeout			=> 0,
	close_on_error		=> 1,
	compress_threshold	=> 100_000,
	compress_ratio		=> 0.9,
	# compress_methods	=> [
	# 	\&IO::Compress::Gzip::gzip,
	# 	\&IO::Uncompress::Gunzip::gunzip
	# ],
	max_failures		=> 3,
	failure_timeout		=> 2,
	ketama_points		=> 150,
	nowait				=> 1,
	hash_namespace		=> 1,
	# serialize_methods	=> [
	# 	\&Storable::freeze,
	# 	\&Storable::thaw
	# ],
	utf8				=> 1,
	max_size			=> 512 * 1024,
});

# clear all keys
$memd->flush_all;

print "1==\n";

# add new keys
foreach (1..10) {
	my $data = "data {$_-программа}\r\n";
	set_data($_, \$data, $expires);
}

# get all keys & print value of all keys
$res = get_all_data(0);
print Dumper($res);
print "2==\n";

my $string =  JSON::XS->new->encode($res);
print "$string==\n";

my $obj = decode_json($string);
print Dumper $obj;

print "3==\n";

my $result = store_all_data('fileHash.dat', \$string);
unless ($result) {
	print "Ошибка записи\n";
}

my $res;
($res, $obj) = restore_all_data('fileHash.dat', 1);
print Dumper $obj;

print "==================\n";
my $dat = get_data('1', 1);
print $$dat;

print "==================\n";
$dat = get_data_keylike('10', 1);
print Dumper($dat);

print "==================\n";
$dat = get_data_datalike('8', 1);
print Dumper($dat);

######################## Subs ########################

sub set_data {
	my ($key, $data, $dat, $expires);
	$key = shift;
	$data = shift;
	$expires = shift;
	
	$dat = $cipher->encrypt_hex($$data);
	$memd->set($key, $dat, $expires);
	$dat = '';
}

sub get_data {
	my ($key, $value, $decrypt);
	$key = shift;
	$decrypt = shift;
	
	$value = $memd->get($key);
	if ($decrypt) {
		$value = $cipher->decrypt_hex($value);
	}

	return \$value;
}

sub get_all_data {
	my ($decrypt, @all, %res);
	$decrypt = shift;

	$exec = list_keys();
	%res = ();
	map {
		chomp;
		s/^$namespace//goi;
		if (my $val = $memd->get($_)) {
			if ($decrypt) {
				$res{$_} = $cipher->decrypt_hex($val);
			}
			else {
				$res{$_} = $val;
			}
		}
	} (`$exec`);

	return \%res;
}

sub get_data_datalike {
	my ($like, $decrypt, $exec, %res);
	$like = shift;
	$decrypt = shift;

	$exec = list_keys();
	%res = ();
	map {
		chomp;
		s/^$namespace//goi;
		if (my $val = $memd->get($_)) {
			if ($decrypt) {
				$val = $cipher->decrypt_hex($val);
				if ($val =~ /$like/) {
					$res{$_} = $val;
				}
			}
			else {
				if ($val =~ /$like/) {
					$res{$_} = $val;
				}
			}
		}
	} (`$exec`);

	return \%res;
}

sub get_data_keylike {
	my ($like, $decrypt, $exec, %res);
	$like = shift;
	$decrypt = shift;

	$exec = list_keys();
	%res = ();
	map {
		chomp;
		s/^$namespace//goi;
		if (my $val = $memd->get($_)) {
			if (/$like/) {
				if ($decrypt) {
					$res{$_} = $cipher->decrypt_hex($val);
				}
				else {
						$res{$_} = $val;
				}
			}
		}
	} (`$exec`);

	return \%res;
}

sub list_keys {
	return "MEMCHOST=$host; printf \"stats items\\n\" | nc \$MEMCHOST $port | grep \":number\" | awk -F\":\" '{print \$2}' | xargs -I % printf \"stats cachedump \% 0\\n\" | nc \$MEMCHOST $port | grep ITEM | awk '\{print \$2\}'";
}

# store data
sub store_all_data {
	my ($file, $data, $result);
	$file = shift;
	$data = shift;

	$result = 1;
	open(OFIL, ">$file") or $result = 0;
		print OFIL $$data;
	close(OFIL) or $result = 0;

	return $result;
}

# read data
sub restore_all_data {
	my ($file, $data, $result);
	$file = shift;
	$decript = shift;

	$result = 1;
	open(IFIL, "<$file") or $result = 0;
		$data = <IFIL>;
	close(IFIL) or $result = 0;

	$data = decode_json($data);

	map {
		$data->{$_} = $cipher->decrypt_hex($data->{$_});
	} (keys %{$data});

	return $result, \$data;
}

