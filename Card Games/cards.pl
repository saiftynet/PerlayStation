#!/usr/env perl;
use strict;use warnings;
use Object::Pad;
use lib "./lib/";
use Games::PerlayStation::Display;
use Games::PerlayStation::Cards; 
use utf8;
binmode(STDOUT, ":utf8");
my $d=new Display();


 my $deck=new Stack;
 $deck->fullDeck();
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
 $card=new Card({number=>"8",suit=>"clubs",pos=>[6,10]});
 $card->flip();
 $card->medium($d);
 $card=$deck->shuffle()->deal([7,11]);
 $card->set_face("up");
 $card->large($d);
 $deck->shuffle()->deal($player1);
