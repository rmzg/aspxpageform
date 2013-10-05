#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'MojoX::ASPXPageForm' ) || print "Bail out!\n";
}

diag( "Testing MojoX::ASPXPageForm $MojoX::ASPXPageForm::VERSION, Perl $], $^X" );
