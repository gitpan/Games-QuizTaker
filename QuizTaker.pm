package Games::QuizTaker;
use strict;
use vars qw($AUTOLOAD $VERSION);
use Fcntl qw/:flock/;
use Text::Wrap;
use Carp;

$VERSION=1.2;

sub AUTOLOAD{
  my ($self)=@_;
  $AUTOLOAD=~/.*::[sg]et(_\w+)/ or croak "No such method: $AUTOLOAD";
  exists $self->{$1} or croak "No such attribute: $1";
  return $self->{$1};
}

sub DESTROY{
  my $self=shift;
  undef $self;
}

sub new{
  my($class,%arg)=@_;
    bless{ _Delimiter        => $arg{Delimiter}|| "|",
	   _Answer_Delimiter => $arg{Answer_Delimiter}|| " ", 
           _Score            => $arg{Score}|| "1",
           _FileLength       => "0",
           _FileName         => $arg{FileName}||croak"No FileName given",
	   _Max_Questions    => "0",
         },$class;
}
  
sub load{
  my $self=shift;
  my $Data=shift;
  my $Question_File=$self->get_FileName;
  my $Separator=$self->get_Delimiter;
  my $Answer_Sep=$self->get_Answer_Delimiter;
  my ($question_number,$count,$ref,@sorter);

  if($Answer_Sep eq $Separator){
    croak"The Delimiter and Answer_Delimiter are the same";
  }

  open(FH,"$Question_File")||croak"Can't open $Question_File: $!";
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
      $ref=\@sorter;
      $$Data{$question_number}=$ref;    
    }
  }
  flock(FH,LOCK_UN);
  close FH;
  $self->set_FileLength($count);
  return $Data;   
}

sub generate{
  my ($self,$Data,$Max_Questions)=@_;
  my $Total_Questions=$self->get_FileLength;
  my $FileName=$self->get_FileName;
  
  $Max_Questions = $Total_Questions unless defined $Max_Questions;

  croak"Number of questions in $FileName exceeded"
    if $Max_Questions > $Total_Questions;

  croak"Must have at least one question in test"
    if $Max_Questions < 1;

  $self->set_Max_Questions($Max_Questions);

  my %Randoms=();
  my @Randoms=();
  my %Test_Questions=();
  my %Test_Answers=(); 
  
  for(1..$Max_Questions){
    my $question_number=int(rand($Total_Questions)+1);
    redo if exists $Randoms{$question_number};
    $Randoms{$question_number}=1;
  }

  @Randoms=keys %Randoms;
  $self->shuffle(\@Randoms);

  for(my $D=0;$D<$Max_Questions;$D++){
    $Test_Answers{$Randoms[$D]}=pop @{$$Data{$Randoms[$D]}};
    $Test_Questions{$Randoms[$D]} = $$Data{$Randoms[$D]};
  }
  
   return \%Test_Questions,\%Test_Answers,\@Randoms; 
}

sub test{
  my $self=shift;
  my $Questions=shift;
  my $Answers=shift;
  my $Randoms=shift;
  my $Answer_Sep=$self->get_Answer_Delimiter;
  my $Max=$self->get_Max_Questions;
  my ($answer,$key,$line,$question_answer);
  my $question_number=1;
  my $number_correct=0;

  system(($^O eq "MSWin32"?'cls':'clear'));
  print"\n";

  while($question_number<=$Max){
    $key=shift @$Randoms;
  
    print"Question Number $question_number\n";

    foreach $line(@{$$Questions{$key}}){
      print wrap("","","$line\n");
    }

    print"Your Answer: ";
    $answer=<STDIN>;
    chomp($answer);
    $answer=uc $answer;
    $question_answer=$$Answers{$key};
    chomp($question_answer);
    $question_answer=uc $question_answer;

    my $ln=length($question_answer);

    if($ln>1){
      if($question_answer!~/$Answer_Sep/){
        warn"Answer_Delimiter doesn't match internally";
      }
      if($Answer_Sep eq " "){
      }else{
        $question_answer=~s/$Answer_Sep/ /;
      }
    }

    if($answer eq $question_answer){
      print"That is correct!!\n\n";
      $question_number++;
      $number_correct++;
    }else{
      print"That is incorrect!!\n";
      print"The correct answer is $question_answer.\n\n";
      $question_number++;
    }
  }
  my $Final=$self->get_Score;
  if($Final == 1){
    $self->Final($number_correct,$Max);
    return;
  }else{
    return;
  }
}

sub shuffle{
  ## Fisher-Yates shuffle ##
  my $self=shift;
  my $array=shift;
  my $x;
  for($x=@$array;--$x;){
    my $y=int rand ($x+1);
    next if $x == $y;
    @$array[$x,$y]=@$array[$y,$x];
  }
}

