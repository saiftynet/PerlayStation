use Object::Pad;
use lib "../lib/";

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
