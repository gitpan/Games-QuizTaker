use Test::More tests=>17;

#1
BEGIN { use_ok('Games::QuizTaker', 'Games::QuizTaker loaded'); }

#2
$Q1=Games::QuizTaker->new(FileName=>"sampleqa",Score=>1);
ok(defined $Q1, 'Object created');

#3
ok($Q1->isa('Games::QuizTaker'),"It's the correct type");

#4
ok($$Q1{_FileName} eq "sampleqa", 'FileName set');

#5
ok($$Q1{_Delimiter} eq "|", 'Default delimiter set');

#6
$Q2=Games::QuizTaker->new(FileName=>"sample.csv",Delimiter=>",");
ok($$Q2{_Delimiter} eq ",",'File Delimiter set');

#7
my %hash=();
my $refhash=$Q1->load(\%hash);
my $Num=keys %$refhash;
ok($Num == 9,'Load Function');

#8
my($ref1,$ref2,$ref3,$ref4)=$Q1->generate(\%hash);
my $num=keys %{$ref1};
ok($num == 9,'Generate Function');

#9
my $V=$Q2->get_VERSION;
ok($V=~/^\d\.\d{1,3}/, 'VERSION Function');

#10
my $Q3=Games::QuizTaker->new(FileName=>"sample.csv",Delimiter=>",",Answer_Delimiter=>"x");
my $del=$Q3->get_Answer_Delimiter;
ok($del eq "x", 'Answer_Delimiter init');

#11
my $Max=$Q3->get_Max_Questions;
ok($Max == 0,'Max Questions init');

#12
my $Final=$Q3->get_Score;
ok(! defined $Final,'Default Final Score');

#13
my $Final2=$Q1->get_Score;
ok(defined $Final2, 'Set Final Score');

#14
eval{ my $Q4=Games::QuizTaker->new(FileName=>"sample.csv",Delimiter=>',',Answer_Delimiter=>','); };
ok( $@=~m|The Delimiter and Answer_Delimiter are the same| , 'Catch new function error' );

#15
eval{ my($d,$e,$f)=$Q1->generate(\%hash,"10"); };
ok( $@=~m|Number of questions in .* exceeded| , 'Catch generate function error' );

#16
eval{ my($g,$h,$i)=$Q1->generate(\%hash,"0"); };
ok( $@=~m|Must have at least one question in test| , 'Catch second generate function error');

#17
eval{ $Q3->bad_method; };
ok( $@=~/No such method/ , 'Catch AUTOLOAD errors');
 
