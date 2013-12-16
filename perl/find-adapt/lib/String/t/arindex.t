use String::Approx 'arindex';

chdir('t') or die "could not chdir to 't'";

print "1..3\n";

print "not " unless arindex("xyz", "abcxyzdefxyz") ==  9;
print "ok 1\n";

print "not " unless arindex("xyz", "abcxyzdefghi") ==  3;
print "ok 2\n";

print "not " unless arindex("xyz", "abcwyzdefghi") ==  3;
print "ok 3\n";

