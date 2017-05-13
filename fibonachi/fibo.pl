#!/usr/bin/perl -w

use strict;
use warnings;

# матричный метод вычисления
# Вычисление от 0 до 93 числа

print "Введите номер числа Фибоначчи от 0 до 93 \n";
my $input = <STDIN>;
chomp($input);

if ($input =~ /\D/) {
    print "Введите число\n";
    exit;
}
if (($input < 0)||($input > 93)) {
    print "Вычисление производится только для диапазона 0..93\n";
    exit;
}

my $f = (calc($input, 0, 1, 1, 1))[1];
print "Результат: $f\n";

sub calc {
    my $digit = shift;

    if ($digit == 0) {
        return (1, 0, 0, 1);
    }
    elsif ($digit == 1) {
        return @_;
    }
    elsif ($digit % 2) {
        my @res = calc (
            ($digit-1)/2,
            $_[0]**2 + $_[1] * $_[2],
            $_[1] * ($_[0] + $_[3]),
            $_[2] * ($_[0] + $_[3]),
            $_[1] * $_[2] + $_[3]**2
        );
        return (
            $res[0] *$_[0] + $res[1] * $_[2],
            $res[0] *$_[1] + $res[2] * $_[3],
            $res[2] *$_[0] + $res[3] * $_[2],
            $res[2] *$_[1] + $res[3] * $_[3]
        );
    }
    else {
        return calc (
            $digit/2,
            $_[0]**2 + $_[1] * $_[2],
            $_[1] * ($_[0] +$_[3]),
            $_[2] * ($_[0] +$_[3]),
            $_[1] * $_[2] + $_[3]**2
        );
    }
}
