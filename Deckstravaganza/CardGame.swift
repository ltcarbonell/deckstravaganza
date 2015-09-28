//
//  CardGame.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

struct Player {
    var userName: String
    var score = 0
}



protocol CardGame {
    // Properties
    var deck: Deck { get }
    var players: [Player] { get set }
    // Methods
    func play()
}

protocol CardGameDelegate {
    
    typealias T
    // deals out the cards at the start of each round and/or turn depending on the game
    func deal(Game: T)
    
    // these are used to keep track of the status of the game
    func gameDidStart(Game: T)
    func gameDidEnd(Game: T)
    func isWinner(Game: T)
    
    // used to keep track of the rounds
    func roundDidStart(Game: T)
    func roundDidEnd(Game: T)
    
    // keeps score for the player
    func increaseScore(Game: T)
}