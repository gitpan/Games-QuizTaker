use Test::More tests=>7;
use Games::QuizTaker;

my $gq=Games::QuizTaker->new(FileName=>"t/sampleqa");
my %hash;

my $max=$gq->get_Max_Questions;
ok(!defined $max ,'Max questions init');

my $final=$gq->get_Score;
ok(!defined $final,'Default final score');

my $gq2=Games::QuizTaker->new(FileName=>"t/sampleqa",Score=>1);
my $final2=$gq2->get_Score;
ok(defined $final2,'Set Default score');

eval{ my $Q=Games::QuizTaker->new(FileName=>"t/sample.csv",Delimiter=>',',Answer_Delimiter=>','); };
ok($@=~m|The Delimiter and Answer_Delimiter are the same|,'Catch new function error');

$gq->load(\%hash);
eval{ my($d,$e,$f)=$gq->generate(\%hash,"10"); };
ok($@=~m|Number of questions in .* exceeded|,'Catch generate function error');

eval{ my($g,$h,$i)=$gq->generate(\%hash,"0"); };
ok($@=~m|Must have at least one question in test|,'Catch second generate function error');

eval{ $gq->bad_method; };
ok($@=~m|No such method|,'Catch AUTOLOAD errors');


