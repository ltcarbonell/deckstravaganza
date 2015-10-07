//
//  Solitare.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import SpriteKit

class Solitare: CardGame {
    
    //Properties from protocol of card game
    var deck: Deck
    var players = [Player]()
    var diff: Difficulty
    
    var adjustableSettings = [AdjustableSetting(settingName: "Difficulty Level", formType: FormType.DropDown, dataType: DataType.String, options: ["Easy", "Hard"])]
    
    enum Difficulty : Int {
        case Easy = 1;
        case Hard = 3;
    }
    
    // Properties of solitare
    var wastePile = StackPile()        // where the three cards are placed that you can chose from
    var foundations = [StackPile](count: 4, repeatedValue: StackPile())    // where you have to place A -> King by suit
    var tableus = [StackPile](count: 7, repeatedValue: StackPile())        // The piles of cards you can add onto
    
    
    let gameDelegate = SolitareDelegate()
    
    // initializer
    init() {
        self.diff = .Easy
        // deals the cards out for the first and only time
        // calls from solitare delagate
        self.deck = Deck()
        self.setPlayers()
        gameDelegate.deal(self)
    }
    
    // Methods
    
    // play function is run to play the game
    func play() {
        gameDelegate.deal(self)
        gameDelegate.gameDidStart(self)
        while !gameDelegate.isWinner(self) {
            gameDelegate.roundDidStart(self)
            // take a turn
            //turn()
            gameDelegate.roundDidEnd(self)
            gameDelegate.numberOfRounds++
            gameDelegate.increaseScore(self)
        }
        gameDelegate.gameDidEnd(self)
    }
    
    func setPlayers() {
        self.players = [Player(userName: "Player 1", score: 0, playerNumber: 1)]  // only one player... hence SOLITARE
    }
    
    /*func turn() {
        // user can either draw from deck or move a card
        // if choses to draw card
        if isCardDrawn {
            // if the deck is empty, add the cards from waste pile back to deck
            if deck.numberOfCards() == 0 {
                while wastePile.numberOfCards() > 0 {
                    deck.push(wastePile.pull()!)
                }
            }
            // check to see if there are enough cards left in the deck to draw
            if deck.numberOfCards() >= diff.rawValue {
                if diff == .Easy {
                    // draw only the top card and put it in the waste pile
                    wastePile.push(deck.pull()!)
                    
                } else { // if diff == .Hard
                    // draw three cards put it in the waste pile and only have access to the top one (3rd card drawn)
                    wastePile.push(deck.pull()!)
                    wastePile.push(deck.pull()!)
                    wastePile.push(deck.pull()!)
                }
            } else { // there are not enough cards to draw, so while the deck isnt empty draw the remaining cards, then after turn put them all back into the deck
                while deck.numberOfCards() > 0 {
                    wastePile.push(deck.pull()!)
                }
            }
            
        } else if isCardMoved { // if card is moved
            // checkMove() -> if valid allow move to take place
            let prevPile: StackPile
            let newPile: StackPile
            if checkMove(prevPile, newPile) {
                newPile.push(prevPile.pull()!)
            } else {
                turn()
            }
            //             -> if invalid, allow user to take a turn again and move all cards back to where they were
        } else {
            // Invalid
            print("invalid move try again")
        }
    }
    
    func checkMove(previousPile: StackPile, newPile: StackPile) -> Bool {
        // get where the card is coming from
        // see where it is going
        
        // if coming from wastePile and going to tableu, has to be one less and opposite color as tableu.top or king and empty space
        if previousPile == wastePile && tableus.contains(newPile) {
            // if the tableu it is going to is empty, it must be a king of any suit
            if newPile.isEmpty() {
                if previousPile.topCard()!.getRank() == .King {
                return true
                } else {
                    return false
                }
            } else { // if the tableu is not empty, the top card of the tableu must be 1 more than the rank of the moved card and the opposite color
                if previousPile.topCard()!.hasOppositeColorThan(newPile.topCard()!) && previousPile.topCard()!.getRank().hashValue == newPile.topCard()!.getRank().hashValue - 1 {
                    return true
                } else {
                    return false
                }
            }
        }
            
        // if coming from wastePile and going to foundation, has to be one more and same suit
        else if previousPile == wastePile && foundations.contains(newPile) {
            // checks if foundation is empty, if so it must be an ace that goes to the foundation
            if newPile.isEmpty() {
                if previousPile.topCard()!.getRank() == .Ace {
                    return true
                } else {
                    return false
                }
            } else { // if it is not empty is has to be the same suit and one less than the new card
                if previousPile.topCard()!.hasSameSuitAs(newPile.topCard()!) && previousPile.topCard()!.getRank().hashValue == newPile.topCard()!.getRank().hashValue + 1 {
                    return true
                } else {
                    return false
                }
            }
        }
        
        // if coming from tableu to foundation, has to be one more and same suit
        else if tableus.contains(previousPile) && foundations.contains(newPile) {
            // checks if foundation is empty, if so it must be an ace that goes to the foundation
            if newPile.isEmpty() {
                if previousPile.topCard()!.getRank() == .Ace {
                    return true
                } else {
                    return false
                }
            } else { // if it is not empty is has to be the same suit and one less than the new card
                if previousPile.topCard()!.hasSameSuitAs(newPile.topCard()!) && previousPile.topCard()!.getRank().hashValue == newPile.topCard()!.getRank().hashValue + 1 {
                    return true
                } else {
                    return false
                }
            }
        }
        
        // if coming from foundation to tableu has to be one less and opposite color
        else if foundations.contains(previousPile) && tableus.contains(newPile) {
            // if the tableu it is going to is empty, it must be a king of any suit
            if newPile.isEmpty() {
                if previousPile.topCard()!.getRank() == .King {
                    return true
                } else {
                    return false
                }
            } else { // if the tableu is not empty, the top card of the tableu must be 1 more than the rank of the moved card and the opposite color
                if previousPile.topCard()!.hasOppositeColorThan(newPile.topCard()!) && previousPile.topCard()!.getRank().hashValue == newPile.topCard()!.getRank().hashValue - 1 {
                    return true
                } else {
                    return false
                }
            }
        }
        // if coming from tableu to different tableu, has to be one less and opposite color as tableu.top or king and empty space
        else if tableus.contains(previousPile) && tableus.contains(newPile) {
            // HAVE TO BE ABLE TO MOVE MULTIPLE CARDS AT ONE TIME
            // NOTE: Ask Calvin which method (if any) implements that
            
        }
    }*/
}

