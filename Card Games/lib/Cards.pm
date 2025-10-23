#!/usr/env perl;
use strict;use warnings;
use Object::Pad;
use lib "../lib/";
use utf8;
binmode(STDOUT, ":utf8");
use Display;
my $d=new Display();


=head2 Card
A Card Object

Multiple ways exist to create a Card
 my $card=new Card("Ace Of Spades");
 my $card=new Card("10","hearts");
 my $card=new Card({value=>"jack",suit=>"diamonds"});
 my $card=new Card({number=>"8",suit=>"c"});


the card object can also have a position (default [0,0])
 my $card=new Card({number=>"8",suit=>"hearts"},4,8);
 my $card=new Card({number=>"8",suit=>"hearts"},[4,8]);

=cut



class Card{
	field $number :reader;
	field $rank :reader;
	field $suit :reader;
	field $name :reader;
	field $char :reader;
	field $colour :reader;
	field $position :reader :writer =[0,0];
	field $face :reader :writer="up";
	field $symbol :reader;
	field $packColour :reader;
	
	BUILD{
	  my $n=shift;	
	  my ($s,$r,$c);
	  if (ref $n){
		 $s=uc($n->{suit});
		 $position->[0]=$n->{row}//$n->{y}//$n->{pos}[0]//0;
		 $position->[1]=$n->{column}//$n->{x}//$n->{pos}[1]//0;
		 $packColour=$n->{packColour}//"blue";	
		 $n=$n->{rank}//$n->{number};
      }
      elsif($n=~/(ACE|1|ONE|TWO|2|THREE|3|FOUR|4|FIVE|5|SIX|6|SEVEN|7|EIGHT|8|NINE|9|TEN|10|JACK|KNIGHT|QUEEN|KING)\s+OF\s+(SPADES|HEARTS|DIAMONDS|CLUBS)/i){
	     $n=uc($1);
	     $s=uc($2);
      }
      else{
		  $s=shift;
	  }
	  $r=shift;
	  if (!$r){ $position=[0,0];}
	  elsif (ref $r){ $position->[0]=int($r->[0]);$position->[1]=int($r->[1]);}
	  else{
			  $position->[0]=int($r)//0;
			  $position->[1]=shift//0;
			  $position->[1]=int($position->[1]);
	  }
	 # die $position->[0].",".$position->[1];
      if ($n=~/knight/i){$n=12}
      elsif ($n=~/(ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE|TEN)/){
		 $n={ONE=>1,TWO=>2,THREE=>3,FOUR=>4,FIVE=>5,SIX=>6,SEVEN=>7,EIGHT=>8,NINE=>9,TEN=>10}->{$n};
	  }
	  elsif ($n=~/^[akqj]/i){
	     $n={a=>1,j=>11,q=>13,k=>14}->{lc(substr($n,0,1))};
      }
      
      $number=$n;
      $rank=(qw/ACE 2 3 4 5 6 7 8 9 10 JACK KNIGHT QUEEN KING/)[$number-1];
      $suit={ s=>"SPADES",h=>"HEARTS",d=>"DIAMONDS",c=>"CLUBS"}->{lc(substr($s,0,1))};
      $name="$rank OF $suit";
      $colour=$s=~/^(s|c)/i?"black,on_white":"red,on_white";
      $packColour//="blue";	
      $char=chr({ s=>127137,h=>127153,d=>127169,c=>127185}->{lc(substr($s,0,1))}+$n-1);
      $symbol={HEARTS=>chr(0x2665),CLUBS=>chr(0x2663), DIAMONDS=>chr(0x2666),  SPADES=>chr(0x2660)}->{$suit};
      
      };
      
      method small{
		  my $display=shift;
		  if ($face eq "up"){
			  $display->printAt($position->[0],$position->[1],$display->paint($char." ",$colour));
		  }
		  else{
			  $display->printAt($position->[0],$position->[1],$display->paint(chr(0x1F0A0)." ",["blue","on_white"]));
		  }
			  
	  }
	  
