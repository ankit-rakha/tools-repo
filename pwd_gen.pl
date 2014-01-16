#!/usr/bin/perl

# random password generator (minimum 6 characters password)
# reads from standard input or command line

# Example run:

# for x in {1..10};do ./pwd_gen.pl 10; done

# output:

#1Q_e70112A
#NFPfgQdH-j
#EZ7udEqobB
#sPu4Ux1TO1
#BstfZMn7KW
#fmAwLAJdvz
#dCbObAvKak
#Q9yL9_RFX8
#dUekkvIFJP
#9mOPRe0THI

use strict; use warnings; use diagnostics;

sub genPwd(){

my $password = "";

# can be extended to more ASCII characters

my @options = ('a' .. 'z', 'A' .. 'Z', 0 .. 9, '-', '_');

while ( length $password < "$ARGV[0]" ){

$password .= $options[rand @options];

}

print "$password\n";

}

if ( $ARGV[0] < 6 ){

print "Please choose a password of minimum 6 characters, Please try again.\n"

}
else {

&genPwd;

}

