use Test::More tests=>11;

BEGIN { use_ok('Games::QuizTaker', 'Games::QuizTaker loaded'); }
$Q1=Games::QuizTaker->new(FileName=>"sampleqa",Score=>1);
ok($$Q1{_FileName} eq "sampleqa", 'FileName set');
ok($$Q1{_Delimiter} eq "|", 'Default delimiter set');

$Q2=Games::QuizTaker->new(FileName=>"sample.csv",Delimiter=>",");
ok($$Q2{_Delimiter} eq ",",'File Delimiter set');

my %hash=();
my $refhash=$Q1->load(\%hash);
my $Num=keys %$refhash;
ok($Num == 9,'Load Function');

my($ref1,$ref2,$ref3,$ref4)=$Q1->generate(\%hash);
my $num=keys %{$ref1};
ok($num == 9,'Generate Function');

my $V=$Q2->get_VERSION;
ok($V=~/^\d\.\d{1,3}/, 'VERSION Function');

my $Q3=Games::QuizTaker->new(FileName=>"sample.csv",Delimiter=>",",Answer_Delimiter=>"x");
my $del=$Q3->get_Answer_Delimiter;
ok($del eq "x", 'Answer_Delimiter init');

my $Max=$Q3->get_Max_Questions;
ok($Max == 0,'Max Questions init');

my $Final=$Q3->get_Score;
ok(! defined $Final,'Default Final Score');

my $Final2=$Q1->get_Score;
ok(defined $Final2, 'Set Final Score');

