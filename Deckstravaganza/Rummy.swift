//
//  Rummy.swift
//  Deckstravaganza
//
//  Created by Luis Carbonell on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

enum MeldType : Int {
    case group = 1
    case run = 2
    
    static let numberOfRummyTypes = 2
}

enum Difficulty : Int {
    case easy = 1
    case hard = 2
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
    
    var isRoundOver: Bool
    var isGameOver: Bool
    
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
        
        self.turn = 0
        self.round = 0
        
        self.isRoundOver = false
        self.isGameOver = false
        
        if selectedOptions != nil {
            // Check if multiplayer
//            if (selectedOptions![0].options.first! == "true") {
                // do gamecenter stuff
//            }
            if selectedOptions![0].options.first! == "Easy" {
                self.difficulty = .easy
            } else {
                self.difficulty = .hard
            }
        
            let floatScore = Float(selectedOptions![1].options.first!)
            self.targetScore = Int(floatScore!)
            self.setPlayers(Int(selectedOptions![2].options.first!)!)
        } else {
            self.targetScore = 500
            self.difficulty = .easy
            self.setPlayers(2)
        }
        
        self.adjustableSettings = [
//            AdjustableSetting(
//                settingName: "Multiplayer",
//                formType: FormType.Switch,
//                dataType: DataType.Bool,
//                options: ["on","off"]
//            ),
            AdjustableSetting(
                settingName: "Difficulty Level",
                formType: FormType.dropDown,
                dataType: DataType.string,
                options: ["Easy", "Hard"]
            ),
            AdjustableSetting(
                settingName: "Score",
                formType: FormType.slider,
                dataType: DataType.int,
                options: ["0","1000","10"]
            ),
            AdjustableSetting(
                settingName: "Number of players",
                formType: FormType.dropDown,
                dataType: DataType.int,
                options: ["2","3","4","5","6"]
            ),
            AdjustableSetting(
                settingName: "Card Type",
                formType: FormType.cards,
                dataType: DataType.image,
                options: []
            )
        ]
        
        
    }
    
    // MARK: Methods for setting up the game
    
    
    
    func setPlayers(_ numberOfPlayers: Int) {
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
            for _ in 0 ..< self.playersHands.count {
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
        
        for _ in 0 ..< handSize  {
            for playerIndex in 0 ..< self.playersHands.count {
                if !self.deck.isEmpty() {
                self.playersHands[playerIndex].appendCard(self.deck.pull()!);

                }
            }
        }
        
        self.wastePile.push(self.deck.pull()!)
        
        
    }
    
    // MARK: Methods for moving cards in game
    // Adds a card when it is selected to a pile
    func addSelectedCard(_ card: Card) {
        selectedCards.appendCard(card)
    }
    
    // Removes card from hand and adds it to the waste pile
    func discard(_ card: Card) {
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
            let newMeld = RummyMeld(meld: Pile(), type: .run)
            for cardIndex in 0..<selectedCards.numberOfCards() {
                newMeld.meld.appendCard(selectedCards.cardAt(cardIndex)!)
            }
            self.melds.append(newMeld)
            self.selectedCards.removeAllCards()
        }
            
        else if checkForGroup() {
            let newMeld = RummyMeld(meld: Pile(), type: .group)
            for cardIndex in 0..<selectedCards.numberOfCards() {
                newMeld.meld.appendCard(selectedCards.cardAt(cardIndex)!)
            }
            self.melds.append(newMeld)
            self.selectedCards.removeAllCards()
        }
    }
    
    // Moves cards in a valid layoff from the players hand into the meld in the array of melds
    // Return the index of the meld it was moved to
    func layOffSelectedCards(_ meldIndex: Int, insertIndex: Int){
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
                    if melds[meldIndex].type == .group && melds[meldIndex].meld.cardAt(0)!.hasSameRankAs(selectedCards.cardAt(cardIndex)!) {
                        meldIndicies.append(meldIndex)
                    }
                        // Check for run
                    else if melds[meldIndex].type == .run {
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
    func drawFromDeck(_ card: Card) {
        let drawnCard = self.deck.removeCard(card)
        self.playersHands[currentPlayerNumber].insertCardAt(drawnCard!, index: 0)
    }
    
    // Draws waste pile from deck and adds it to the users hand
    func drawFromWastePile(_ card: Card) {
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
                if meld.type == .group && meld.meld.cardAt(0)!.hasSameRankAs(selectedCard!) {
                    return true
                }
                    // Check for run
                else if meld.type == .run {
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
        for playerHand in playersHands {
            if playerHand.isEmpty() {
                isRoundOver = true
                return true
            }
        }
        return false
    }
    
    func checkGameEnded() -> Bool {
        for player in players {
            if player.score >= targetScore {
                isGameOver = true
                return true
            }
        }
        return false
    }
    
    func turnDidStart() {
        print("Turn started")
        turn += 1
        currentPlayerNumber = turn%players.count
        isRoundOver = false
    }
    
    func resetGame() {
        self.turn = 0
        self.round = 0
        self.roundScores = []
        
        self.isRoundOver = false
        self.isGameOver = false
        
        for playerIndex in 0..<self.players.count {
            players[playerIndex].score = 0
        }
    }
    
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
}
