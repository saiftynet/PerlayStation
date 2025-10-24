## Card Games

### Objective
Create classes for Cards and Stacks and Tables that allow interactive manipulations of cards for games, such as 
bridge, poker, blackjack, fish etc. These objects can be displayed on a terminal window and positioned as desired, 
eventually will have animations as well.  Some compatibility with the well established [Games::Cards](https://metacpan.org/pod/Games::Cards) 
is expected, but that is not the primary goal of this project.  


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

### Cards Class

Cards have `$rank` ([A,2,3,..K, `$suit`, `$position` (location on terminal window), `$face` ("up" or "down"),
Cards can be displayed (as single UTF8 character, as 3 rows of characters, or of arbitrary sizes.) at a location on the screen.
This allows games where only a few cards need to be shown at a time, or when a large number of cards need to be shown.
There are multiple ways to ceate a card at the moment; these will be reduced once an idea of what is best is decided.
Cards may have a $packColour defined.  Some compatiblity with existing [Games::Cards](

### Stack Class

This allows creation of compilations of cards, e.g. an entire deck, of a players hands
The cards methods include `shuffle()`, `deal`([$position or $stack]) to a position on the table, or to another stack,
displayed face down/up, 

### Display.pm

This contains the primitives for decorating character strings and blitting blocks or entire screens to the terminal window.


### Versions

* 0.01
First extremely buggy submission.





