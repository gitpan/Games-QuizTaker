package Games::QuizTaker;
use strict;
use vars qw($AUTOLOAD $VERSION);
use Fcntl qw/:flock/;
use Text::Wrap;
use Carp;

$VERSION=1.03;

sub AUTOLOAD{
  my $self=shift;
  carp"The function $AUTOLOAD is not initialized\n";
}

sub DESTROY{
  my $self=shift;
  undef $self;
}

sub new{
  my($class,%arg)=@_;
    bless{ _Delimiter  => $arg{Delimiter}|| "|",
           _FileLength => "0",
           _FileName   => $arg{FileName}||croak"No FileName given",
         },$class;
}
  
sub load{
  my $self=shift;
  my $Question_File=_get_FileName($self);
  my $Separator=_get_Delimiter($self);
  my $Data=shift;
  my $question_number;
  my $length;
  my $count;
  my $C;
  my @sorter=();

  open(FH,"$Question_File")||die"Can't open $Question_File: $!\n";
  flock(FH,LOCK_SH);
  while(<FH>){
    if(/^$/ or /^#/){}else{
      $count++; 
      if($Separator eq "|"){ 
        @sorter=split /\|/;
      }else{
        @sorter=split /$Separator/;
      }
      $question_number=shift @sorter;
      $length=@sorter;
      for($C=0;$C<$length;$C++){
        $$Data{$question_number}[$C]=$sorter[$C];
      }
    }
  }
  flock(FH,LOCK_UN);
  close FH;
  &_set_FileLength($self,$count);
  return $Data;   
}

sub generate{
  my $self=shift;
  my $Total_Questions=_get_FileLength($self);
  my $FileName=_get_FileName($self);
  my $Data=shift;
  my $Max_Questions=shift;

  if(!defined $Max_Questions){
    $Max_Questions=$Total_Questions;
  }elsif($Max_Questions > $Total_Questions){
    croak"Number of questions exceeds the amount in $FileName";
  }
  
  my %Randoms=();
  my @Randoms=();
  my %Test_Questions=();
  my %Test_Answers=(); 
  my %Question_Lengths=();
  my $E;

  for(1..$Max_Questions){
    my $question_number=int(rand($Total_Questions)+1);
    redo if exists $Randoms{$question_number};
    $Randoms{$question_number}=1;
  }

  @Randoms=keys %Randoms;
  &_shuffle(\@Randoms);

  for(my $D=0;$D<$Max_Questions;$D++){
    $Test_Answers{$Randoms[$D]}=pop @{$$Data{$Randoms[$D]}};
    $Test_Questions{$Randoms[$D]} = $$Data{$Randoms[$D]};
  }
  
  foreach my $key(keys %Test_Questions){
    $E=@{$Test_Questions{$key}};
    $Question_Lengths{$key}=$E;
  }
  return \%Test_Questions,\%Test_Answers,\%Question_Lengths,\@Randoms; 
}

sub test{
  my $self=shift;
  my $Questions=shift;
  my $Answers=shift;
  my $Lengths=shift;
  my $Randoms=shift;
  my $Max=shift;

  if(!defined $Max){
    $Max=&_get_FileLength($self);
  }

  my($length,$answer,$key,$X);
  my $question_number=1;
  my $question_answer;
  my $number_correct;

  system('clear');
  print"\n";

  while($question_number<=$Max){
    $key=shift @$Randoms;
    $length=$$Lengths{$key};

    print"Question Number $question_number\n";

    for($X=0;$X<$length;$X++){
      print wrap("","","$$Questions{$key}[$X]\n");
    }

    print"Your Answer: ";
    $answer=<STDIN>;
    chomp($answer);
    $answer=uc $answer;
    $question_answer=$$Answers{$key};
    chomp($question_answer);
    $question_answer=uc $question_answer;

    if($answer eq $question_answer){
      print"That is correct!!\n\n";
      $question_number+=1;
      $number_correct+=1;
    }else{
      print"That is incorrect!!\n";
      print"The correct answer is $question_answer.\n\n";
      $question_number+=1;
    }
  }
  &_Final($number_correct,$Max);
  return;
}

