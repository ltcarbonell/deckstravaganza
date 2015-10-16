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
        case Clubs =    1;
        case Diamonds = 2;
        case Hearts =   3;
        case Spades =   4;
        
        static let numberOfSuits = 4;
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
        
        case Joker =  14;
        
        static let numberOfRanks = 13;
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
    func hasSameRankAs(card : Card) -> Bool {
        return (self.rank == card.getRank());
    }
    
    /**
    * Return true if and only if this card matches the specified card's suit.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool - true if both cards have the same suit
    */
    func hasSameSuitAs(card : Card) -> Bool {
        return (self.suit == card.getSuit());
    }
    
    /**
    * Return true if and only if this card matches the specified card's color.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool - true if both cards have the same color
    */
    func hasSameColorAs(card : Card) -> Bool {
        return (self.color == card.getColor());
    }
    
    /**
    * Return true if and only if this card does not match the specified card's color.
    *
    * @param card : Card - The card with which to compare this card.
    * @return Bool - true if this card has the opposite color of the specified card
    */
    func hasOppositeColorThan(card : Card) -> Bool {
        return (self.color != card.getColor());
    }
    
    /**
    * Return true if and only if this card has a higher rank than the specified card.
    *
    * @param card : Card - The card with which to compare this card.
    * @param acesLow : Bool - True if Aces should be considered low.
    * @return Bool - true if this card has a higher rank than the specified card
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
    * @return Bool - true if this card has a lower rank than the specified card
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
    * @param ignoreSuit : Bool (default true) - True if suit should not be considered; false otherwise.
    * @return Bool - true if this card is equal to the specified card
    */
    func isEqualTo(card : Card, ignoreSuit : Bool = true) -> Bool {
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
    func getCardFace(deckChoice : Deck.DeckFronts) -> UIImage? {
        let cardRank : String;
        let cardSuit : String;
        var cardOption : Deck.DeckFronts = deckChoice;
        
        switch(self.suit) {
            case .Clubs:
                cardSuit = "clubs";
            case .Diamonds:
                cardSuit = "diamonds";
            case .Hearts:
                cardSuit = "hearts";
            case .Spades:
                cardSuit = "spades";
        }
        
        switch(self.rank) {
            case .Ace:
                cardRank = "ace";
            case .Jack:
                cardRank = "jack";
            case .Queen:
                cardRank = "queen";
            case .King:
                cardRank = "king";
            default:
                cardRank = String(self.rank.rawValue);
        }
        
        // The only difference between Deck1 and Deck2 are the Kings, Queens, and Jacks.
        if(self.rank.rawValue <= CardRank.Ten.rawValue && cardOption == Deck.DeckFronts.Deck3) {
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
    func getCardBack(deckChoice : Deck.DeckBacks) -> UIImage? {
        let imageName = "back_" + deckChoice.rawValue;
        
        return UIImage(named: imageName);
    }
}