#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Config::General::Easy' );
}

diag( "Testing Config::General::Easy $Config::General::Easy::VERSION, Perl $], $^X" );
