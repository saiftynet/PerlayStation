#!/usr/env perl;
use strict;use warnings;
use Object::Pad;

use utf8;
binmode(STDOUT, ":utf8");
my $d=new Display();


 my $deck=new Stack;
 $deck->fullDeck();#
 my $player1=new Stack;
 
 my $card=new Card("Ace Of Spades");
 $card=new Card("10","hearts");
 $card=new Card({rank=>"jack",suit=>"diamonds"});
 $card=new Card({number=>"8",suit=>"c"});
 $card=new Card({number=>"8",suit=>"hearts"},4,8);
 $card=new Card({number=>"10",suit=>"hearts"},[4,8]);
 $card->medium($d);
 $card=new Card({number=>"9",suit=>"hearts"},[5,9]);
 $card->medium($d);
 $card=new Card({number=>"8",suit=>"clubs"},[6,10]);
 $card->flip();
 $card->medium($d);
 $card=$deck->shuffle()->deal([7,11]);
 $card->set_face("down");
 $card->large($d);
 $deck->shuffle()->deal($player1);

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


class Display{
	use Time::HiRes "sleep";
	use utf8;
	field %colours=(black   =>30,red   =>31,green   =>32,yellow   =>33,blue   =>34,magenta   =>35,cyan  =>36,white   =>37,
               on_black=>40,on_red=>41,on_green=>42,on_yellow=>43,on_blue=>44,on_magenta=>45,on_cyan=>46,on_white=>47,
               reset=>0, bold=>1, faint=>2, italic=>3, underline=>4, overline=>53, blink=>5, strikethrough=>9, invert=>7, fast_blink=>6, no_blink=>25);
    field $buffer="\033[?c";
    field $dimensions  :param //={width=>80,height=>24};
    field $bigNum={1=>[" ▟ "," ▐ "," ▟▖"],
		           2=>["▞▀▖"," ▞ ","▟▄▖"],
		           3=>["▞▀▖"," ▀▖","▚▄▘"],
		           4=>[" ▟ ","▟▟▖"," ▐ "],
		           5=>["▛▀▘","▀▀▖","▚▄▘"],
		           6=>["▞▀▖","▙▄ ","▚▄▘"],
		           7=>["▀▀▌"," ▞ ","▞  "],
		           8=>["▞▀▖","▞▀▖","▚▄▘"],
		           9=>["▞▀▖","▝▀▌","▚▄▘"],
		           0=>["▞▀▖","▌ ▌","▚▄▘"],
		           "."=>["   ","   "," █ "],
		           " "=>["   ","   ","   "],
		           "L"=>["▗▚ ","▟▄ ","▟▄ "],
		           "p"=>["   ","▗▚ ","▐▘ "],
		           "?"=>["▞▀▖"," ▞ "," ▖ "],
			   };
	field $borders={	
		simple=>{tl=>"+", t=>"-", tr=>"+", l=>"|", r=>"|", bl=>"+", b=>"-", br=>"+",ts=>"|",te=>"|",},
		double=>{tl=>"╔", t=>"═", tr=>"╗", l=>"║", r=>"║", bl=>"╚", b=>"═", br=>"╝",ts=>"╣",te=>"╠",},
		shadow=>{tl=>"┌", t=>"─", tr=>"╖", l=>"│", r=>"║", bl=>"╘", b=>"═", br=>"╝",ts=>"┨",te=>"┠",},
		thin  =>{tl=>"┌", t=>"─", tr=>"┐", l=>"│", r=>"│", bl=>"└", b=>"─", br=>"┘",ts=>"┤",te=>"├",},  
		thick =>{tl=>"┏", t=>"━", tr=>"┓", l=>"┃", r=>"┃", bl=>"┗", b=>"━", br=>"┛",ts=>"┫",te=>"┣",}, 
	};
     
