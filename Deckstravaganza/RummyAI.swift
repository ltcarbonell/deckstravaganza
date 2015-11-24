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
    let player: Player
    
    init(difficulty: Int, game: Rummy, player: Player) {
        self.difficulty = difficulty
        self.game = game
        self.player = player
    }
    
    // MARK: Test for AI by only drawing from waste pile if it is a red card
    func shouldDrawCardFromDeck() -> Bool {
        let wasteTop = self.game.wastePile.topCard()!
        
        if wasteTop.getColor() == .Red {
            return true
        }
        else {
            return false
        }
    }
    
    func getDiscardCardIndex() -> Int {
        let discardedCard = self.game.playersHands[player.playerNumber].cardAt(0)!
        print(discardedCard.getRank(),discardedCard.getSuit())
        return 0
    }
    
}