sub Final{
  my ($self,$Correct,$Max)=@_;
  
  if($Correct >= 1){
    my $Percentage=($Correct/$Max)*100;
    print"You answered $Correct out of $Max correctly.\n";
    printf"For a final score of %02d%%\n",$Percentage;
    return;
  }else{
    print"You answered 0 out of $Max correctly.\n";
    print"For a final score of 0%\n";
    return;
  }
}

sub set_FileLength{
  my $self=shift;
  my $count=shift;
  $$self{_FileLength}=$count;
}

sub set_Max_Questions{
  my $self=shift;
  my $Questions=shift;
  $$self{_Max_Questions}=$Questions;
}

sub get_FileLength{
  my $self=shift;
  return $$self{_FileLength};
}

sub get_Max_Questions{
  my $self=shift;
  return $$self{_Max_Questions};
}

sub get_FileName{
  my $self=shift;
  return $$self{_FileName};
}

sub get_Delimiter{
  my $self=shift;
  return $$self{_Delimiter};
}

sub get_Answer_Delimiter{
  my $self=shift;
  return $$self{_Answer_Delimiter};
}

sub get_Score{
  my $self=shift;
  return $$self{_Score};
}

#####################
## Debug Functions ##
#####################
sub Print_Object{
  my $self=shift;
  my $structure=shift;
  require Data::Dumper;

  if(defined $structure){
    print Data::Dumper->Dumper($structure);
  }else{
    print Data::Dumper->Dumper($self); 
  }
}

sub get_VERSION{
  my $self=shift;
  return $VERSION;
}
 
1;
__END__

=pod

=head1 NAME

Games::QuizTaker - Create and take your own quizzes and tests

=head1 SYNOPSIS

     use Games::QuizTaker;
     my $Q=Games::QuizTaker->new(FileName=>"sampleqa");
     my %Data=();
     my $rData=$Q->load(\%Data);
     my ($rQuestions,$rAnswers,$rRandoms)=$Q->generate(\%Data);
     $Q->test($rQuestions,$rAnswers,$rRandoms);

=head1 DESCRIPTION

=over 5

=item new

C<< new("FileName"=>"FILENAME","Delimiter"=>"Delimiter",Answer_Delimiter=>"Delimiter",Score=>"1"); >>

This creates the Games::QuizTaker object and initializes it with two
parameters. The FileName parameter is required, and the Delimiter is
optional. The Delimiter is what is used to separate the question and
answers in the question file. If the Delimiter parameter isn't passed,
it will default to the pipe ("|") character. The Answer_Delimiter is
used for questions that have more than one correct answer. If the
Answer_Delimiter parameter isn't passed, it will default to a space.
When answering the questions within the test that have more than one
answer, put a space between each answer. There is also a parameter called
Scores that also can be passed to the object. By default it is set to 1 and
will print out the final score of the quiz when done. It can be set to 0,
thus turning it off. This could be done when setting a script up as part of
a login script and giving a "Question of the day".

=item load

C<< $refHash=$QT->load(\%Data); >>

This function will load the hash with all of the questions and answers
from the file that you specify when you create the object. It also sets
another parameter within the $QT object called FileLength, which is the
total number of questions within the file. It will also check to see if
the _Answer_Delimiter parameter is the same as the _Delimiter parameter.
If they are the same, then the program will croak.

=item generate

C<< ($refHash1,$refHash2,$refArray1)=$QT->generate(\%Data,$Max); >> 

This function will generate the 2 hashes and 1 array needed by the test
function. The first reference ($refHash1) are the questions that will be
asked by the test function. The second reference ($refHash2) are the answers
to those questions. And $refArray1 is a sequence of random numbers that is
generated from the total number of questions ($Max) that you wish to answer.
The $refArray1 is also randomized further after its generation by the
internal _shuffle function which is a Fisher-Yates shuffle. If the maximum
number of questions you wish to answer on the quiz ($Max) is not passed to
the function, it will default to the maximum number of questions in the file
(determined by the FileLength parameter within the object). It will also set
the Max_Questions parameter within the object, which will be later used by
the test function to keep track of the number of questions printed out.

=item test

C<< $QT->test($refHash1,$refHash2,$refArray1); >>

This function will print out each question in the Questions hash, and wait
for a response. It will then match that response against the Answers hash.
If there is a match, it will keep track of the number of correct answers, and 
move on to the next question, other wise it will give the correct answer, and
go to the next question. After the last question, it will pass the number
correct and the max number of questions on the test to the _Final function,
which prints out your final score.

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

Also, I would like to thank Chris Ahrends for his suggestions to improve this module,
and to Mike Castle for pointing out a typo in my POD.

=head1 AUTHOR

Thomas Stanley

Thomas_J_Stanley@msn.com

I can also be found at http://perlmonks.org as TStanley. You can direct
any questions relating to this module there.

=head1 COPYRIGHT

Copyright (C)2001,2002 Thomas Stanley. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms as
Perl itself.
 
=head1 SEE ALSO

I<perl(1)>

=cut


