# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..9\n"; }
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
my $Num=keys %hash;
if($Num == 10){
  print"Load function .......... ok 5\n";
}else{
  print"Load function .......... not ok 5\n";
}
my($ref1,$ref2,$ref3,$ref4)=$Q1->generate(\%hash);
my $num=keys %{$ref1};
#foreach my $key(keys %$ref1){
#  foreach my $ln(@$ref1{$key}){
#    print"$key => $$ref1{$key}[$ln]\n";
#  }
#}
if($num == 10){
  print"Generate function ...... ok 6\n";
}else{
  print"num is $num\n";
  print"Generate function ...... not ok 6\n";
}
my $V=$Q2->_get_VERSION;
if($V=~/^\d\.\d{2}/){
  print"Version function ....... ok 7\n";
}else{
  print"Version function ....... not ok 7\n";
}
my $PO=$Q2->_Print_Object;
if(defined $PO){
  print"Print_Object ........... ok 8\n";
}else{
  print"Print_Object ........... not ok 8\n";
}
my $Q3=Games::QuizTaker->new(FileName=>"sample.csv",Delimiter=>",",Answer_Delimiter=>"x");
my $del=$Q3->_get_Answer_Delimiter;
if($del eq "x"){
  print"Answer_Delimiter init .. ok 9\n";
}else{
  print"Answer_Delimiter init .. not ok 9\n";
}
