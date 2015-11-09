//
//  Rummy.swift
//  Deckstravaganza
//
//  Created by Calvin Moore on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

struct RummyMeld {
    var user: Player;
    var meld: StackPile;
}

class Rummy: CardGame {
    /* Rules from http://www.pagat.com/rummy/rummy.html */
    
    var deck = Deck(deckFront: Deck.DeckFronts.Deck2, deckBack: Deck.DeckBacks.Default)
    var targetScore = 500;
    
    var wastePile =     StackPile(),
        playersHands =  [Pile](),
        melds =         [RummyMeld]();
    
    var players = [Player]();
    
    var adjustableSettings = [AdjustableSetting]();
    
    init(numberOfPlayers: Int) {
        self.setPlayers(numberOfPlayers)
    }
    
    func play() {
        print("Playing");
    }
    
    func setPlayers(numberOfPlayers: Int) {
        print("Setting players");
        for playerNumber in 1...numberOfPlayers {
            self.players.append(Player(userName: "Player \(playerNumber)", score: 0, playerNumber: playerNumber))
        }
        for _ in 0..<players.count {
            self.playersHands.append(Pile())
        }
        // DEBUG //
        print(players.count)
        print(playersHands.count)
    }
    
    func getGameOptions() -> [AdjustableSetting] {
        return []
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
                Game.playersHands.append(Pile());
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
                Game.playersHands[playerIndex].addCard(Game.deck.pull()!);
            }
        }
        
        Game.wastePile.push(Game.deck.pull()!)
        
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

