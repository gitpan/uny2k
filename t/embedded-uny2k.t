#!/usr/bin/perl -w

use Test::More no_plan;

package Catch;

sub TIEHANDLE {
    my($class) = shift;
    return bless {}, $class;
}

sub PRINT  {
    my($self) = shift;
    $main::_STDOUT_ .= join '', @_;
}

sub READ {}
sub READLINE {}
sub GETC {}

package main;

local $SIG{__WARN__} = sub { $_STDERR_ .= join '', @_ };
tie *STDOUT, 'Catch' or die $!;


eval q{
  my $example = sub {
    no warnings;

#line 150 lib/uny2k.pm
use uny2k;
my $year = (localtime)[5];

    $full_year = $year + 1900;

    $two_digit_year = $year % 100;

;

  }
};
is($@, '', "example from line 150");

#line 150 lib/uny2k.pm
use uny2k;
my $year = (localtime)[5];

    $full_year = $year + 1900;

    $two_digit_year = $year % 100;

my $real_year = (CORE::localtime)[5];
is( $full_year,      '19'.$real_year,   "undid + 1900 fix" );
is( $two_digit_year, $real_year,        "undid % 100 fix"  );


