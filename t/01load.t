use Test::More tests => 5;

BEGIN{ use_ok('Games::QuizTaker','use Games::QuizTaker;'); }

my $QT1=Games::QuizTaker->new(FileName=>"t/sampleqa",Score=>1);

ok(defined $QT1,'Object created');
ok($QT1->isa('Games::QuizTaker'),'Its the correct type');
is($$QT1{_FileName},"t/sampleqa",'FileName is set');
is($$QT1{_Delimiter},"|",'Default Delimiter is set');


