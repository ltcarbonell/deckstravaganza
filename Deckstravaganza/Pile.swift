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
     * Insert the card at end of pile.
     *
     * @param card : Card - the card to be inserted into the pile
     */
    func addCard(card : Card) {
        pile.append(card);
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
}