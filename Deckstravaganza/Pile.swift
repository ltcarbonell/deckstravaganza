//
//  Pile.swift
//  Deckstravaganza
//
//  Created by Calvin Moore on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

class Pile {
    var pile : [Card];
    var name: String?
    
    init() {
        pile = [Card]();
    }
    
    /**
    * Randomizes the pile using the Fisher-Yates algorithm as proposed by Nate Cook
    * on StackOverflow at
    * http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift.
    */
    func shuffle() {
        let count = pile.count;
        
        for index in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - index))) + index;
            
            guard index != j else {
                continue;
            }
            
            swap(&pile[index], &pile[j])
        }
    }
    
    /**
     * Find the card and remove it.  If card is not in pile, nil is returned.
     *
     * @param card : Card - the index of the card to return in the pile
     * @return Card? - the card at index
     */
    func removeCard(card : Card) -> Card? {
        var index = -1
        for cardIndex in 0..<pile.count {
            if card.isEqualTo(pile[cardIndex], ignoreSuit:  false) {
                index = cardIndex
            }
        }
        if(index >= 0 && index < pile.count) {
            return removeCardAt(index);
        } else {
            return nil;
        }
    }
    
    
   /**
    * Return the card at index.  If index is out of bounds, nil is returned.
    *
    * @param index : Int - the index of the card to return in the pile
    * @return Card? - the card at index
    */
    func cardAt(index : Int) -> Card? {
        if(index >= 0 && index < pile.count) {
            return pile[index];
        } else {
            return nil;
        }
    }
    
    /**
     * Return and remove the card at index.  If index is out of bounds, nil is returned.
     *
     * @param index : Int - the index of the card to return in the pile
     * @return Card? - the card at index
     */
    func removeCardAt(index : Int) -> Card? {
        if(index >= 0 && index < pile.count) {
            return pile.removeAtIndex(index);
        } else {
            return nil;
        }
    }
    
    /**
     * Insert the card at index.  If index is out of bounds, card is appended.
     *
     * @param index : Int - the index of the card to insert in the pile
     * @param Card - the card at index
     */
    func insertCardAt(card: Card, index : Int) {
        if(index >= 0 && index < pile.count) {
            return pile.insert(card, atIndex: index);
        } else {
            return pile.append(card);
        }
    }
    
    /**
     * Append the card at end of pile.
     *
     * @param card : Card - the card to be inserted into the pile
     */
    func appendCard(card : Card) {
        pile.append(card);
    }
    
    /**
     *
     * Return true if and only if the pile contains the card.
     *
     * @param card: Card - the card being searched for
     * @ return Bool
     */
     
    func contains(card: Card) -> Bool {
        for searchCard in pile {
            if card.isEqualTo(searchCard, ignoreSuit: false) {
                return true
            }
        }
        return false
    }
    
    /**
    * Return true if and only if the pile is empty.
    *
    * @return Bool
    */
    func isEmpty() -> Bool {
        return pile.isEmpty;
    }
    
    /**
    * Remove all cards from the pile.
    */
    func removeAllCards() {
        pile.removeAll();
    }
    
    /**
     * Return the number of cards in this pile.
     *
     * @return Bool
     */
    func numberOfCards() -> Int {
        return pile.count;
    }
    
    /**
     * Sort the cards in this pile by their rank.
     *
     * @param card: acesLow: Bool - True if Aces should be considered low.
     */
    func sortByRank(acesLow: Bool) {
        pile.sortInPlace { (card1: Card, card2: Card) -> Bool in
            return card1.isHigherThan(card2, acesLow: acesLow)
        }
    }
    
    /**
     * Sort the cards in this pile by their suit.
     * Places priority order as Spades, Hearts, Diamonds, Clubs
     *
     * @return Bool
     */
    func sortBySuit() {
        pile.sortInPlace { (card1: Card, card2: Card) -> Bool in
            return card1.getSuit().hashValue < card2.getSuit().hashValue
        }
    }
}