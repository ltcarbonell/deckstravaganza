//
//  Card.swift
//  Deckstravaganza
//
//  Created by Calvin Moore on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class Card {
    // Enumeration of legal card suits.
    enum CardSuit : Int {
        case clubs =    1;
        case diamonds = 2;
        case hearts =   3;
        case spades =   4;
        
        static let numberOfSuits = 4;
    }
    
    // Enumeration of legal card ranks and rank value.
    enum CardRank : Int {
        case ace =    1;
        case two =    2;
        case three =  3;
        case four =   4;
        case five =   5;
        case six =    6;
        case seven =  7;
        case eight =  8;
        case nine =   9;
        case ten =    10;
        case jack =   11;
        case queen =  12;
        case king =   13;
        
        case joker =  14;
        
        static let numberOfRanks = 13;
    }
    
    // Enumeration of legal card colors.
    enum CardColor : Int {
        case red =      1;
        case black =    2;
    }
    
    // All card properties are immutable and private.
    fileprivate let suit : CardSuit;
    fileprivate let rank : CardRank;
    
    // The color of the card is determined by the suit.
    fileprivate var color : CardColor {
        get {
            if(self.suit == .clubs || self.suit == .spades) {
                return CardColor.black;
            } else {
                return CardColor.red;
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
    * @return CardSuit - this card's suit
    */
    func getSuit() -> CardSuit {
        return self.suit;
    }
    
    /**
    * Return this card's rank.
    *
    * @return CardRank - this card's rank
    */
    func getRank() -> CardRank {
        return self.rank;
    }
    
    /**
    * Return this card's color.
    *
    * @return CardColor - this card's color
    */
    func getColor() -> CardColor {
        return self.color;
    }
    
    /**
    * Return true if and only if this card matches the specified card's rank.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool - true if both cards have the same rank
    */
    func hasSameRankAs(_ card : Card) -> Bool {
        return (self.rank == card.getRank());
    }
    
    /**
    * Return true if and only if this card matches the specified card's suit.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool - true if both cards have the same suit
    */
    func hasSameSuitAs(_ card : Card) -> Bool {
        return (self.suit == card.getSuit());
    }
    
    /**
    * Return true if and only if this card matches the specified card's color.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool - true if both cards have the same color
    */
    func hasSameColorAs(_ card : Card) -> Bool {
        return (self.color == card.getColor());
    }
    
    /**
    * Return true if and only if this card does not match the specified card's color.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool - true if this card has the opposite color of the specified card
    */
    func hasOppositeColorThan(_ card : Card) -> Bool {
        return (self.color != card.getColor());
    }
    
    /**
    * Return true if and only if this card has a higher rank than the specified card.
    *
    * @param card : Card - The card with which to compare this card.
    * @param acesLow : Bool - True if Aces should be considered low.
    * @return Bool - true if this card has a higher rank than the specified card
    */
    func isHigherThan(_ card : Card, acesLow : Bool) -> Bool {
        if(acesLow || (!acesLow && self.rank != .ace && card.getRank() != .ace)) {
            return (self.rank.rawValue < card.getRank().rawValue);
        } else {
            if(self.rank == .ace && card.getRank() != .ace) {
                return true;
            } else if(self.rank != .ace && card.getRank() == .ace) {
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
    * @return Bool - true if this card has a lower rank than the specified card
    */
    func isLowerThan(_ card : Card, acesLow : Bool) -> Bool {
        if(acesLow || (!acesLow && self.rank != .ace && card.getRank() != .ace)) {
            return (self.rank.rawValue > card.getRank().rawValue);
        } else {
            if(self.rank == .ace && card.getRank() != .ace) {
                return false;
            } else if(self.rank != .ace && card.getRank() == .ace) {
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
    * @param ignoreSuit : Bool (default true) - True if suit should not be considered; false otherwise.
    * @return Bool - true if this card is equal to the specified card
    */
    func isEqualTo(_ card : Card, ignoreSuit : Bool = true) -> Bool {
        if(ignoreSuit) {
            return (self.rank == card.getRank());
        } else {
            return (self.rank == card.getRank() && self.suit == card.getSuit());
        }
    }
    
    /**
    * Returns the face of this card.
    *
    * @param deckChoice : DeckFronts - the deck front being used by this deck to which this card belongs
    * @return UIImage? - the face of this card if found
    */
    func getCardFace(_ deckChoice : Deck.DeckFronts) -> UIImage? {
        let cardRank : String;
        let cardSuit : String;
        var cardOption : Deck.DeckFronts = deckChoice;
        
        switch(self.suit) {
            case .clubs:
                cardSuit = "clubs";
            case .diamonds:
                cardSuit = "diamonds";
            case .hearts:
                cardSuit = "hearts";
            case .spades:
                cardSuit = "spades";
        }
        
        switch(self.rank) {
            case .ace:
                cardRank = "ace";
            case .jack:
                cardRank = "jack";
            case .queen:
                cardRank = "queen";
            case .king:
                cardRank = "king";
            default:
                cardRank = String(self.rank.rawValue);
        }
        
        // The only difference between Deck1 and Deck2 are the Kings, Queens, and Jacks.
        if(self.rank.rawValue <= CardRank.ten.rawValue && cardOption == Deck.DeckFronts.Deck3 && !(self.rank
            == .ace && self.suit == .spades)) {
            cardOption = Deck.DeckFronts.Deck2;
        }
        
        let imageName = cardRank + "_" + cardSuit + "_" + cardOption.rawValue;
        return UIImage(named: imageName);
    }
    
    /**
    * Returns the back of this card.
    *
    * @param deckChoice : DeckBacks - the deck back being used by the deck to which this card belongs
    * @return UIImage? - the back of this card if found
    */
    func getCardBack(_ deckChoice : Deck.DeckBacks) -> UIImage? {
        let imageName = "back_" + deckChoice.rawValue;
        
        return UIImage(named: imageName);
    }
}
