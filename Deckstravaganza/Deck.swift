//
//  Deck.swift
//  Deckstravaganza
//
//  Created by Calvin Moore on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class Deck: StackPile {
    enum DeckFronts : String {
        case Default =   "a";
        case Deck2 =     "b";
        case Deck3 =     "2b";
    }
    
    enum DeckBacks : String {
        case Default =      "a";
        case SolidBlue =    "b";
        case SolidBlack =   "c";
        case PatternBlue =  "d";
    }
    
    var frontType : DeckFronts;
    var backType : DeckBacks;
    
    override init() {
        frontType = .Default;
        backType = .Default;
        
        super.init();
        
        newDeck();
    }
    
    init(deckFront : DeckFronts = .Default, deckBack : DeckBacks = .Default) {
        frontType = deckFront;
        backType = deckBack;
        
        super.init();
        
        newDeck();
    }
    
    override init(isTopAtFirstCard : Bool) {
        frontType = .Default;
        backType = .Default;
        
        super.init(isTopAtFirstCard: isTopAtFirstCard);
        
        newDeck();
    }
    
    init(isTopAtFirstCard : Bool, deckFront : DeckFronts = .Default, deckBack : DeckBacks = .Default) {
        frontType = deckFront;
        backType = deckBack;
        
        super.init(isTopAtFirstCard: isTopAtFirstCard);
        
        newDeck();
    }
    
    override init(oldPile : StackPile, isTopAtFirstCard : Bool = false) {
        frontType = .Default;
        backType = .Default;
        
        super.init(oldPile: oldPile, isTopAtFirstCard: isTopAtFirstCard);
    }
    
    init(oldPile : StackPile, deckFront : DeckFronts, deckBack : DeckBacks, isTopAtFirstCard : Bool = false) {
        frontType = deckFront;
        backType = deckBack;
        
        super.init(oldPile: oldPile, isTopAtFirstCard: isTopAtFirstCard);
    }
    
    /**
    * Change the deck style chosen.
    *
    * @param deckFront : DeckFronts (default nil) - the new DeckFronts style to use.  If nil, the current style remains.
    * @param deckBack : DeckBacks (default nil) - the new DeckBacks style to use.  If nil, the current style remains.
    */
    func changeDeck(_ deckFront : DeckFronts? = nil, deckBack : DeckBacks? = nil) {
        if(deckFront != nil) {
            frontType = deckFront!;
        }
        
        if(deckBack != nil) {
            backType = deckBack!;
        }
    }
    
    /**
    * Creates a new deck and shuffles the cards.
    */
    func newDeck() {
        self.pile.removeAll();
        
        for suitCounter in 0 ..< Card.CardSuit.numberOfSuits  {
            for valueCounter in 0 ..< Card.CardRank.numberOfRanks  {
                var suit : Card.CardSuit;
                var value : Card.CardRank;
                
                switch(suitCounter) {
                case 0:
                    suit = .hearts;
                case 1:
                    suit = .diamonds;
                case 2:
                    suit = .clubs;
                case 3:
                    suit = .spades;
                default:
                    suit = .hearts;
                }
                
                switch(valueCounter) {
                case 0:
                    //Ace
                    value = .ace;
                case 1:
                    value = .two;
                case 2:
                    value = .three;
                case 3:
                    value = .four;
                case 4:
                    value = .five;
                case 5:
                    value = .six;
                case 6:
                    value = .seven;
                case 7:
                    value = .eight;
                case 8:
                    value = .nine;
                case 9:
                    value = .ten;
                case 10:
                    //Jack
                    value = .jack;
                case 11:
                    //Queen
                    value = .queen;
                case 12:
                    //King
                    value = .king;
                default:
                    value = .joker;
                }
                
                self.pile.append(Card(suit: suit, rank: value));
            }
        }
        
        super.shuffle();
    }
}
