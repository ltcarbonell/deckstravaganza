//
//  QueuePile.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 9/21/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

class QueuePile: Pile {
    let frontAtFirstCard : Bool;
    
    override init() {
        frontAtFirstCard = true;
        
        super.init();
    }
    
    init(isFrontAtFirstCard : Bool) {
        frontAtFirstCard = isFrontAtFirstCard;
        
        super.init();
    }
    
    init(oldPile : QueuePile, isFrontAtFirstCard : Bool) {
        frontAtFirstCard = isFrontAtFirstCard;
        
        super.init();
        
        while(!oldPile.isEmpty()) {
            if(frontAtFirstCard) {
                pile.append(oldPile.dequeue()!);
            } else {
                pile.insert(oldPile.dequeue()!, atIndex: 0);
            }
        }
    }
    
    /**
    * Add newCard to the back of the pile.
    *
    * @param newCard : Card - card to add to the pile.
    */
    func enqueue(newCard : Card) {
        if(frontAtFirstCard) {
            pile.append(newCard);
        } else {
            pile.insert(newCard, atIndex: 0);
        }
    }
    
    /**
    * Remove the first card in the queue.
    *
    * @return Card? - the card removed from the queue
    */
    func dequeue() -> Card? {
        if(frontAtFirstCard) {
            return pile.removeAtIndex(0);
        } else {
            return pile.popLast();
        }
    }
    
    /**
    * Return the card at the front of the queue.
    *
    * @return Card? - the card at the front of the queue
    */
    func frontCard() -> Card? {
        if(frontAtFirstCard) {
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
    * Enqueue all the cards in newPile starting at the first card of the pile.  The first
    * card is defined as the card that has its back facing away from all the other cards.
    * This operation removes all cards from newPile.
    *
    * @param newPile : Pile - the pile to add to this pile
    */
    func addToQueueFromFirstCardOf(newPile : Pile) {
        for(var index = 0, cardCount = newPile.numberOfCards(); index < cardCount; index++) {
            self.enqueue(newPile.cardAt(index)!);
        }
        
        newPile.removeAllCards();
    }
    
    /**
    * Enqueue all the cards in newPile starting at the last card of the pile.  The last
    * card is defined as the card that has its face side facing away from all the other cards.
    * This operation removes all cards from newPile.
    *
    * @param newPile : Pile - the pile to add to this pile
    */
    func addToQueueFromLastCardOf(newPile : Pile) {
        for(var index = 0, cardCount = newPile.numberOfCards(); index < cardCount; index++) {
            self.enqueue(newPile.cardAt(cardCount - 1 - index)!);
        }
        
        newPile.removeAllCards();
    }
}