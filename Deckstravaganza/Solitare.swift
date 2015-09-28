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
    
    // Properties of solitare
    var wastePile = StackPile()        // where the three cards are placed that you can chose from
    var foundations = [StackPile]()    // where you have to place A -> King by suit
    var tableus = [StackPile]()        // The piles of cards you can add onto
    
    var players = [Player(userName: "Player 1", score: 0) ]  // only one player... hence SOLITARE
    
    let gameDelegate = SolitareDelegate()
    
    // initializer
    init() {
        // deals the cards out for the first and only time
        // calls from solitare delagate
        self.deck = Deck()
        gameDelegate.deal(self)
        
    }
    
    // Methods
    func play() {
        gameDelegate.deal(self)
        gameDelegate.gameDidStart(self)
        
    }
}

class SolitareDelegate: CardGameDelegate {
    var numberOfTurns = 0
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
        for var i = 1; i < 7; i++ {
            for var j = 0; j < i; j++ {
                newCard = Game.deck.pull()!
                Game.foundations[i].push(newCard)
            }
        }
    }
    
    
    // these are used to keep track of the status of the game
    func gameDidStart(Game: Solitare) {
        print(" ")
    }
    
    func gameDidEnd(Game: Solitare) {
        print("  ")

    }
    func isWinner(Game: Solitare) {
        print("  ")
    }
    
    // used to keep track of the rounds
    func roundDidStart(Game: Solitare) {
        print("  ")
    }
    
    func roundDidEnd(Game: Solitare) {
        print("  ")
    }
    
    // keeps score for the player
    func increaseScore(Game: Solitare) {
        print("  ")
    }

}