     BUILD{
		 print "\033[?25l"; # disable blinking cursor
	 }
=head3 style($style)
returns the Escape sequence that corresponds to an ANSI style
=cut	
    method style($style){
		return exists $colours{$style}?"\033[$colours{$style}m":"";
	}
	
=head3 decorate()
allows multiple style sequences.  these style formats may be passes either as
a comma separted string or an ArrayRef
=cut		
	method colour($formats){
		return "" unless $formats;
		my @fmts=ref $formats? @$formats :  split(/[, ]/,$formats);
		my $dec="";
		foreach (@fmts){
			$dec.=exists $colours{$_}?"\033[$colours{$_}m":"";
		}
		return $dec
	}
	
=head3 paint($block,@formats)
	# multiple styles can used by either using a ref to a list of styles, or comma separated list
	# multiline strings is handled by either using a ref to a list of strings, or comma separated list
=cut
    method paint($block,$formats){ 
		return unless $block;
		my @strs=ref $block ? @$block  :  split("\n",$block);
		foreach (0..$#strs){
			my $line=ref $strs[$_]?join("",@{$strs[$_]}):$strs[$_];
			$line=$self->colour($formats).$line."\033[$colours{reset}m";
			$strs[$_]=$line;
		}
		return ref $block?\@strs:join("\n",@strs);
	}
	
=head3 printAt($row,$column,$block)
 print a string to a cursor position
 multiline strings is handled by either using a ref to a list of strings, or comma separated list
=cut	
	method printAt($row,$column,$block){
		$block//="";
		my @strs=ref $block ? @$block  :  split("\n",$block);
		print "\033[".$row++.";$column"."H".$_ foreach (@strs);
        $|=1;
	}
	
=head3 clear()
 clears screens
=cut	
	method clear(){
		system($^O eq 'MSWin32'?'cls':'clear');
		$buffer="\033[?c";
	}
	
=head3 stripColours($str)
   clears a string of any colours escape codes
=cut	
	
	method stripColours($block){
		my @strs=ref $block ? @$block  :  split("\n",$block);
		foreach (0..$#strs){
			$strs[$_]=~s/\033\[[^m]+m//g
		}
        return  ref $block?\@strs:join("\n",@strs);
	}
	
=head3 blank($block)
   makes a block of text blanks (spaces),  the block may be passed as a 
   ref to array of strings or a string separated by newlines;
   returns block in same format
=cut	
	method blank($block){
		$block= $self->stripColours($block);
		my @strs=ref $block ? @$block  :  split("\n",$block);
		foreach (0..$#strs){
			$strs[$_]=" " x length($self->stripColours($strs[$_]));
		}
		return ref $block?\@strs:join("\n",@strs);
	}
	
=head3 flash($block,$row,$column,$interval,$number)
   flash a block alternating between block and its blank.
   the interval in microseconds and the number of flashes are required
   even number of flashes means block is does not persist, odd number 
   means that the block remains after flashing
=cut	
	
	method flash($block,$row,$column,$interval,$number){
		my $blank=$self->blank($block);
		for (0..$number){
			$self->printAt($row,$column,$_%2?$block:$blank);
			sleep $interval;
		}
	}

=head trimBlock($block,$start,$length)
  left and right crop block, padding if needed
=cut

    method trimBlock($block,$start,$length){
		my @strs=ref $block ? @$block  :  split("\n",$block);
		foreach my $row (0..$#strs){
			$strs[$row]=substr($strs[$_],$start,$length);
			$strs[$row].=" " x ($length-length($strs[$row]));
		};
		return ref $block?\@strs:join("\n",@strs);
	}

	
=head3 largeNum($number)
prints a large version of the text (and currencies only)
=cut	
	method largeNum($number){
		my $lot=["","",""];
		foreach my $digit  (split //, $number){
			$digit="?" unless $bigNum->{$digit};  # if character doesnt exist
			foreach(0..2){
				$lot->[$_].=$bigNum->{$digit}->[$_]
			}
		}
		return $lot;
	}
	
	method center{
		my ($block,$minColumn,$maxColumn)=@_;
		unless ($minColumn || $maxColumn){
			$minColumn=0;
			$maxColumn=$dimensions->{width}; # change later to screenwidth
		}
		unless ($maxColumn){
			$maxColumn=$minColumn;
			$minColumn=0;
		}
		return if ($minColumn>$maxColumn) ;
		
		
	}
	
	method box{
		my %params=ref $_[0]?%$_[0]:@_;
		my $content =$params{content}//[""];  # $content converted to arrayRef
		$content=[split "\n",$content] unless (ref $content);
		my $width=$params{width}//$self->blockWidth($content);
		my $height=$params{height}//$self->blockHeight($content);
		$content=[@$content[0..$height-1]];
		$content=$self->trimBlock($content,0,$width);
		my %border=$borders->{$params{style}//"simple"};
		my @blck=($border{tl}.($border{t}x$width).$border{tr});
		for (0..$height-1){
			push @blck,$border{l}.(defined $content->[$_]?$content->[$_]:" "x$width).$border{r};
		}
		push @blck,$border{bl}.($border{t}x$width).$border{br};          
		return [@blck];
	}
	
}