class SolitareDelegate: CardGameDelegate {
    var numberOfRounds = 0
    typealias cardGameType = Solitare
    
    func deal(Game: Solitare) {
        var newCard: Card
        // calls a brand new, newly shuffled deck
        Game.deck.newDeck()
        
        
        // creates empty stacks for all three piles
        Game.wastePile.removeAllCards()
        for foundation in Game.foundations {
            foundation.removeAllCards()
        }
        for tableu in Game.tableus {
            tableu.removeAllCards()
        }
        
        // places the cards into the tableus 1->7
        for var i = 0; i < 7; i++ {
            for var j = 0; j < i; j++ {
                newCard = Game.deck.pull()!
                Game.tableus[i].push(newCard)
            }
        }         
    }
    
    
    // these are used to keep track of the status of the game
    func gameDidStart(Game: Solitare) {
        numberOfRounds = 0
        if Game is Solitare {
            print("We are playing solitare")
            
        }
    }
    
    func gameDidEnd(Game: Solitare) {
        print("The game ended in \(numberOfRounds) rounds.")
        print("\(Game.players[0].userName) has a score of \(Game.players[0].score)")
        
    }
    func isWinner(Game: Solitare) -> Bool {
        //        if Game.foundations[0].numberOfCards() == 13 && Game.foundations[1].numberOfCards() == 13  && Game.foundations[2].numberOfCards() == 13 && Game.foundations[3].numberOfCards() == 13 {
        //            return true
        //        } else {
        //            return false
        //        }
        if numberOfRounds > 10 {
            return true
        } else {
            return false
        }
    }
    
    // used to keep track of the rounds which are when all players take their turn
    func roundDidStart(Game: Solitare) {
        print("Round number \(numberOfRounds) is starting.")
    }
    
    //
    func roundDidEnd(Game: Solitare) {
        print("Round number \(numberOfRounds) is ending.")
    }
    
    // keeps score for the player
    func increaseScore(Game: Solitare) {
        Game.players[0].score++
    }
    
}