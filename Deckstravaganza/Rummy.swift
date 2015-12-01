//
//  Rummy.swift
//  Deckstravaganza
//
//  Created by Calvin Moore on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

enum MeldType : Int {
    case Group = 1
    case Run = 2
    
    static let numberOfRummyTypes = 2
}

enum Difficulty : Int {
    case Easy = 1
    case Hard = 2
}

struct RummyMeld {
    var meld: Pile;
    var type: MeldType
}

class Rummy: CardGame {
    /* Rules from http://www.pagat.com/rummy/rummy.html */
    
    var deck = Deck(deckFront: Deck.DeckFronts.Deck2, deckBack: Deck.DeckBacks.Default)
    var targetScore: Int;
    var difficulty: Difficulty
    let selectedOptions: [AdjustableSetting]?
    
    var wastePile =     StackPile(),
        playersHands =  [Pile](),
        melds =         [RummyMeld]();
    
    var players = [Player]();
    var currentPlayerNumber = 0
    var turn: Int
    var round: Int
    
    var adjustableSettings = [AdjustableSetting]();
    
    let smallGameHand = 10;
    let mediumGameHand = 7;
    let largeGameHand = 6;
    
    var didDrawCard = false
    var didPlayMeld = false
    var didLayOff = false
    var didDiscard = false
    
    var roundScores: [[Int]] = []
    
    var selectedCards = Pile()
    
    var computerPlayers = [RummyAI]()
    
    init(selectedOptions: [AdjustableSetting]?) {
        self.selectedOptions = selectedOptions
        if selectedOptions != nil {
            for option in selectedOptions! {
                print(option.settingName, option.options)
            }
        }
        
        self.turn = 0
        self.round = 0
        
        if selectedOptions != nil {
            // Check if multiplayer
            if (selectedOptions![0].options.first! == "true") {
                // do gamecenter stuff
            }
            if selectedOptions![1].options.first! == "Easy" {
                self.difficulty = .Easy
            } else {
                self.difficulty = .Hard
            }
        
            let floatScore = Float(selectedOptions![2].options.first!)
            self.targetScore = Int(floatScore!)
            self.setPlayers(Int(selectedOptions![3].options.first!)!)
        } else {
            self.targetScore = 500
            self.difficulty = .Easy
            self.setPlayers(2)
        }
        
        self.adjustableSettings = [
            AdjustableSetting(
                settingName: "Multiplayer",
                formType: FormType.Switch,
                dataType: DataType.Bool,
                options: ["on","off"]
            ),
            AdjustableSetting(
                settingName: "Difficulty Level",
                formType: FormType.DropDown,
                dataType: DataType.String,
                options: ["Easy", "Hard"]
            ),
            AdjustableSetting(
                settingName: "Score",
                formType: FormType.Slider,
                dataType: DataType.Int,
                options: ["0","1000","10"]
            ),
            AdjustableSetting(
                settingName: "Number of players",
                formType: FormType.DropDown,
                dataType: DataType.Int,
                options: ["2","3","4","5","6"]
            ),
            AdjustableSetting(
                settingName: "Card Type",
                formType: FormType.Cards,
                dataType: DataType.Image,
                options: []
            )
        ]
        
        
    }
    
    // MARK: Methods for setting up the game
    
    func setPlayers(numberOfPlayers: Int) {
        let fakeNames = ["Jess", "Bill", "Mark", "Pam", "Mike"]
        print("Setting \(numberOfPlayers) players");
        self.players.append(Player(userName: "You", score: 0, playerNumber: 0, isComputer: false))
        for playerNumber in 1..<numberOfPlayers {
            self.players.append(Player(userName: fakeNames[playerNumber-1], score: 0, playerNumber: playerNumber, isComputer: true))
        }
        for _ in 0..<players.count {
            self.playersHands.append(Pile())
        }
        for playerNumber in 0..<numberOfPlayers {
            if players[playerNumber].isComputer {
                computerPlayers.append(RummyAI(difficulty: self.difficulty, game: self, player: players[playerNumber]))
            }
        }
    }
    
    func getGameOptions() -> [AdjustableSetting] {
        return self.adjustableSettings
    }
    
