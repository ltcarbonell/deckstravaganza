//
//  CardGame.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

struct Player {
    var userName: String
    var score = 0
    var playerNumber: Int
}

enum FormType : Int {
    case DropDown = 1
    case Slider = 2
    case Switch = 3
    case Cards = 4
    
    static let numberOfFormTypes = 4
}

enum DataType : Int {
    case Int = 1
    case Bool = 2
    case String = 3
    case Image = 4
    
    static let numberOfDataTypes = 4
}

struct AdjustableSetting {
    var settingName: String
    var formType: FormType
    var dataType: DataType
    var options: [String]
}

enum GameType: Int {
    case Solitaire = 0;
    case Rummy = 1;
    
    static let numberOfGameTypes = 2;
}

protocol CardGame {
    // Properties
    var deck: Deck { get }
    var players: [Player] { get set }
    // Methods
    
    func play()
    
    // sets the players with point values and names
    func setPlayers(numberOfPlayers: Int)
    
    // Return adjustable settings for the game
    func getAdjustableSettings() -> [AdjustableSetting];
    
    var adjustableSettings: [AdjustableSetting] { get set }
}

protocol CardGameDelegate {
    
    typealias CardGameType = CardGame
    
    // deals out the cards at the start of each round and/or turn depending on the game
    func deal(Game: CardGameType)
    
    // these are used to keep track of the status of the game
    func gameDidStart(Game: CardGameType)
    func gameDidEnd(Game: CardGameType)
    func isWinner(Game: CardGameType) -> Bool
    
    // used to keep track of the rounds which are defined inside each of the individual games
    func roundDidStart(Game: CardGameType)
    // ends when all players are finished with their turn
    func roundDidEnd(Game: CardGameType)
    
    // keeps score for the player
    func increaseScore(Game: CardGameType)
}