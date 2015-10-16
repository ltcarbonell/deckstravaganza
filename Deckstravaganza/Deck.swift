//
//  Deck.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

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
    
    init(deckFront : DeckFronts, deckBack : DeckBacks) {
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
    
    init(isTopAtFirstCard : Bool, deckFront : DeckFronts, deckBack : DeckBacks) {
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
    func changeDeck(deckFront : DeckFronts? = nil, deckBack : DeckBacks? = nil) {
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
        
        for(var suitCounter = 0; suitCounter < Card.CardSuit.numberOfSuits; suitCounter++) {
            for(var valueCounter = 0; valueCounter < Card.CardRank.numberOfRanks; valueCounter++) {
                var suit : Card.CardSuit;
                var value : Card.CardRank;
                
                switch(suitCounter) {
                case 0:
                    suit = .Hearts;
                case 1:
                    suit = .Diamonds;
                case 2:
                    suit = .Clubs;
                case 3:
                    suit = .Spades;
                default:
                    suit = .Hearts;
                }
                
                switch(valueCounter) {
                case 0:
                    //Ace
                    value = .Ace;
                case 1:
                    value = .Two;
                case 2:
                    value = .Three;
                case 3:
                    value = .Four;
                case 4:
                    value = .Five;
                case 5:
                    value = .Six;
                case 6:
                    value = .Seven;
                case 7:
                    value = .Eight;
                case 8:
                    value = .Nine;
                case 9:
                    value = .Ten;
                case 10:
                    //Jack
                    value = .Jack;
                case 11:
                    //Queen
                    value = .Queen;
                case 12:
                    //King
                    value = .King;
                default:
                    value = .Joker;
                }
                
                self.pile.append(Card(suit: suit, rank: value));
            }
        }
        
        super.shuffle();
    }
}