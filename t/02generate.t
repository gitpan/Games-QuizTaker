use Test::More tests => 3; 
use Games::QuizTaker;

my $q1="t/sampleqa";
my $q2="t/sample.csv";

my $GQ1=Games::QuizTaker->new(FileName=>$q1);

my %hash;
my $refhash=$GQ1->load(\%hash);
my $num=keys %$refhash;
ok($num == 9,'File is loaded');

my($ref1,$ref2,$ref3,$ref4)=$GQ1->generate(\%hash);
my $num2=keys %{$ref1};
ok($num2 == 9,'Questions generated');

my $v=$GQ1->get_VERSION;
ok($v=~/^\d\.\d{1,3}/,'Retrieve Module version');

