#!/usr/bin/perl
$@='Just Another Perl Hacker';$@=length($@);
$|=abs(2-$@);goto f;z:if(int(rand(10))>5){($-
,$.)=($",$;);}else{($-,$.)=($",$;);}@b =();$b
[0] = $-;if($- ==$;){$b[1]=1;}else{$b[1]=7 +
50 + 10 + (5 * 2);}$,='l';$,='r'if$-==$";$vd
 ='u';$vd='d'if int(rand(10))<5;while($|){my
$s="";foreach $%(0 .. 22){foreach$=(0 .. 78)
{if($===39){$s.="|";}if($%==$;&& $===0){$s.=
"]";}elsif($===$b[1]&& $%==$b[0]){$s.= "*";}
elsif($===78&& $%==$"){$s.="[\n";}elsif($===
78){$s.=" \n";}else{$s.=" ";}}}print $s;#### 
$b[1]==1 and$,='r';$b[1]==77 and$,='l';$b[0]
== 23 and$vd='u';$b[0]==0 and$vd='d';if($,eq
'r'){$b[1]++;$mp=\$";}if($, eq'l'){$b[1]--;#
$mp=\$;;}if($vd eq'u'){$b[0]--;$$mp-- unless
$$mp==0;}if($vd eq'd'){$b[0]++;$$mp++ unless
$$mp == 22;}select $`,$`,$`,.05;system($^);}
f:$^='clear';$"=int(rand(22));$;=int(rand(22
));$^='cls'if$^O=~m|win|i;goto z;###########
