# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Tk-StatusBar.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;
BEGIN { use_ok('Tk::StatusBar') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use strict;
use Test;

use Tk;
use Tk::StatusBar;

my $mw = tkinit;
my $sb = $mw->StatusBar;

ok($sb);