//
//  Rummy.swift
//  Deckstravaganza
//
//  Created by Calvin Moore on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

enum MeldType : Int {
    case Group = 1
    case Run = 2
    
    static let numberOfRummyTypes = 2
}

struct RummyMeld {
    var user: Player;
    var meld: Pile;
    var type: MeldType
}

class Rummy: CardGame {
    /* Rules from http://www.pagat.com/rummy/rummy.html */
    
    var deck = Deck(deckFront: Deck.DeckFronts.Deck2, deckBack: Deck.DeckBacks.Default)
    var targetScore = 500;
    
    var wastePile =     StackPile(),
        playersHands =  [Pile](),
        melds =         [RummyMeld]();
    
    var players = [Player]();
    var currentPlayerNumber = 0
    var turn: Int
    
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
        self.turn = 0
        self.setPlayers(numberOfPlayers)
        
    }
    
    
    //begin round
    //begin turn player i
    // if player score = 500 -> end turn, end round, end game
    // end turn player i, begin turn player i+1, repeat for n turns
    //end round
    // Redeal cards -> begin round if score != 500
    
    
    
    
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
        let discardedCard = self.playersHands[currentPlayerNumber].removeCard(card)
        self.wastePile.push(discardedCard!)
        turnDidEnd()
    }
    
    // Moves cards in a valid meld from the players hand and into the array of melds
    func meldSelectedCards() {
        // Remove cards from hand
        for cardIndex in 0..<self.selectedCards.numberOfCards() {
            self.playersHands[currentPlayerNumber].removeCard(self.selectedCards.cardAt(cardIndex)!)
        }
        
        if checkForRun() {
            let newMeld = RummyMeld(user: players[currentPlayerNumber], meld: Pile(), type: .Run)
            for cardIndex in 0..<selectedCards.numberOfCards() {
                newMeld.meld.appendCard(selectedCards.cardAt(cardIndex)!)
            }
            self.melds.append(newMeld)
            self.selectedCards.removeAllCards()
        }
        
        else if checkForGroup() {
            let newMeld = RummyMeld(user: players[currentPlayerNumber], meld: Pile(), type: .Group)
            for cardIndex in 0..<selectedCards.numberOfCards() {
                newMeld.meld.appendCard(selectedCards.cardAt(cardIndex)!)
            }
            self.melds.append(newMeld)
            self.selectedCards.removeAllCards()
        }
    }
    
    // Moves cards in a valid layoff from the players hand into the meld in the array of melds
    // Return the index of the meld it was moved to
    func layOffSelectedCards(meldIndex: Int, insertIndex: Int){
        for cardIndex in 0..<self.selectedCards.numberOfCards() {
            self.playersHands[currentPlayerNumber].removeCard(self.selectedCards.cardAt(cardIndex)!)
            self.melds[meldIndex].meld.insertCardAt(self.selectedCards.cardAt(cardIndex)!, index: insertIndex)
        }
        self.selectedCards.removeAllCards()
        
    }
    
    // Check to see where the cards can be moved to
    // Returns an array of possible meld options
    func checkForMeldOptions() -> [Int] {
        selectedCards.sortByRank(true)
        var meldIndicies: [Int] = []
        // If there arent any melds, then there is nothing to check
        if self.melds.count > 0 {
            for cardIndex in 0..<selectedCards.numberOfCards() {
                // check for first card of a group
                for meldIndex in 0..<melds.count {
                    // if it is same rank return true
                    if melds[meldIndex].type == .Group && melds[meldIndex].meld.cardAt(0)!.hasSameRankAs(selectedCards.cardAt(cardIndex)!) {
                        meldIndicies.append(meldIndex)
                    }
                        // Check for run
                    else if melds[meldIndex].type == .Run {
                        // if same suit and 1 - first card rank return true
                        if selectedCards.cardAt(cardIndex)!.getRank().hashValue == melds[meldIndex].meld.cardAt(0)!.getRank().hashValue-1 && melds[meldIndex].meld.cardAt(0)!.hasSameSuitAs(selectedCards.cardAt(cardIndex)!) {
                            meldIndicies.append(meldIndex)
                            // if is it same suit and 1+ last card rank return true
                        } else if selectedCards.cardAt(cardIndex)!.getRank().hashValue == melds[meldIndex].meld.cardAt(melds[meldIndex].meld.numberOfCards() - 1)!.getRank().hashValue+1 && melds[meldIndex].meld.cardAt(0)!.hasSameSuitAs(selectedCards.cardAt(cardIndex)!) {
                            meldIndicies.append(meldIndex)
                        }
                    }
                }
            }
        }
        return meldIndicies
    }
    
    
    // Draws card from deck and adds it to the users hand
    func drawFromDeck(card: Card) {
        let drawnCard = self.deck.removeCard(card)
        self.playersHands[currentPlayerNumber].insertCardAt(drawnCard!, index: 0)
    }
    
    // Draws waste pile from deck and adds it to the users hand
    func drawFromWastePile(card: Card) {
        let drawnCard = self.wastePile.removeCard(card)
        self.playersHands[currentPlayerNumber].insertCardAt(drawnCard!, index: 0)
    }
    
    // MARK: Methods for checking for valid moves
    // Check for run
    func checkForRun() -> Bool {
        if selectedCards.numberOfCards() >= 3 {
            var prevCard = selectedCards.cardAt(0)!
            for cardIndex in 1..<selectedCards.numberOfCards() {
                if !selectedCards.cardAt(cardIndex)!.hasSameSuitAs(selectedCards.cardAt(0)!) {
                    return false
                }
                else {
                    if prevCard.getRank().hashValue + 1 != selectedCards.cardAt(cardIndex)?.getRank().hashValue {
                        return false
                    } else {
                        prevCard = selectedCards.cardAt(cardIndex)!
                    }
                }
            }
            return true
        } else {
            return false
        }
    }
    
    func checkForGroup() -> Bool {
        if selectedCards.numberOfCards() >= 3 {
            for cardIndex in 1..<selectedCards.numberOfCards() {
                if !selectedCards.cardAt(cardIndex)!.hasSameRankAs(selectedCards.cardAt(0)!) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    // Check if the selected cards are a valid meld
    func isSelectedCardsValidMeld() -> Bool {
        selectedCards.sortByRank(true)
        if checkForRun() || checkForGroup() {
            return true
        } else {
            return false
        }
    }
    
    // Check if the selected card(s) are a valid layoff
    func isSelectedCardsValidLayOff() -> Bool {
        selectedCards.sortByRank(true)
        
        // If there arent any melds, then there is nothing to check
        if self.melds.count == 0 {
            return false
        } else {
            for cardIndex in 0..<selectedCards.numberOfCards() {
                // check for first card of a group
                for meld in melds {
                    // if it is same rank return true
                    if meld.type == .Group && meld.meld.cardAt(0)!.hasSameRankAs(selectedCards.cardAt(cardIndex)!) {
                        return true
                    }
                    // Check for run
                    else if meld.type == .Run {
                            // if same suit and 1 - first card rank return true
                        if selectedCards.cardAt(cardIndex)!.getRank().hashValue == meld.meld.cardAt(0)!.getRank().hashValue-1 && meld.meld.cardAt(0)!.hasSameSuitAs(selectedCards.cardAt(cardIndex)!) {
                            return true
                            // if is it same suit and 1+ last card rank return true
                        } else if selectedCards.cardAt(cardIndex)!.getRank().hashValue == meld.meld.cardAt(meld.meld.numberOfCards() - 1)!.getRank().hashValue+1 && meld.meld.cardAt(0)!.hasSameSuitAs(selectedCards.cardAt(cardIndex)!) {
                            return true
                        }
                        else {
                            return false
                        }
                    }
                }
            }
            return false
        }
    }

    // MARK: Methods for checking and changing game status
    func checkRoundEnded() -> Bool{
        if playersHands[currentPlayerNumber].isEmpty() {
            return true
        } else {
            return false
        }
    }
    
    func checkGameEnded() -> Bool {
        if players[currentPlayerNumber].score >= targetScore {
            return true
        } else {
            return false
        }
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
        print("TURN NUMBER", turn)
        // If turn ended check if the round ended
        if checkRoundEnded() {
            // check if game ended
            if checkGameEnded() {
                // display winner
            } else {
                increaseScore()
                currentPlayerNumber = ++turn%players.count
            }
            
            // else start new round
        } else {
            currentPlayerNumber = ++turn%players.count
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

