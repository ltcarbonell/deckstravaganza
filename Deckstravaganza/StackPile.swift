//
//  StackPile.swift
//  Deckstravaganza
//
//  Created by Calvin Moore on 9/21/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class StackPile: Pile {
    /**
    * True if the top of the stack is at the first card.  The first
    * card is defined as the card that has its back facing away from
    * all the other cards.
    */
    private let topAtFirstCard : Bool;
    
    override init() {
        topAtFirstCard = false;
        
        super.init();
    }
    
    init(isTopAtFirstCard : Bool) {
        topAtFirstCard = isTopAtFirstCard;
        
        super.init();
    }
    
    init(oldPile : StackPile, isTopAtFirstCard : Bool = false) {
        topAtFirstCard = isTopAtFirstCard;
        
        super.init();
        
        if(topAtFirstCard) {
            while(!oldPile.isEmpty()) {
                pile.insert(oldPile.pull()!, atIndex: 0);
            }
        } else {
            while(!oldPile.isEmpty()) {
                pile.append(oldPile.pull()!);
            }
        }
    }
    
    /**
    * Push newCard to the top of the stack.
    *
    * @param newCard : Card - the card to insert at the top of the stack
    */
    func push(newCard : Card) {
        if(topAtFirstCard) {
            pile.insert(newCard, atIndex: 0);
        } else {
            pile.append(newCard);
        }
    }
    
    /**
    * Remove and return the card at the top of the stack.
    *
    * @return Card? - the card at the top of the stack.
    */
    func pull() -> Card? {
        if(topAtFirstCard) {
            return pile.removeAtIndex(0);
        } else {
            return pile.popLast();
        }
    }
    
    /**
    * Return the card at the top of the stack.
    *
    * @return Card? - the card at the top of the stack.
    */
    func topCard() -> Card? {
        if(topAtFirstCard) {
            if(!pile.isEmpty) {
                return pile[0];
            } else {
                return nil;
            }
        } else {
            return pile.last;
        }
    }
    
    /**
    * Push all the cards in newPile starting at the first card of the pile.  The first
    * card is defined as the card that has its back facing away from all the other cards.
    * This operation removes all cards from newPile.
    *
    * @param newPile : Pile - the pile to add to this pile
    */
    func addToStackFromFirstCardOf(newPile : Pile) {
        for(var index = 0, cardCount = newPile.numberOfCards(); index < cardCount; index++) {
            self.push(newPile.cardAt(index)!);
        }
        
        newPile.removeAllCards();
    }
    
    /**
    * Push all the cards in newPile starting at the last card of the pile.  The last
    * card is defined as the card that has its face side facing away from all the other cards.
    * This operation removes all cards from newPile.
    *
    * @param newPile : Pile - the pile to add to this pile
    */
    func addToStackFromLastCardOf(newPile : Pile) {
        for(var index = 0, cardCount = newPile.numberOfCards(); index < cardCount; index++) {
            self.push(newPile.cardAt(cardCount - 1 - index)!);
        }
        
        newPile.removeAllCards();
    }
}