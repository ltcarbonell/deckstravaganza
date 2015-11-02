//
//  Solitaire.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import SpriteKit

class Solitaire: CardGame {
    
    //Properties from protocol of card game
    var deck: Deck
    var players = [Player]()
    var diff: Difficulty
    
    // properties of the game rules that can be changed
    var adjustableSettings = [AdjustableSetting(settingName: "Difficulty Level", formType: FormType.DropDown, dataType: DataType.String, options: ["Easy", "Hard"])]
    
    // Difficulty levels possibly in solitaire
    enum Difficulty : Int {
        case Easy = 1
        case Hard = 3
    }
    
    // Properties of Solitaire
    var wastePile: StackPile        // where the three cards are placed that you can chose from
    
    
    // where you have to place A -> King by suit
    var foundations:[StackPile]
    var foundation1: StackPile
    var foundation2: StackPile
    var foundation3: StackPile
    var foundation4: StackPile
    
    // The piles of cards you can add onto
    var tableus: [StackPile]
    var tableu1: StackPile
    var tableu2: StackPile
    var tableu3: StackPile
    var tableu4: StackPile
    var tableu5: StackPile
    var tableu6: StackPile
    var tableu7: StackPile
    
    let gameDelegate = SolitaireDelegate()
    
    // initializer
    init() {
        self.diff = .Easy
        // deals the cards out for the first and only time
        // calls from Solitaire delagate
        self.deck = Deck(deckFront: Deck.DeckFronts.Deck2, deckBack: Deck.DeckBacks.Default)
        self.deck.name = "Deck"
        
        self.wastePile = StackPile()
        self.wastePile.name = "WastePile"
        
        // initializes the foundations and adds them to array
        self.foundation1 = StackPile()
        self.foundation2 = StackPile()
        self.foundation3 = StackPile()
        self.foundation4 = StackPile()
        self.foundations = [self.foundation1, self.foundation2, self.foundation3, self.foundation4]
        for foundation in self.foundations {
            foundation.name = "Foundation"
        }

        // initializes the tableu and adds them to array
        self.tableu1 = StackPile()
        self.tableu2 = StackPile()
        self.tableu3 = StackPile()
        self.tableu4 = StackPile()
        self.tableu5 = StackPile()
        self.tableu6 = StackPile()
        self.tableu7 = StackPile()
        self.tableus = [self.tableu1, self.tableu2, self.tableu3, self.tableu4, self.tableu5, self.tableu6, self.tableu7]
        for tableu in self.tableus {
            tableu.name = "Tableu"
        }
        
        self.setPlayers(1)
        //gameDelegate.deal(self)
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
    
    func setPlayers(numberOfPlayers: Int) {
        self.players = [Player(userName: "Player 1", score: 0, playerNumber: 1)]  // only one player... hence Solitaire
    }
    
    // Moves the top card of a pile and moves it to the new pile
    func moveTopCard(fromPile: StackPile, toPile: StackPile) {
        toPile.push(fromPile.pull()!)
    }
    
    // Moves multiple cards from a pile to a new pile
    // uses a temporary pile to help moves them
    func moveGroupedCards(numberOfCardsToMove: Int, fromPile: StackPile, toPile: StackPile) {
        let tempPile = StackPile()
        for _ in 0..<numberOfCardsToMove {
            tempPile.push(fromPile.pull()!)
        }
        toPile.addToStackFromFirstCardOf(tempPile)
        
    }
    
    func checkMove(card: Card, previousPile: StackPile, newPile: StackPile) -> Bool {
        // get where the card is coming from
        // see where it is going
        print("FROM, TO \(previousPile.name, newPile.name)")
        // if coming from wastePile and going to tableu, has to be one less and opposite color as tableu.top or king and empty space
        if previousPile.name == wastePile.name && newPile.name == tableus[0].name {
            // if the tableu it is going to is empty, it must be a king of any suit
            if newPile.isEmpty() {
                if card.getRank() == .King {
                return true
                } else {
                    return false
                }
            } else { // if the tableu is not empty, the top card of the tableu must be 1 more than the rank of the moved card and the opposite color
                if card.hasOppositeColorThan(newPile.topCard()!) && card.getRank().hashValue == newPile.topCard()!.getRank().hashValue - 1 {
                    return true
                } else {
                    return false
                }
            }
        }
            
        // if coming from wastePile and going to foundation, has to be one more and same suit
        else if previousPile.name == wastePile.name && newPile.name == foundations[0].name {
            // checks if foundation is empty, if so it must be an ace that goes to the foundation
            if newPile.isEmpty() {
                if card.getRank() == .Ace {
                    return true
                } else {
                    return false
                }
            } else { // if it is not empty is has to be the same suit and one less than the new card
                if card.hasSameSuitAs(newPile.topCard()!) && card.getRank().hashValue == newPile.topCard()!.getRank().hashValue + 1 {
                    return true
                } else {
                    return false
                }
            }
        }
        // if coming from tableu to foundation, has to be one more and same suit
        else if previousPile.name == tableus[0].name && newPile.name == foundations[0].name {
            // checks if foundation is empty, if so it must be an ace that goes to the foundation
            if newPile.isEmpty() {
                if card.getRank() == .Ace {
                    return true
                } else {
                    return false
                }
            } else { // if it is not empty is has to be the same suit and one less than the new card
                if card.hasSameSuitAs(newPile.topCard()!) && card.getRank().hashValue == newPile.topCard()!.getRank().hashValue + 1 {
                    return true
                } else {
                    return false
                }
            }
        }
        // if coming from foundation to tableu has to be one less and opposite color
        else if foundations[0].name == previousPile.name && tableus[0].name == newPile.name {
            // if the tableu it is going to is empty, it must be a king of any suit
            if newPile.isEmpty() {
                if card.getRank() == .King {
                    return true
                } else {
                    return false
                }
            } else { // if the tableu is not empty, the top card of the tableu must be 1 more than the rank of the moved card and the opposite color
                if card.hasOppositeColorThan(newPile.topCard()!) && card.getRank().hashValue == newPile.topCard()!.getRank().hashValue - 1 {
                    return true
                } else {
                    return false
                }
            }
        }
        // if coming from tableu to different tableu, has to be one less and opposite color as tableu.top or king and empty space
        else if tableus[0].name == previousPile.name && tableus[0].name == newPile.name {
            // HAVE TO BE ABLE TO MOVE MULTIPLE CARDS AT ONE TIME
            if newPile.isEmpty() {
                if card.getRank() == .King {
                    return true
                } else {
                    return false
                }
            }
            else {
                if card.hasOppositeColorThan(newPile.topCard()!) && card.getRank().hashValue == newPile.topCard()!.getRank().hashValue - 1 {
                    return true
                } else {
                    return false
                }
            }
        }
        else {
            return false
        }
    }
    
    // helpful methods to check the number of cards in each pile
    func printPileNumbers() {
        print("Deck: \(self.deck.numberOfCards())")
        print("Waste: \(self.wastePile.numberOfCards())")
        var Count = 0
        for tableu in self.tableus {
            print("Tableu\(Count++): \(tableu.numberOfCards())")
        }
        var count = 0
        for foundation in self.foundations {
            print("Foundation\(count++): \(foundation.numberOfCards())")
        }
    }
}

class SolitaireDelegate: CardGameDelegate {
    var numberOfRounds = 0
    typealias cardGameType = Solitaire
    
    func deal(Game: Solitaire) {
        var newCard: Card
        // calls a brand new, newly shuffled deck
        Game.deck.newDeck()
        Game.printPileNumbers()
        
        
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
            for var j = 0; j < i+1; j++ {
                newCard = Game.deck.pull()!
                Game.tableus[i].push(newCard)
            }
        }
        Game.printPileNumbers()
    }
    
    
    // these are used to keep track of the status of the game
    func gameDidStart(Game: Solitaire) {
        numberOfRounds = 0
        if Game is Solitaire {
            print("We are playing Solitaire")
            
        }
    }
    
    func gameDidEnd(Game: Solitaire) {
        print("The game ended in \(numberOfRounds) rounds.")
        print("\(Game.players[0].userName) has a score of \(Game.players[0].score)")
        
    }
    func isWinner(Game: Solitaire) -> Bool {
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
    func roundDidStart(Game: Solitaire) {
        print("Round number \(numberOfRounds) is starting.")
    }
    
    //
    func roundDidEnd(Game: Solitaire) {
        print("Round number \(numberOfRounds) is ending.")
        Game.printPileNumbers()
    }
    
    // keeps score for the player
    func increaseScore(Game: Solitaire) {
        Game.players[0].score++
    }
    
}