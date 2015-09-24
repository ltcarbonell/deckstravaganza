//
//  CardGame.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

protocol CardGame {
    // Properties
    var deck: Deck { get }
    var players: [String: Int] { get set }
    // Methods
    func play()
}

protocol CardGameDelegate {
    // deals out the cards at the start of each round and/or turn depending on the game
    func deal(Game: CardGame)
    
    // these are used to keep track of the status of the game
    func gameDidStart(Game: CardGame)
    func gameDidEnd(Game: CardGame)
    func isWinner(Game: CardGame)
    
    // used to keep track of the rounds
    func roundDidStart(Game: CardGame)
    func roundDidEnd(Game: CardGame)
    
    // keeps score for the player
    func increaseScore(Game: CardGame)
}