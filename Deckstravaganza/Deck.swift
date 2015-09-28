//
//  Deck.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

class Deck: StackPile {
    override init() {
        super.init();
        
        newDeck();
    }
    
    override init(isTopAtFirstCard : Bool) {
        super.init(isTopAtFirstCard: isTopAtFirstCard);
        
        newDeck();
    }
    
    override init(oldPile : StackPile, isTopAtFirstCard : Bool = false) {
        super.init(oldPile: oldPile, isTopAtFirstCard: isTopAtFirstCard);
    }
    
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