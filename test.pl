# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use Games::QuizTaker;
$loaded = 1;
  print"Loaded ............... ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$Q1=Games::QuizTaker->new({-FileName=>"sampleqa"});
if($$Q1{-FileName} eq "sampleqa"){
  print"{-FileName} .......... ok 2\n";
}else{
  print"{-FileName} .......... not ok 2\n";
}
if($$Q1{-Delimitor} eq "|"){
  print"{-Delimitor} ......... ok 3\n";
}else{
  print"{-Delimitor} ......... not ok 3\n";
}
$Q2=Games::QuizTaker->new({-FileName=>"sample.csv",-Delimitor=>","});
if($$Q2{-Delimitor} eq ","){
  print"{-Delimitor} init .... ok 4\n";
}else{
  print"{-Delimitor} init .... not ok 4\n";
}
my %hash=();
my $refhash=$Q1->load(\%hash);
my $Num=keys %hash;
if($Num == 9){
  print"Load function ........ ok 5\n";
}else{
  print"Load function ........ not ok 5\n";
}
my($ref1,$ref2,$ref3,$ref4)=$Q1->generate(\%hash);
my $num=keys %{$ref1};
if($num == 9){
  print"Generate function .... ok 6\n";
}else{
  print"Generate function .... not ok 6\n";
}


