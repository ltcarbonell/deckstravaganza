//
//  Card.swift
//  Deckstravaganza
//
//  Created by Calvin Moore on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

class Card {
    // Enumeration of legal card suits.
    enum CardSuit : Int {
        case Clubs =    1;
        case Diamonds = 2;
        case Hearts =   3;
        case Spades =   4;
    }
    
    // Enumeration of legal card ranks and rank value.
    enum CardRank : Int {
        case Ace =    1;
        case Two =    2;
        case Three =  3;
        case Four =   4;
        case Five =   5;
        case Six =    6;
        case Seven =  7;
        case Eight =  8;
        case Nine =   9;
        case Ten =    10;
        case Jack =   11;
        case Queen =  12;
        case King =   13;
    }
    
    // Enumeration of legal card colors.
    enum CardColor : Int {
        case Red =      1;
        case Black =    2;
    }
    
    // All card properties are immutable and private.
    private let suit : CardSuit;
    private let rank : CardRank;
    
    // The color of the card is determined by the suit.
    private var color : CardColor {
        get {
            if(self.suit == .Clubs || self.suit == .Spades) {
                return CardColor.Black;
            } else {
                return CardColor.Red;
            }
        }
    }
    
    init(suit : CardSuit, rank : CardRank) {
        self.suit = suit;
        self.rank = rank;
    }
    
    /**
    * Return this card's suit.
    *
    * @return CardSuit
    */
    func getSuit() -> CardSuit {
        return self.suit;
    }
    
    /**
    * Return this card's rank.
    *
    * @return CardRank
    */
    func getRank() -> CardRank {
        return self.rank;
    }
    
    /**
    * Return this card's color.
    *
    * @return CardColor
    */
    func getColor() -> CardColor {
        return self.color;
    }
    
    /**
    * Return true if and only if this card matches the specified card's rank.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool
    */
    func hasSameRankAs(card : Card) -> Bool {
        return (self.rank == card.getRank());
    }
    
    /**
    * Return true if and only if this card matches the specified card's suit.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool
    */
    func hasSameSuitAs(card : Card) -> Bool {
        return (self.suit == card.getSuit());
    }
    
    /**
    * Return true if and only if this card matches the specified card's color.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool
    */
    func hasSameColorAs(card : Card) -> Bool {
        return (self.color == card.getColor());
    }
    
    /**
    * Return true if and only if this card does not match the specified card's color.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool
    */
    func hasOppositeColorThan(card : Card) -> Bool {
        return (self.color != card.getColor());
    }
    
    /**
    * Return true if and only if this card has a higher rank than the specified card.
    *
    * @param card : Card - The card with which to compare this card.
    * @param acesLow : Bool - True if Aces should be considered low.
    * @return Bool
    */
    func isHigherThan(card : Card, acesLow : Bool) -> Bool {
        if(acesLow || (!acesLow && self.rank != .Ace && card.getRank() != .Ace)) {
            return (self.rank.rawValue < card.getRank().rawValue);
        } else {
            if(self.rank == .Ace && card.getRank() != .Ace) {
                return true;
            } else if(self.rank != .Ace && card.getRank() == .Ace) {
                return false;
            } else {
                return false;
            }
        }
    }
    
    /**
    * Return true if and only if this card has a lower rank than the specified card.
    *
    * @param card : Card - The card with which to compare this card.
    * @param acesLow : Bool - True if Aces should be considered low.
    * @return Bool
    */
    func isLowerThan(card : Card, acesLow : Bool) -> Bool {
        if(acesLow || (!acesLow && self.rank != .Ace && card.getRank() != .Ace)) {
            return (self.rank.rawValue > card.getRank().rawValue);
        } else {
            if(self.rank == .Ace && card.getRank() != .Ace) {
                return false;
            } else if(self.rank != .Ace && card.getRank() == .Ace) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    /**
    * If ignoreSuit is true or not specified, return true if and only if this card's
    * rank matches the specified card's rank.  If ignoreSuit is false, return true if
    * and only if this card's rank and suit matches the specified card's rank and
    * suit.
    *
    * @param card : Card - The card with which to compare this card.
    * @param acesLow : Bool - True if Aces should be considered low.
    * @return Bool
    */
    func isEqualTo(card : Card, ignoreSuit : Bool = true) -> Bool {
        if(ignoreSuit) {
            return (self.rank == card.getRank());
        } else {
            return (self.rank == card.getRank() && self.suit == card.getSuit());
        }
    }
}