#!/usr/env perl
use strict;use warnings;
use utf8;
binmode( STDOUT, ":encoding(UTF-8)" );

my $mapString=<<END;
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e                                   w           w           e
e           wwgwwgwwgwwwgw          r           y           e
e           b                       w           w           e
e           w           rwrwrwrwrwrwwwrw        y           e
e           b                 w                 w           e
ebwbwb      w                 m         ywywywywwwmgww      e
e           b           wwmwmww                      m      e
e     bwbwbww           m         t       rbrbwr     g      e
e           wwmwm    wmww                 w    b     w      e
e           w           y        ww            r     m      e
e           r          wwymymymymww      brbrbrb     g      e
e    wrwrwrww                                        w      e
e                                  wwywrwywrwywrwywrwm      e
e       wwwwwwbwrwywmwbwr            w                      e
e            w                       w               w      e
e            r             wwgwwmwwgwwmwwgwwmww      r      e
e            w                                       w      e
e            m                                       m      e
e            wwbwwrwwrwwrwwrwwrwwrwwrww     rwwgwwwbww      e
e            w                                              e
e            w                                              e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
END


my $ui=new UI;
setupUI();

my $mode="3d";
my $screenHeight=($ui->{windowHeight}*4-30)//100 ;  # dimensions of 3d graphical maze
my $screenWidth =($ui->{windowWidth}*2-40)//180;    # dimensions of 3d graphical maze
my $hOffset= 10;
my $vOffset=4;
my $map= buildMap();
my $player={position=>[5,5],dir=>0.1,fov=>1,character=>"P"};
my $colIndex={w=>37,e=>32,y=>93,r=>31,b=>94,g=>32,m=>35,t=>[5,35],title=>[47,91],instructions=>[47,34]};

clearScreen();
drawTitle();
rayD();
$ui->run("default");  # start interactivity

sub drawTitle{
	my $line=1;
	printAt([$line++,$ui->{windowWidth}/2-3], paint("   3D Maze   ",$colIndex->{title}));
	foreach("  Arrowkeys = Forward,Backwards,Turn Left,Turn Right  ",
            "       A = Side Step Left   D = Side Step Right       "){
       	printAt([$line++,($ui->{windowWidth}-length $_)/2], paint($_,$colIndex->{instructions}));
	}
}

# this routine draws rays from the player and gets distances to 
# the obstacle the ray encounters. it returns a listref of hashes
# containing the distance, the type of object hit, whether it is
# on an "odd" position, and whether it is on the edge of the object
sub rayD{
	my $collection=[[$player->{position},$player->{character}]];
	my $columns=$screenWidth;
	my @distances=();
	my $startDir= $player->{dir}-$player->{fov}/2;
	my $endDir  = $player->{dir}+$player->{fov}/2;
	my $steps   = ($endDir-$startDir)/$columns;
	for (my $rayDir=$startDir;$rayDir<$endDir;$rayDir+=$steps){
				my $uv=[0.1*cos($rayDir),0.1*sin($rayDir)];
				my $ray=$player->{position};
				my $hit=collision($ray);
				while($hit=~/[P\s]/ && !outside($map,$ray)){
					$ray=Add($ray,$uv);
					$hit=collision($ray);
				}
				$collection=[@$collection,[$ray,uc $hit]];
				push @distances,[distance($ray,$player->{position}),$hit,corner($ray),odd($ray)];
			}
	if ($mode eq "map") {draw2D($collection)}
	else{draw3D([@distances])};
	drawStatus();
}

# this takes the list of distances and draws walls in 3d
# painting and shading them.
sub draw3D{
	my ($distances)=@_;
	my $view=grid($screenWidth,$screenHeight);
	my $colours;
	my $w=1;
	foreach my $d(@$distances){
		$w++;
		next unless $d->[0]; # prevent divide by zero if next to wall
		# next if $d->[2]; # edges dont draw
		my $height=int(($screenHeight)/$d->[0]);
		$height=$screenHeight if $height>$screenHeight;
		my $gap=int(($screenHeight-$height)/2+.5);
		for(my $y=$gap;$y<$height+$gap;$y+=1+$d->[3]){
			# plot wall, but makes the edges ($d->][1] eq "e") lighter (edge of map)
			$colours->[int $y/4]->[int ($w/2)]=$colIndex->{$d->[1]} if $w%2;
			plot ($view,[$w,$y]) unless $w%2 && ($d->[1] eq "e");
		}
	}
	draw($view,$colours);
}

