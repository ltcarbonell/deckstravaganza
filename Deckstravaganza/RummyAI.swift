//
//  RummyAI.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 11/23/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

class RummyAI {
    
    let difficulty: Int
    let game: Rummy
    
    init(difficulty: Int, game: Rummy) {
        self.difficulty = difficulty
        self.game = game
    }
    
    func shouldDrawCardFromDeck() -> Bool {
        let wasteTop = self.game.wastePile.topCard()!
        
        if wasteTop.getColor() == .Red {

        }
        
        return true
    }
    
    func getDiscardCard() {
        
    }
    
}