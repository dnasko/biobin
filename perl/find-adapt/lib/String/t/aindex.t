use String::Approx 'aindex';
use Test::More tests => 12;

chdir('t') or die "could not chdir to 't'";

is(aindex("xyz", "abcdef"), -1);

is(aindex("xyz", "abcdefxyz"), 6);

is(aindex("xyz", "abcdefxgh"), -1);

is(aindex("xyz", "abcdefyzg"), 6);

is(aindex("xyz", "abcdefxgz"), 6);

is(aindex("xyz", "abcdexfyz"), 5);

is(aindex("xyz", ["initial_position=3"], "xyzabcde"), -1);

is(aindex("xyz", ["initial_position=1"], "xyzabcde"), 1);

is(aindex("xyz", ["final_position=5"],   "abcdexyz"), -1);

is(aindex("xyz", ["initial_position=2",
		  "final_position=6"],   "xyzabcxyz"), -1);

is(aindex("xyz", ["initial_position=2",
		  "final_position=7"],   "xyzabcxyz"), 6);

is(aindex("xyz", ["initial_position=1",
		  "final_position=6"],   "xyzabcxyz"), 1);

# that's it.