# the status bar
sub drawStatus{
	my $status=" Player position=".toString($player->{position}).
          "   Player dir=".sprintf("%.2f",$player->{dir}).
          "   Objective: Find Blinking purple target\r";
	printAt([$vOffset+$screenHeight/4,($ui->{windowWidth}-length $status)/2],$status);
}

# A 2d view is also possible, for debugging purposes,
# it capitalises and paints the walls that can be seen
sub draw2D{
	my ($overlay)=@_;
	my $tmp=buildMap();
    system($^O eq 'MSWin32'?'cls':'clear');
	foreach (@$overlay){
		insert($tmp,@$_)
	}
	foreach my $row (@$tmp){
		foreach (@$row) {
			$_=~s/([A-OQ-Z])/\033[32m$1\033[0m/g;
			print;
		}
		print"\n\r";
	};
}

sub paint{
	my ($text,$colr)=@_;
	return $text unless $colr || $mode eq "monochrome";
	$colr=join("m\033[",@$colr) if ref $colr;
	return "\033[".$colr."m".$text."\033[0m";
}

sub printAt{
	my ($location,$text)=@_;
	my @out=ref $text?@$text:($text);
	my ($line,$column)=@$location;
	print "\033[".int ($line++).";".int($column)."H".$_ foreach(@out);
}

sub clearScreen{
    system($^O eq 'MSWin32'?'cls':'clear');
}


sub corner{ # is the part of the wall hit near a corner
	my $point=shift;
	return ((abs($point->[1]-int ($point->[1]+.5))<0.08)&&(abs($point->[0]-int ($point->[0]+.5))<0.08))
}

sub odd{ # detect whether odd or even block for shading;
	my $point=shift;
	return (int $point->[1] + int $point->[0])%2;
}

sub collision{  # see if point is at wall or edge
	my $point=shift;
	return 1 if  outside($map,$point) ;
	return $map->[int $point->[1]]->[int $point->[0]];#; =~/[^\sP]/?1:0;
}

sub movePlayer{ # move the player if possible, identify target found
	my $newPos=shift;
	my $occupied=collision($newPos);
	$player->{position}=$newPos if $occupied=~/[P\s]/ ;
	targetCaptured() if $occupied=~/t/;
}

sub targetCaptured{
	printAt([($vOffset+$screenHeight/4)/2,($ui->{windowWidth}-40)/2],
	         ["*****************************************",
	          "*             Target Found!            **",
	          "*****************************************"]);
     printAt([$vOffset+$screenHeight/4,($ui->{windowWidth}-10)/2],"");
     system("stty","sane");
     $ui->stop();
     exit;
}

sub buildMap{
	my @rows=split(/\n/,$mapString);
	return [map{[split //]}@rows];
}

sub insert{ # insert a character in the map position
	my ($map,$vector,$char)=@_;
	$map->[int($vector->[1])]->[int($vector->[0])]=$char;
}
###  Bitvector routines follow

sub grid{ # create a bitvector array
   my ($width,$height)=@_;
   my $temp;vec( $temp, $width, 1 ) = 0;
   return [map{$temp}(0..$height)];
}

# this function converts a bit vector array in a array of braille characters
# and draws the array to the console
sub draw {
    my ($grid,$colours ) = @_;
    use integer;
    my $width=((length $grid->[0])-1)*8;
    my $height=$#$grid-($#$grid%4);
    my @block = ();  # the grid of braille characters
    for ( my $y = 0 ; $y < $height  ; $y += 4 ) {
        my $r = "";
        for ( my $x = 0 ; $x < $width ; $x += 2 ) {
			my $colr=$colours->[int $y/4]->[int $x/2]//0;
			$colr="\033[".join("m\033[",@$colr) if ref $colr;
			my ($col,$res)=("\033[".$colr."m","\033[0m");
            $r .= $col.chr(0x2800 | oct(
              "0b". vec( $grid->[ $y + 3 ], $x + 1, 1 )
                  . vec( $grid->[ $y + 3 ], $x,     1 )
                  . vec( $grid->[ $y + 2 ], $x + 1, 1 )
                  . vec( $grid->[ $y + 1 ], $x + 1, 1 )
                  . vec( $grid->[$y],       $x + 1, 1 )
                  . vec( $grid->[ $y + 2 ], $x,     1 )
                  . vec( $grid->[ $y + 1 ], $x,     1 )
                  . vec( $grid->[$y],       $x,     1 ) 
				)
			).
				$res;
        }
        push @block, $r;
    }
    my $line=$vOffset;
    print "\033[".$line++.";".$hOffset."H".$_ foreach(@block );
}

sub outside{ # test whether the vector is outside the bit vector array
	my ($grid,$vector)=@_;
	my $bound="";
	if ($vector->[0]>=@{$grid->[0]}){ $bound.="X+"}
	elsif ($vector->[0]<0){$bound.= "X-"};
	if ($vector->[1]>=@$grid){$bound.= "Y+"}
	elsif ($vector->[1]<0){$bound.="Y-"};
	return $bound;
}

sub toString{  # for debugging, evctor to a string;
	return "[".join(",", map {sprintf("%.2f",$_)}@{$_[0]})."]";
}

sub Add{  # add two vectors
	my($vector1,$vector2)=@_;
	return [map {$vector1->[$_]+$vector2->[$_]} (0..$#$vector1)];
}

sub distance{ # vector displacements to scalar 
	my ($vec1,$vec2)=@_;
	return sqrt(($vec1->[0]-$vec2->[0])*($vec1->[0]-$vec2->[0])+($vec1->[1]-$vec2->[1])*($vec1->[1]-$vec2->[1]));
}

sub plot { # plot pixel in a bitvector array
    my ( $grid, $vec ) = @_;
    die  toString($vec) if outOfBounds($grid,$vec);
    vec( $grid->[ $vec->[1] ], $vec->[0], 1 ) = 1;
}

sub outOfBounds { # ensure the vector does not go out of the bitvector array
    my ( $grid, $vec ) = @_;
    return 1 if $vec->[0] > 8*(length $grid->[0]);
    return 2 if $vec->[1] > @$grid;
    return 3 if $vec->[0] < 0;
    return 4 if $vec->[1] < 0;
    return 0;
}

sub setupUI{  # setup the UI
	    my $keyActions={
        default=>{
            'rightarrow'=>sub{$player->{dir}+=.1 ;},  # turn right
            'leftarrow' =>sub{$player->{dir}-=.1 ;},  # turn left 
            'uparrow'   =>sub{   # forwards
				     movePlayer([$player->{position}->[0]+.5*cos($player->{dir}),
				              $player->{position}->[1]+.5*sin($player->{dir})]) },
            'downarrow' =>sub{   # backwards
				     movePlayer([$player->{position}->[0]-.5*cos($player->{dir}),
				              $player->{position}->[1]-.5*sin($player->{dir})]) },
            'd'   =>sub{         # sidestep right
				     movePlayer([$player->{position}->[0]-.5*sin($player->{dir}),
				              $player->{position}->[1]+.5*cos($player->{dir})]) },
            'a' =>sub{           # sidestep left
				    movePlayer([$player->{position}->[0]+.5*sin($player->{dir}),
				              $player->{position}->[1]-.5*cos($player->{dir})]) },
            'pagedown'  =>sub{},
            'pageup'    =>sub{},
            'tab'       =>sub{},
            'shifttab'  =>sub{},
            '#'         =>sub{},
            "updateAction"=>sub{rayD()},      # this action defines the screen update action
            "windowChange"=>sub{},            # tyhis defines what to do when screen size changes
            "m"           =>sub{$mode=($mode eq "map")?"3D":"map"}, # toggle between 2d and 3d},
        },
    };
	foreach my $k (keys %{$keyActions->{default}}){
            $ui->setKeyAction("default",$k,$keyActions->{"default"}->{$k});
    }
}

package UI;    
#######################################################################################
#####################   User Interaction Object #######################################
#######################################################################################

sub new{
    my $class=shift;
    $| = 1;
    my $self={};
    $self->{$_}= '' for (qw/update windowWidth windowHeight stty mode buffer run/);
    $self->{$_}={} for (qw/namedKeys actions mapping/);
    $self->{namedKeys}=setKeys();
    bless $self, $class;
    $self->get_terminal_size;
    $SIG{WINCH} = sub {$self->winSizeChange();};
    return $self;
}

sub run{
    my ($self,$mode)=@_;
    $self->{mode}=$mode//"default";
    $self->{run}=1;
    $self->get_terminal_size();
    binmode(STDIN);
    $self->ReadMode(5);
    my $key;
    while ($self->{run}) {
        last if ( !$self->dokey($key) );
        $self->{actions}->{$self->{mode}}->{updateAction}->() // $self->updateAction() if ($self->{update}); # update screen
        $self->{update}=0;
        $key = $self->ReadKey();
    }
    $self->ReadMode(0);
    print "\n";
}


sub stop{
    my $self=shift;
    $self->{run}=0;
    $| = 1;
}

sub setKeys {# gives the keys pressed a name
    return {
        32     =>  'space',
        13     =>  'return',
        9      =>  'tab',
        '[Zm'  =>  'shifttab',
        '[Am'  =>  'uparrow',
        '[Bm'  =>  'downarrow',
        '[Cm'  =>  'rightarrow',
        '[Dm'  =>  'leftarrow',
        '[Hm'  =>  'home',
        '[2~m' =>  'insert',
        '[3~m' =>  'delete',
        '[Fm'  =>  'end',
        '[5~m' =>  'pageup',
        '[6~m' =>  'pagedown',
        '[Fm'  =>  'end',
        'OPm'  =>  'F1',
        'OQm'  =>  'F2',
        'ORm'  =>  'F3',
        'OSm'  =>  'F4',
        '[15~m'=> 'F5',
        '[17~m'=> 'F6',
        '[18~m'=> 'F7',
        '[19~m'=> 'F8',
        '[21~m'=> 'F10',
        '[24~m'=> 'F12',
    };    
}

sub dokey {
    my ($self,$key) = @_;
    return 1 unless (defined $key);
    my $ctrl = ord($key);my $esc="";
    return if ($ctrl == 3);                 # Ctrl+c = exit;
    my $pressed="";
    if ($ctrl==27){
        while ( my $key = $self->ReadKey() ) {
           $esc .= $key;
           last if ( $key =~ /[a-z~]/i );
        }
        if ($esc eq "O"){# F1-F5
           while ( my $key = $self->ReadKey() ) {
             $esc .= $key;
             last if ( $key =~ /[a-z~]/i );
           }
            
        }    
        $esc.="m"
    };
    
    if (exists $self->{namedKeys}->{$ctrl}){$pressed=$self->{namedKeys}->{$ctrl}}
    elsif (exists $self->{namedKeys}->{$esc}){$pressed=$self->{namedKeys}->{$esc}}
    else{$pressed= ($esc ne "")?$esc:chr($ctrl);};
    $self->act($pressed,$key);    
    return 1;
}

sub act{ 
    my ($self,$pressed,$key)=@_;
    if ($self->{actions}->{$self->{mode}}->{$pressed}){
        $self->{actions}->{$self->{mode}}->{$pressed}->();
    }
    else{
        $self->{buffer}//="";
        $self->{buffer}.=$key;
    } 
    $self->stop() if ($pressed eq "Q");
    print $pressed if $self->{debug};
    $self->{update}=1;
    
}

sub get_terminal_size {
    my $self=shift;
    if ($^O eq 'MSWin32'){
        `chcp 65001\n`;
        my $geometry=(split("\n", `powershell -command "&{(get-host).ui.rawui.WindowSize;cls}"`))[3];
        ($self->{windowHeight}, $self->{windowWidth})=(split(/\s+/,$geometry))[1,2];
    }
    else{    
        ( $self->{windowHeight}, $self->{windowWidth} ) = split( /\s+/, `stty size` );
        $self->{windowHeight} -= 2;
    }
}

sub winSizeChange{
    my $self=shift;
    $self->get_terminal_size();
    $self->{actions}->{$self->{mode}}->{"windowChange"}->() if $self->{actions}->{$self->{mode}}->{"windowChange"}->();
}

sub ReadKey {
    my $self=shift;
    my $key = '';
    sysread( STDIN, $key, 1 );
    return $key;
}

sub ReadLine { return <STDIN>;}

sub ReadMode {
    my ($self,$mode)=@_;
    if ( $mode == 5 ) {  
        $self->{stty} = `stty -g`;
        chomp($self->{stty});
        system( 'stty', 'raw', '-echo' );# find Windows equivalent
    }
    elsif ( $mode == 0 ) {
        system( 'stty', $self->{stty} ); # find Windows equivalent
    }
}

### actions to update the screen need to be setup for interactive applications 
sub setKeyAction{
    my ($self,$mode,$key,$uAction)=@_;
    $self->{actions}->{$mode}->{$key}=$uAction;
}

sub updateAction{
    print "\n\r";
}
