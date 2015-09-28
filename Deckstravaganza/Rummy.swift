//
//  Rummy.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

struct RummyMeld {
    var user: Player;
    var meld: StackPile;
}

class Rummy: CardGame {
    var deck = Deck();
    
    var wastePile =     StackPile(),
        playersHands =  [StackPile](),
        melds =         [RummyMeld]();
    
    var players = [Player]();
    
    func play() {
        print("Playing");
    }
}

class RummyDelegate: CardGameDelegate {
    typealias T = Rummy;
    
    func deal(Game: T) {
        print("Dealt");
    }
    
    func gameDidStart(Game: T) {
        print("Game started");
    }
    
    func gameDidEnd(Game: T) {
        print("Game ended");
    }
    
    func isWinner(Game: T) {
        print("Winner!");
    }
    
    func roundDidStart(Game: T) {
        print("Round started");
    }
    
    func roundDidEnd(Game: T) {
        print("Round ended");
    }
    
    func increaseScore(Game: T) {
        print("Score increased");
    }
}

