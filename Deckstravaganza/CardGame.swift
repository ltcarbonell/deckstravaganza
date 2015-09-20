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
    func deal(Game: CardGame)
    
    func beginGame(Game: CardGame)
    func endGame(Game: CardGame)
    func isWinner(Game: CardGame)
    
    func beginRound(Game: CardGame)
    func endRound(Game: CardGame)
    
    func increaseScore(Game: CardGame)
}