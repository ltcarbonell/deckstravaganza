//
//  Menu.swift
//  Deckstravaganza
//
//  Created by Stephen on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class Menu {
    let name: String
    let description: String
    let level: Int
    let clickable: Bool
    let viewGameOptions: Bool
    let gameType: GameType?
    
    // designated initializer for a MenuItem
    init(name: String, description: String, level: Int = 1, clickable: Bool = true, viewGameOptions: Bool = false, gameType: GameType? = nil) {
        self.name = name
        self.description = description
        self.level = level
        self.clickable = clickable
        self.viewGameOptions = viewGameOptions;
        self.gameType = gameType;
    }
}

