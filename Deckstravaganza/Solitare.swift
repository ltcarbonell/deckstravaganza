//
//  Solitare.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

class Solitare: CardGame {
    
    //Properties from protocol of card game
    var deck: Deck
    enum Difficulty : Int {
        case Easy = 1;
        case Hard = 3;
    }
    
    // Properties of solitare
    var wastePile = StackPile()        // where the three cards are placed that you can chose from
    var foundations = [StackPile](count: 4, repeatedValue: StackPile())    // where you have to place A -> King by suit
    var tableus = [StackPile](count: 7, repeatedValue: StackPile())        // The piles of cards you can add onto
    var players = [Player]()
    
    let gameDelegate = SolitareDelegate()
    
    // initializer
    init() {
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
            turn()
            gameDelegate.roundDidEnd(self)
            gameDelegate.numberOfRounds++
            gameDelegate.increaseScore(self)
        }
        gameDelegate.gameDidEnd(self)
    }
    
    func setPlayers() {
        self.players = [Player(userName: "Player 1", score: 0, playerNumber: 1)]  // only one player... hence SOLITARE
    }
    
    func turn() {
        // pop off either 3 or 1 cards based on the difficulty
        
        // user can either move a card or draw again
            // if moved card, checkMove()
            // if not end turn
    }
    
    func checkMove() {
        // get where the card is coming from
        // see where it is going
        // if coming from wastePile and going to tableu, has to be one less and opposite color as tableu.top or king and empty space
        // if coming from wastePile and going to foundation, has to be one more and same suit
        // if coming from tableu to foundation, has to be one more and same suit
        // if coming from tableu to different tableu, has to be one less and opposite color as tableu.top or king and empty space
    }
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