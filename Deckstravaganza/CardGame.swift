//
//  CardGame.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

struct Player {
    var userName: String
    var score = 0
    var playerNumber: Int
    var isComputer: Bool
}

enum FormType : Int {
    case dropDown = 1
    case slider = 2
    case `switch` = 3
    case cards = 4
    
    static let numberOfFormTypes = 4
}

enum DataType : Int {
    case int = 1
    case bool = 2
    case string = 3
    case image = 4
    
    static let numberOfDataTypes = 4
}

struct AdjustableSetting {
    var settingName: String
    var formType: FormType
    var dataType: DataType
    var options: [String]
}

enum GameType: Int {
    case solitaire = 0;
    case rummy = 1;
    
    static let numberOfGameTypes = 2;
}

protocol CardGame {
    // Properties
    var deck: Deck { get }
    var players: [Player] { get set }
    // Methods
        
    // sets the players with point values and names
    func setPlayers(_ numberOfPlayers: Int)
    
    // Return adjustable settings for the game
    func getGameOptions() -> [AdjustableSetting];
    
    var adjustableSettings: [AdjustableSetting] { get set }
}

protocol CardGameDelegate {
    
    associatedtype CardGameType = CardGame
    
    // deals out the cards at the start of each round and/or turn depending on the game
    func deal(_ Game: CardGameType)
    
    // these are used to keep track of the status of the game
    func gameDidStart(_ Game: CardGameType)
    func gameDidEnd(_ Game: CardGameType)
    func isWinner(_ Game: CardGameType) -> Bool
    
    // used to keep track of the rounds which are defined inside each of the individual games
    func roundDidStart(_ Game: CardGameType)
    // ends when all players are finished with their turn
    func roundDidEnd(_ Game: CardGameType)
    
    // keeps score for the player
    func increaseScore(_ Game: CardGameType)
}
