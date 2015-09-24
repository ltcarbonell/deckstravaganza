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
    var wastePile: stackPile        // where the three cards are placed that you can chose from
    var foundations: [stackPile]    // where you have to place A -> King by suit
    var tableus: [stackPile]        // The piles of cards you can add onto
    
    var players = ["Player 1": 0]   // only one player... hence SOLITARE
    
    let gameDelegate = SolitareDelegate()
    
    // initializer
    init() {
        // deals the cards out for the first and only time
        // calls from solitare delagate
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
    func deal(Game: CardGame) {
        
        // calls a brand new, newly shuffled deck
        Solitare.deck = Deck.newDeck()
        
        // creates empty stacks dor all three piles
        Solitare.wastePile = stackPile()
        Solitare.foundations = [stackPile]()
        Solitare.tableus = [stackPile]()
        
        // places the cards into the tableus 1->7
        for var i = 1; i < 7; i++ {
            for var j = 0; j < i; j++ {
                Solitare.deck.pop = Solitare.foundations[i].push
            }
        }
    }
    
    func gameDidStart(Game: CardGame) {
        
    }
    
    func gameDidEnd(Game: CardGame) {
        
    }
    
    func isWinner(Game: CardGame) {
        
    }
    
    func roundDidStart(Game: CardGame) {
        
    }
    
    func roundDidEnd(Game: CardGame) {
        
    }
    
    func increaseScore(Game: CardGame) {
        
    }
}