sub _shuffle{
  ## Fisher-Yates shuffle ##
  my $array=shift;
  my $x;
  for($x=@$array;--$x;){
    my $y=int rand ($x+1);
    next if $x == $y;
    @$array[$x,$y]=@$array[$y,$x];
  }
}

sub _Final{
  my $Correct=shift;
  my $Max=shift;
  my $Percentage=($Correct/$Max)*100;

  print"You answered $Correct out of $Max correctly.\n";
  printf"For a final score of %02d%%\n",$Percentage;
  return;
}

sub _set_FileLength{
  my $self=shift;
  my $count=shift;
  $$self{_FileLength}=$count;
}

sub _get_FileLength{
  my $self=shift;
  return $$self{_FileLength};
}

sub _get_FileName{
  my $self=shift;
  return $$self{_FileName};
}

sub _get_Delimiter{
  my $self=shift;
  return $$self{_Delimiter};
}
#####################
## Debug Functions ##
#####################
sub _Print_Object{
  my $self=shift;
  require Data::Dumper;
  print Data::Dumper->Dumper($self); 
}

sub _Get_VERSION{
  my $self=shift;
  return $VERSION;
}
 
1;
__END__

=pod

=head1 NAME

Games::QuizTaker - Create and take your own quizzes and tests

=head1 SYNOPSIS

     use Quiz::Taker;
     my $Q=Quiz::Taker->new(FileName=>"sampleqa");
     my %Data=();
     my $rData=$Q->load(\%Data);
     my ($rQuestions,$rAnswers,$rLengths,$rRandoms)=$Q->generate(\%Data);
     $Q->test($rQuestions,$rAnswers,$rLengths,$rRandoms);

=head1 DESCRIPTION

=over 5

=item new

C<< new("FileName"=>"FILENAME","Delimiter"=>"Delimiter"); >>

This creates the Games::QuizTaker object and initializes it with two
parameters. The FileName parameter is required, and the Delimiter is
optional. The Delimiter is what is used to separate the question and
answers in the question file. If the Delimiter parameter isn't passed,
it will default to the pipe ("|") character.

=item load

C<< $refHash=$QT->load(\%Data); >>

This function will load the hash with all of the questions and answers
from the file that you specify when you create the object. It also sets
another parameter within the $QT object called FileLength, which is the
total number of questions within the file.

=item generate

C<< ($refHash1,$refHash2,$refHash3,$refArray1)=$QT->generate(\%Data,$Max); >> 

This function will generate the 3 hashes and 1 array needed by the test
function. The first reference ($refHash1) are the questions that will be
asked by the test function. The second reference ($refHash2) are the answers
to those questions. The third reference ($refHash3) is the length of the
array that is the value for each key of $refHash1. And $refArray1 is a
sequence of random numbers that is generated from the total number of
questions ($Max) that you wish to answer. The $refArray1 is also randomized
further after its generation by the internal _shuffle function which is a
Fisher-Yates shuffle. If the maximum number of questions you wish to answer
on the quiz ($Max) is not passed to the function, it will default to the
maximum number of questions in the file (determined by the FileLength
parameter within the object.

=item test

C<< $QT->test($refHash1,$refHash2,$refHash3,$refArray1,$Max); >>

This function will print out each question in the Questions hash, and wait
for a response. It will then match that response against the Answers hash.
If there is a match, it will keep track of the number of correct answers, and 
move on to the next question, other wise it will give the correct answer, and
go to the next question. After the last question, it will pass the number
correct and the max number of questions on the test to the _Final function,
which prints out your final score. The $Max variable is optional to be
passed and will default to the total number of questions in the question file.

=back

=head1 EXPORT

None by default

=head1 DEBUGGING

There is a single function available for debugging. When called, it will
print out the contents of the object and its parameters.
 
=head1 ACKNOWLEDGEMENTS

Special thanks to everyone at http://perlmonks.org for their suggestions
and contributions to this module, and to Damian Conway for his excellent
book on Object Oriented Perl

=head1 AUTHOR

Thomas Stanley

Thomas_J_Stanley@msn.com

I can also be found at http://perlmonks.org as TStanley. You can direct
any questions relating to this module there.

=head1 COPYRIGHT

Copyright (C)2001 Thomas Stanley. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms as
Perl itself.
 
=head1 SEE ALSO

I<perl(1)>

=cut


