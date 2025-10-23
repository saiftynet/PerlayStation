## Card Games

### Objective
Create classes for Cards and Stacks and Tables that allow interactive manipulations of cards for games, such as 
bridge, poker, black jack, fish etc. These objects can be displayed on a terminal window and positioned as disired, 
eventually will have animations as well.


### Usage: 

```
# Multiple ways exist to create a Card
 my $card=new Card("Ace Of Spades");
 my $card=new Card("10","hearts");
 my $card=new Card({value=>"jack",suit=>"diamonds"});
 my $card=new Card({number=>"8",suit=>"c"});


# the card object can also have a position (default [0,0])
 my $card=new Card({number=>"8",suit=>"hearts"},4,8);
 my $card=new Card({number=>"8",suit=>"hearts"},[4,8]);

# Collections of cards use the Stack object

 my $deck=new Stack;
 $deck->fullDeck();
 my $player1=new Stack;
 $deck->shuffle()->deal($player1);
```

