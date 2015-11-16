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
    var meld: Pile;
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
    
    let smallGameHand = 10;
    let mediumGameHand = 7;
    let largeGameHand = 6;
    
    var didDrawCard = false
    var didPlayMeld = false
    var didLayOff = false
    var didDiscard = false
    
    var selectedCards = Pile()
    
    init(numberOfPlayers: Int) {
        self.setPlayers(numberOfPlayers)
    }
    
    // MARK: Methods for setting up the game
    
    func play() {
        print("Playing");
    }
    
    func setPlayers(numberOfPlayers: Int) {
        print("Setting players");
        for playerNumber in 0..<numberOfPlayers {
            self.players.append(Player(userName: "Player \(playerNumber)", score: 0, playerNumber: playerNumber))
        }
        for _ in 0..<players.count {
            self.playersHands.append(Pile())
        }
    }
    
    func getGameOptions() -> [AdjustableSetting] {
        return []
    }
    
    // MARK: Methods for playing game
    
    // Deals the cards from the pre-shuffled deck into the approporate number of players hands
    func deal() {
        if(self.playersHands.count == 0) {
            for(var playerIndex = 0; playerIndex < self.playersHands.count; playerIndex++) {
                self.playersHands.append(Pile());
            }
        }
        let handSize : Int;
        
        switch(self.players.count) {
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
            for(var playerIndex = 0; playerIndex < self.playersHands.count && !self.deck.isEmpty(); playerIndex++) {
                self.playersHands[playerIndex].appendCard(self.deck.pull()!);
            }
        }
        
        self.wastePile.push(self.deck.pull()!)
        
        print("Dealt");
    }
    
    // MARK: Methods for moving cards in game
    // Adds a card when it is selected to a pile
    func addSelectedCard(card: Card) {
        selectedCards.appendCard(card)
    }
    
    // Removes card from hand and adds it to the waste pile
    func discard(card: Card) {
        let discardedCard = self.playersHands[players[0].playerNumber].removeCard(card)
        self.wastePile.push(discardedCard!)
    }
    
    // Draws card from deck and adds it to the users hand
    func drawFromDeck(card: Card) {
        let drawnCard = self.deck.removeCard(card)
        self.playersHands[0].insertCardAt(drawnCard!, index: 0)
    }
    
    // Draws waste pile from deck and adds it to the users hand
    func drawFromWastePile(card: Card) {
        let drawnCard = self.wastePile.removeCard(card)
        self.playersHands[0].insertCardAt(drawnCard!, index: 0)
    }
    
    // MARK: Methods for checking for valid moves
    func isValidMeld(pile: Pile) -> Bool {
        if pile.numberOfCards() > 3 {
            // Check for run
            for cardIndex in 0..<pile.numberOfCards() {
                
            }
            // Check for group
            for cardIndex in 1..<pile.numberOfCards() {
                if !pile.cardAt(cardIndex)!.hasSameSuitAs(pile.cardAt(0)!) {
                    return false
                }
            }
        } else {
            return false
        }
        return false
    }
    
    //begin round
    //begin turn player i
    // if player score = 500 -> end turn, end round, end game
    // end turn player i, begin turn player i+1, repeat for n turns
    //end round
    // Redeal cards -> begin round if score != 500
    
    func checkValidTurn(card: Card, toPile: StackPile) {
        /*Each turn consists of the following parts:*/
        /*The Draw. You must begin by taking one card from either the top of the Stock pile or the top card on the discard pile, and adding it to your hand.*/
        
        /* Melding. If you have a valid group or sequence in your hand, you may lay one such combination face up on the table in front of you. You cannot meld more than one combination in a turn. Melding is optional; you are not obliged to meld just because you can.*/
        
        /*Laying off. This is also optional. If you wish, you may add cards to groups or sequences previously melded by yourself or others. There is no limit to the number of cards a player may lay off in one turn.*/
        
        /*The Discard At the end of your turn, one card must be discarded from your hand and placed on top of the discard pile face up. If you began your turn by picking up the top card of the discard pile you are not allowed to end that turn by discarding the same card, leaving the pile unchanged - you must discard a different card.*/
    }
    
    
    // MARK: Methods for checking and changing game status
    func checkRoundEnded() -> Bool{
        return false
    }
    
    func checkGameEnded() {
        
    }
    
    func gameDidStart() {
        print("Game started");
    }
    
    func gameDidEnd() {
        print("Game ended");
    }
    
    func isWinner() -> Bool {
        print("Winner!");
        return true;
    }
    
    func roundDidStart() {
        print("Round started");
    }
    
    func roundDidEnd() {
        print("Round ended");
    }
    
    func increaseScore() {
        print("Score increased");
    }
    
    func turnDidEnd() {
        // If turn ended check if the round ended
        if checkRoundEnded() {
            // check if game ended
            // if ended, display winner
            // else start new round
        } else {
            // Go to next player
            // Current player's turn is player++%(number of players).
        }
        
    }
}



/*
class RummyDelegate: CardGameDelegate {
    typealias CardGameType = Rummy;
    
    let smallGameHand = 10;
    let mediumGameHand = 7;
    let largeGameHand = 6;
    
    var didDrawCard = false
    var didPlayMeld = false
    var didLayOff = false
    var didDiscard = false
    
    var selectedCards = Pile()
    
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
                Game.playersHands[playerIndex].appendCard(Game.deck.pull()!);
            }
        }
        
        Game.wastePile.push(Game.deck.pull()!)
        
        print("Dealt");
    }
    

    
    func addSelectedCard(card: Card) {
        selectedCards.appendCard(card)
    }
    
    //begin round
    //begin turn player i
    // if player score = 500 -> end turn, end round, end game
    // end turn player i, begin turn player i+1, repeat for n turns
    //end round
    // Redeal cards -> begin round if score != 500
    
    func checkValidTurn(card: Card, toPile: StackPile) {
        /*Each turn consists of the following parts:*/
            /*The Draw. You must begin by taking one card from either the top of the Stock pile or the top card on the discard pile, and adding it to your hand.*/
        
           /* Melding. If you have a valid group or sequence in your hand, you may lay one such combination face up on the table in front of you. You cannot meld more than one combination in a turn. Melding is optional; you are not obliged to meld just because you can.*/
            
            /*Laying off. This is also optional. If you wish, you may add cards to groups or sequences previously melded by yourself or others. There is no limit to the number of cards a player may lay off in one turn.*/
        
            /*The Discard At the end of your turn, one card must be discarded from your hand and placed on top of the discard pile face up. If you began your turn by picking up the top card of the discard pile you are not allowed to end that turn by discarding the same card, leaving the pile unchanged - you must discard a different card.*/
    }

    func checkRoundEnded() -> Bool{
        return false
    }
    
    func checkGameEnded() {
        
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
        if checkRoundEnded() {
            
        } else {
            
        }
        
    }
}*/

