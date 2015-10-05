//
//  SolitareScene.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import SpriteKit


class SolitareScene: SKScene {
    let solitareGame = Solitare()
    let gameDelegate = SolitareDelegate()
    
    var cardSize = CGSize(width: 0, height: 0)
    
    var deckLocation = CGPoint(x: 0, y: 0)
    var wastePileLocation = CGPoint(x: 0, y: 0)
    var foundationLocations = [CGPoint](count: 4, repeatedValue: CGPointMake(0, 0))
    var tableuLocations = [CGPoint](count: 7, repeatedValue: CGPointMake(0, 0))
    
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.greenColor()
        
        cardSize = CGSizeMake(self.size.width/7.5, self.size.height/3.5)
        deckLocation = CGPointMake(self.frame.minX + cardSize.width/2, self.frame.maxY - cardSize.height/2)
        wastePileLocation = CGPointMake(self.frame.minX + 3*cardSize.width/2, self.frame.maxY - cardSize.height/2)
        for var i = 0; i < foundationLocations.count; i++ {
            foundationLocations[i] = CGPointMake(self.frame.minX + (CGFloat(4+i))*cardSize.width, self.frame.maxY - cardSize.height/2)
        }
        for var i = 0; i <  tableuLocations.count; i++ {
            tableuLocations[i] = CGPointMake(self.frame.minX + (CGFloat(1+i))*cardSize.width, self.frame.maxY - 3*cardSize.height/2)
        }
        
        
        deal()
        gameDelegate.gameDidStart(solitareGame)
        while !gameDelegate.isWinner(solitareGame) {
            gameDelegate.roundDidStart(solitareGame)
            // take a turn
            //turn()
            gameDelegate.roundDidEnd(solitareGame)
            gameDelegate.numberOfRounds++
            gameDelegate.increaseScore(solitareGame)
        }
        gameDelegate.gameDidEnd(solitareGame)
        
    }
    
    func deal() {
        gameDelegate.deal(solitareGame)
        
        let deckSprite = SKSpriteNode(imageNamed: "")
        deckSprite.size = cardSize
        deckSprite.position = deckLocation
        self.addChild(deckSprite)
        
        let wastePileSprite = SKSpriteNode(imageNamed: "")
        wastePileSprite.size = cardSize
        wastePileSprite.position = wastePileLocation
        self.addChild(wastePileSprite)

        for var i = 0; i < foundationLocations.count; i++ {
            let foundationSprite = SKSpriteNode(imageNamed: "")
            foundationSprite.size = cardSize
            foundationSprite.position = foundationLocations[i]
            self.addChild(foundationSprite)
        }
        for var i = 0; i < tableuLocations.count; i++ {
            for var j = 0; j <= i; j++ {
                let tableuSprite = SKSpriteNode(imageNamed: "")
                tableuSprite.size = cardSize
                tableuSprite.position = tableuLocations[i]
                self.addChild(tableuSprite)
            }
            
        }
        
        
    }
    
/********************** Touch Controls ***************************************/
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            touchedNode.zPosition = 1
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            touchedNode.position = location
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            touchedNode.zPosition = 0
        }
    }
}
