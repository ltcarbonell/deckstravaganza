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
    var targetScore = 500;
    
    var wastePile =     StackPile(),
        playersHands =  [StackPile](),
        melds =         [RummyMeld]();
    
    var players = [Player]();
    
    var adjustableSettings = [AdjustableSetting]();
    
    func play() {
        print("Playing");
    }
    
    func setPlayers() {
        print("Setting players");
    }
}

class RummyDelegate: CardGameDelegate {
    typealias CardGameType = Rummy;
    
    let smallGameHand = 10;
    let mediumGameHand = 7;
    let largeGameHand = 6;
    
    func deal(Game: CardGameType) {
        if(Game.playersHands.count == 0) {
            for(var playerIndex = 0; playerIndex < Game.playersHands.count; playerIndex++) {
                Game.playersHands.append(StackPile());
            }
        }
        
        let handSize : Int;
        
        switch(Game.players.count) {
            case 2:
                handSize = smallGameHand;
            case 3, 4:
                handSize = mediumGameHand;
            case 5, 6:
                handSize = largeGameHand;
            default:
                handSize = 0;
                print("Error: Number of players incorrect.");
        }
        
        for(var cardIndex = 0; cardIndex < handSize; cardIndex++) {
            for(var playerIndex = 0; playerIndex < Game.playersHands.count && !Game.deck.isEmpty(); playerIndex++) {
                Game.playersHands[playerIndex].push(Game.deck.pull()!);
            }
        }
        
        print("Dealt");
    }
    
    func gameDidStart(Game: CardGameType) {
        print("Game started");
    }
    
    func gameDidEnd(Game: CardGameType) {
        print("Game ended");
    }
    
    func isWinner(Game: CardGameType) -> Bool {
        print("Winner!");
        return true;
    }
    
    func roundDidStart(Game: CardGameType) {
        print("Round started");
    }
    
    func roundDidEnd(Game: CardGameType) {
        print("Round ended");
    }
    
    func increaseScore(Game: CardGameType) {
        print("Score increased");
    }
    
    func turnDidEnd(Game: CardGameType) {
        // Current player's turn is player++%(number of players).
    }
}

