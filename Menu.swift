//
//  Menu.swift
//  Deckstravaganza
//
//  Created by Stephen on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import UIKit

class Menu {
    let name: String
    let description: String
    let level: Int
    let clickable: Bool
    
    // designated initializer for a MenuItem
    init(name: String, description: String, level: Int = 1, clickable: Bool = true) {
        self.name = name
        self.description = description
        self.level = level
        self.clickable = clickable
    }
}

