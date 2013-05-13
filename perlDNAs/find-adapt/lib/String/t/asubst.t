use String::Approx qw(asubstitute);

chdir('t') or die "could not chdir to 't'";

require 'util';

print "1..11\n";

# test 1

open(WORDS, 'words') or die "could not find words";

t(
  [qw(
      ap(peal)
      dis(pel)
      (erl)angen
      hy(per)bola
      m(erl)in
      (parl)ance
      (pearl)
      (per)k
      su(per)appeal
      su(per)lative
   )],
  [asubstitute('perl', '($&)', <WORDS>)]);
print "ok 1\n";

close(WORDS);

# test 2: like 1 but no insertions allowed

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      a(ppeal)
      dis(pel)
      (erl)angen
      hy(perb)ola
      m(erl)in
      (parl)ance
      (perk)
      su(pera)ppeal
      su(perl)ative
   )],
  [asubstitute('perl', '($&)', ['I0'], <WORDS>)]);
print "ok 2\n";

close(WORDS);

# test 3: like 1 but no deletions allowed

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      a(ppeal)
      hy(perb)ola
      m(erl)in
      (parl)ance
      (pearl)
      (perk)
      su(pera)ppeal
      su(perla)tive
   )],
  [asubstitute('perl', '($&)', ['D0'], <WORDS>)]);
print "ok 3\n";

close(WORDS);

# test 4: like 1 but no substitutions allowed

open(WORDS, 'words') or die "could not find 'words'";

t(
  [qw(
      dis(pel)
      (erl)angen
      hy(per)bola
      m(erl)in
      (pearl)
      (per)k
      su(per)appeal
      su(perla)tive
   )],
  [asubstitute('perl', '($&)', ['S0'], <WORDS>)]);
print "ok 4\n";

close(WORDS);

# test 5: 2-differences

open(WORDS, 'words') or die;

t(
  [qw(
      ab(err)ant
      acc(el)erate
      a(ppeal)
      dis(pel)
      (erla)ngen
      f(el)icity
      gibb(eri)sh
      hy(perbol)a
      it(era)te
      l(egerd)emain
      m(erli)n
      m(erm)aid
      oatm(eal)
      (park)
      (parla)nce
      P(earl)
      (pearl)
      (perk)
      (petal)
      su(perap)peal
      su(perlat)ive
      su(ppl)e
      twi(rl)
      z(eal)ous
     )],
  [asubstitute('perl', '($&)', [2], <WORDS>)]);
print "ok 5\n";

close(WORDS);

# test 6: i(gnore case)

open(WORDS, 'words') or die;

t(
  [qw(
      a(ppeal)
      dis(pel)
      (erl)angen
      hy(perb)ola
      m(erl)in
      (parl)ance
      (Pearl)
      (pearl)
      (perk)
      su(pera)ppeal
      su(perla)tive
    )],
  [asubstitute('perl', '($&)', ['i'], <WORDS>)]);
print "ok 6\n";

close(WORDS);

# test 7: both i(gnore case) and g(lobally)

open(WORDS, 'words') or die;

t(
  [qw(
      a(ppeal)
      dis(pel)
      (erl)angen
      hy(perb)ola
      m(erl)in
      (parl)ance
      (Pearl)
      (pearl)
      (perk)
      su(pera)p(peal)
      su(perla)tive
     )],
  [asubstitute('perl', '($&)', ['ig'], <WORDS>)]);
print "ok 7\n";

close(WORDS);

# test 8: exercise all of $` $& $'

open(WORDS, 'words') or die;

t(
  [qw(
      ap(ap:peal:)
      dis(dis:pel:)
      (:erl:angen)angen
      hy(hy:per:bola)bola
      m(m:erl:in)in
      (:parl:ance)ance
      (:pearl:)
      (:per:k)k
      su(su:per:appeal)appeal
      su(su:per:lative)lative
   )],
  [asubstitute('perl', q(($`:$&:$')), map {chomp;$_} <WORDS>)]);
print "ok 8\n";

close(WORDS);

# test 9: $_

$_ = "foo";
eval 'asubstitute("foo","bar")';
print "not " unless $_ eq 'bar';
print "ok 9\n";
$_ = 'foo'; # anything defined so later tests do not fret

# test 10: test for undefined input

undef $_;
eval 'asubstitute("foo","bar")';
print 'not ' unless ($@ =~ /what are you substituting/);
print "ok 10\n";
$_ = 'foo'; # anything defined so later tests do not fret

# test 11: test fuzzier subsitution.

open(WORDS, 'words') or die;

t(
  [qw(
      ab(ab:err:ant)ant
      acc(acc:el:erate)erate
      a(a:ppeal:)
      dis(dis:pel:)
      (:erla:ngen)ngen
      f(f:el:icity)icity
      gibb(gibb:eri:sh)sh
      hy(hy:perbol:a)a
      it(it:era:te)te
      l(l:egerd:emain)emain
      m(m:erli:n)n
      m(m:erm:aid)aid
      oatm(oatm:eal:)
      (:park:)
      (:parla:nce)nce
      P(P:earl:)
      (:pearl:)
      (:perk:)
      (:petal:)
      su(su:perap:peal)peal
      su(su:perlat:ive)ive
      su(su:ppl:e)e
      twi(twi:rl:)
      z(z:eal:ous)ous
   )],
  [asubstitute('perl', q(($`:$&:$')), [q(2)], map {chomp;$_} <WORDS>)]);
print "ok 11\n";

close(WORDS);

# eof
