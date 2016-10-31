//
//  RummyAI.swift
//  Deckstravaganza
//
//  Created by Luis Carbonell on 11/23/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import GameplayKit

class RummyAI {
    
    let difficulty: Difficulty
    let game: Rummy
    let player: Player
    
    var neededCards = Pile()
    var discardedCards = Pile()
    var currentHand = Pile()
    
    var countedRanks = [Int](repeating: 0, count: 13)
    var countedSuits = [Int](repeating: 0, count: 4)
    
    init(difficulty: Difficulty, game: Rummy, player: Player) {
        self.difficulty = difficulty
        self.game = game
        self.player = player
        self.game.playersHands[player.playerNumber].sortByRank(true)
    }
    
    func countHands() {
        self.countedRanks = [Int](repeating: 0, count: 13)
        self.countedSuits = [Int](repeating: 0, count: 4)
        for cardIndex in 0..<self.game.playersHands[player.playerNumber].numberOfCards() {
            self.countedRanks[self.game.playersHands[player.playerNumber].cardAt(cardIndex)!.getRank().rawValue-1] += 1
            self.countedSuits[self.game.playersHands[player.playerNumber].cardAt(cardIndex)!.getSuit().rawValue-1] += 1
        }
    }
    
    // MARK: Test for AI by only drawing from waste pile if it is a red card
    func shouldDrawCardFromWaste() -> Bool {
        let wasteTop = self.game.wastePile.topCard()!
        
        if difficulty == .easy {
            if wasteTop.getColor() == Card.CardColor.red {
                    return true
            } else {
                return false
            }
        }
        else if difficulty == .hard {
            if self.countedRanks[wasteTop.getRank().rawValue-1] >= 2 ||  self.countedSuits[wasteTop.getSuit().rawValue-1] >= 4 {
                return true
            }
            else {
                return false
                
            }
        }
        else {
            return false
        }
    }
    
    func shouldMeldCards() -> Bool {
        for rank in 0..<self.countedRanks.count {
            if countedRanks[rank] >= 3 {
                for cardIndex in 0..<self.game.playersHands[player.playerNumber].numberOfCards() {
                    if self.game.playersHands[player.playerNumber].cardAt(cardIndex)!.getRank().rawValue-1 == rank {
                        self.game.addSelectedCard(self.game.playersHands[player.playerNumber].cardAt(cardIndex)!)
                    }
                }
                return true
            }
        }
        for suit in 0..<self.countedSuits.count {
            if countedSuits[suit] >= 3 {
                for cardIndex in 0..<self.game.playersHands[player.playerNumber].numberOfCards() {
                    if self.game.playersHands[player.playerNumber].cardAt(cardIndex)!.getSuit().rawValue-1 == suit {
                        self.game.addSelectedCard(self.game.playersHands[player.playerNumber].cardAt(cardIndex)!)
                    }
                }
                while self.game.selectedCards.numberOfCards() >= 3 {
                    // MARK: DEBUG
                    print("Check for run", self.game.checkForRun())
                    print(self.game.selectedCards.numberOfCards())
                    for cardIndex in 0..<self.game.selectedCards.numberOfCards() {
                        print(self.game.selectedCards.cardAt(cardIndex)!.getRank(),self.game.selectedCards.cardAt(cardIndex)!.getSuit())
                    }
                    
                    if self.game.checkForRun() {
                        return true
                    } else {
                        let numberOfCardsSelected = self.game.selectedCards.numberOfCards()
                        let distribution = GKRandomDistribution(lowestValue: 0, highestValue: numberOfCardsSelected-1)
                        let randIndex = distribution.nextInt()
                        self.game.selectedCards.removeCardAt(randIndex)
                    }
                }
                self.game.selectedCards.removeAllCards()
            }
        }
        return false
    }
    
    func shouldLayOffCards() -> Bool {
        let numberOfCardsInHand = self.game.playersHands[player.playerNumber].numberOfCards()
        for cardIndex in 0..<numberOfCardsInHand {
            self.game.addSelectedCard(self.game.playersHands[player.playerNumber].cardAt(cardIndex)!)
            if self.game.isSelectedCardsValidLayOff() {
                return true
            }
        }
        self.game.selectedCards.removeAllCards()
        return false
    }
    
    func getDiscardCardIndex(_ drawnCard: Card) -> Int {
        let numberOfCardsInHand = self.game.playersHands[player.playerNumber].numberOfCards()
        let distribution = GKRandomDistribution(lowestValue: 0, highestValue: numberOfCardsInHand-1)
        let checkedFirst = distribution.nextInt()
        let goRight = distribution.nextBool()
        
        var discardedIndex = checkedFirst
        
        if difficulty == .hard {
            for _ in 0..<numberOfCardsInHand {
                let cardBeingChecked = self.game.playersHands[player.playerNumber].cardAt(discardedIndex)
                if self.countedRanks[cardBeingChecked!.getRank().rawValue-1] < 2 &&  self.countedSuits[cardBeingChecked!.getSuit().rawValue-1] < 4 && !cardBeingChecked!.isEqualTo(drawnCard, ignoreSuit: false) {
                    return discardedIndex
                } else {
                    if goRight {
                        discardedIndex += 1
                    } else {
                        discardedIndex -= 1
                    }
                    if discardedIndex == numberOfCardsInHand {
                        discardedIndex = 0
                    }
                    if discardedIndex == -1 {
                        discardedIndex = numberOfCardsInHand-1
                    }
                }
            }
        }
        
        return discardedIndex
    }
    
}