    // MARK: Methods for playing game
    
    // Deals the cards from the pre-shuffled deck into the approporate number of players hands
    func deal() {
        print("Dealt \(self.deck.numberOfCards()) cards");
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
        self.selectedCards.removeAllCards()
    }
    
    // Moves cards in a valid meld from the players hand and into the array of melds
    func meldSelectedCards() {
        // Remove cards from hand
        for cardIndex in 0..<self.selectedCards.numberOfCards() {
            self.playersHands[currentPlayerNumber].removeCard(self.selectedCards.cardAt(cardIndex)!)
        }
        
        if checkForRun() {
            let newMeld = RummyMeld(meld: Pile(), type: .Run)
            for cardIndex in 0..<selectedCards.numberOfCards() {
                newMeld.meld.appendCard(selectedCards.cardAt(cardIndex)!)
            }
            self.melds.append(newMeld)
            self.selectedCards.removeAllCards()
        }
            
        else if checkForGroup() {
            let newMeld = RummyMeld(meld: Pile(), type: .Group)
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
            let selectedCard = selectedCards.cardAt(0)
            // check for first card of a group
            print(selectedCard!.getRank(),selectedCard!.getSuit())
            for meld in melds {
                // if it is same rank return true
                if meld.type == .Group && meld.meld.cardAt(0)!.hasSameRankAs(selectedCard!) {
                    return true
                }
                    // Check for run
                else if meld.type == .Run {
                    // if same suit and 1 - first card rank return true
                    if selectedCard!.getRank().hashValue == meld.meld.cardAt(0)!.getRank().hashValue-1 && meld.meld.cardAt(0)!.hasSameSuitAs(selectedCard!) {
                        return true
                        // if is it same suit and 1+ last card rank return true
                    } else if selectedCard!.getRank().hashValue == meld.meld.cardAt(meld.meld.numberOfCards() - 1)!.getRank().hashValue+1 && meld.meld.cardAt(0)!.hasSameSuitAs(selectedCard!) {
                        return true
                    }
                    else {
                        //return false
                    }
                }
            }
            return false
        }
    }

    // MARK: Methods for checking and changing game status
    func checkRoundEnded() -> Bool{
        return playersHands[currentPlayerNumber].isEmpty()
    }
    
    func checkGameEnded() -> Bool {
        return players[currentPlayerNumber].score >= targetScore
    }
    
//    func gameDidEnd() {
//        print("Player \(currentPlayerNumber) won.");
//    }
    
    func turnDidStart() {
        print("Turn started");
        currentPlayerNumber = ++turn%players.count
    }
    
//    func roundDidEnd() {
//        increaseScore()
//        if checkGameEnded() {
//            gameDidEnd()
//        } else {
//            currentPlayerNumber = ++turn%players.count
//            for player in players {
//                print(player.playerNumber, player.score)
//            }
//        }
//        print("Round ended");
//    }
    
    func increaseScore() {
        var scoreAdded = 0
        var newRoundScores = [Int]()
        for player in players {
            for cardIndex in 0..<self.playersHands[player.playerNumber].numberOfCards() {
                print(scoreAdded,"added")
                if self.playersHands[player.playerNumber].cardAt(cardIndex)!.getRank().rawValue > 10 {
                    scoreAdded = scoreAdded + 10
                } else {
                    scoreAdded = scoreAdded + self.playersHands[player.playerNumber].cardAt(cardIndex)!.getRank().rawValue
                }
                
            }
            newRoundScores.append(0)
        }
        roundScores.append(newRoundScores)
        print(roundScores)
        for player in players {
            if player.playerNumber == currentPlayerNumber {
                roundScores[self.round][player.playerNumber] = scoreAdded
            } else {
                roundScores[self.round][player.playerNumber] = 0
            }
        }
        
        players[currentPlayerNumber].score += scoreAdded
        print("Score increased by \(scoreAdded)");
    }
    
//    func turnDidEnd() {
//        print("TURN NUMBER", turn)
//        if checkRoundEnded() {
//            roundDidEnd()
//        } else {
//            roundDidStart()
//        }
        
//    }
}