      method medium{
		  my $display=shift;
		  my $cardHeight=my $cardWidth=4;
		  my $grid;
		  my $sm=($rank=~/\d+/)?$rank:substr($rank,0,1);
		  if ($face eq "up"){
			  $grid=[
			   [$display->colour($colour." on_white overline"). $sm,(" ") x ($cardWidth-1-length $sm)," ".$display->colour("reset")],
	           [$display->colour($colour." on_white")." ",(" ")x int($cardWidth/2-2),$symbol,(" ")x int($cardWidth/2-1)," ".$display->colour("reset")],
	           [$display->colour($colour." on_white underline")." "," " x ($cardWidth-1-length $sm) , $sm.$display->colour("reset")],];
	      }
	      else{
		    $grid=[[$display->colour($colour." on_$packColour white overline")."╔",("═") x ($cardWidth-2),"╗".$display->colour("reset")],
		           [$display->colour(" on_$packColour white")."║",("%") x ($cardWidth-2),"║".$display->colour("reset")],
	               [$display->colour(" on_$packColour  white underline")."╚","═" x ($cardWidth-2) , "╝".$display->colour("reset")],];
	     };
		 $display->printAt($position->[0],$position->[1],$display->paint($grid,$colour));
      }
	  
      method large{
		  my $display=shift;
		  my $cardHeight=my $cardWidth=8;
		  my $grid;
		  my $sm=($rank=~/\d+/)?$rank:substr($rank,0,1);
		  if ($face eq "up"){
			  $grid=[
			   [$display->colour($colour." on_white overline"). $sm,(" ") x ($cardWidth-1-length $sm)," ".$display->colour("reset")],
		       ([$display->colour(" on_$packColour white")."|",(" ") x ($cardWidth-2),"|".$display->colour("reset")]) x ($cardHeight-3)/2,
	           [$display->colour($colour." on_white")." ",(" ")x int($cardWidth/2-2),$symbol,(" ")x int($cardWidth/2-1)," ".$display->colour("reset")],
	           [$display->colour($colour." on_white underline")." "," " x ($cardWidth-1-length $sm) , $sm.$display->colour("reset")],];
	      }
	      else{
		    $grid=[[$display->colour($colour." on_$packColour white overline")."╔",("═") x ($cardWidth-2),"╗".$display->colour("reset")],
		           ([$display->colour(" on_$packColour white")."║",("%") x ($cardWidth-2),"║".$display->colour("reset")]) x ($cardHeight-3),
	               [$display->colour(" on_$packColour  white underline")."╚","═" x ($cardWidth-2) , "╝".$display->colour("reset")],];
	     };
		 $display->printAt($position->[0],$position->[1],$display->paint($grid,$colour));
      }
            
      method flip{
		  $face=($face eq "up")?"down":"up";
		  return $self;
	  }
};


=head2 Deck
a Deck of Cards
=cut

class Stack{
	field $cards  :reader =[];
	field $spread :writer =[0,0];
	field $pos :param :reader :writer =[4,4];
	
	BUILD {
	}
	
	method fullDeck{
		foreach my $rank(qw/ACE 2 3 4 5 6 7 8 9 10 JACK QUEEN KING/){
			foreach my $suit(qw/SPADES HEARTS DIAMONDS CLUBS/){
				$self->addCard(Card->new($rank,$suit))
			}
		}
		return $self;
	}
	
	method size{
		return scalar @$cards;
	}
	
	method addCard{
		my $newCard=shift;
		push @$cards,$newCard;
		return $self;
	}
	
	method shuffle{
		foreach my $i (0..$#$cards){
			my $j=int(rand()*$i);
			@$cards[$i,$j]=@$cards[$j,$i];
		}
		return $self;
	}
	
	method deal{
		my $pos=shift;
		my $giveOut=pop @$cards;
		if (!$pos){
			return $giveOut;
		}
		elsif (ref $pos eq "ARRAY"){
			$giveOut->set_position($pos);
			return $giveOut;
		}
		elsif (ref $pos eq "Stack"){
			$pos->addCard($giveOut);
		}
	}
	
	method cut{
		my ($r,$n)=@_;
		$n//=2;
		$r//=$self->size()/8;
		
	}
	
	method spread{
		
		
	}
}

