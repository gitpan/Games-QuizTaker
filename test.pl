# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..10\n"; }
END {print "not ok 1\n" unless $loaded;}
use Games::QuizTaker;
$loaded = 1;
  print"Loaded ................. ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$Q1=Games::QuizTaker->new(FileName=>"sampleqa");
if($$Q1{_FileName} eq "sampleqa"){
  print"{_FileName} ............ ok 2\n";
}else{
  print"{_FileName} ............ not ok 2\n";
}

if($$Q1{_Delimiter} eq "|"){
  print"{_Delimiter} ........... ok 3\n";
}else{
  print"{_Delimiter} ........... not ok 3\n";
}

$Q2=Games::QuizTaker->new(FileName=>"sample.csv",Delimiter=>",");
if($$Q2{_Delimiter} eq ","){
  print"{_Delimiter} init ...... ok 4\n";
}else{
  print"{_Delimiter} init ...... not ok 4\n";
}

my %hash=();
my $refhash=$Q1->load(\%hash);
my $Num=keys %$refhash;
if($Num == 9){
  print"Load function .......... ok 5\n";
}else{
  print"Load function .......... not ok 5\n";
}

my($ref1,$ref2,$ref3,$ref4)=$Q1->generate(\%hash);
my $num=keys %{$ref1};
if($num == 9){
  print"Generate function ...... ok 6\n";
}else{
  print"Generate function ...... not ok 6\n";
}

my $V=$Q2->get_VERSION;
if($V=~/^\d\.\d{1,3}/){
  print"Version function ....... ok 7\n";
}else{
  print"Version function ....... not ok 7\n";
}

my $Q3=Games::QuizTaker->new(FileName=>"sample.csv",Delimiter=>",",Answer_Delimiter=>"x");
my $del=$Q3->get_Answer_Delimiter;
if($del eq "x"){
  print"Answer_Delimiter init .. ok 8\n";
}else{
  print"Answer_Delimiter init .. not ok 8\n";
}

my $Max=$Q3->get_Max_Questions;
if($Max == 0){
  print"Max_Questions init ..... ok 9\n";
}else{
  print"Max_Questions init ..... not ok\n";
}

my $Final=$Q3->get_Score;
if($Final eq "1"){
  print"Final Score set ........ ok 10\n";
}else{
  print"Final Score set ........ not ok 10\n";
}
 
