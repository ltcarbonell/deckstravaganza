//
//  SolitaireScene.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import SpriteKit


class CardSprite: SKSpriteNode {
    let frontTexture: SKTexture
    let backTexture: SKTexture
    var faceUp: Bool
    
    let solitaireScene = SolitaireScene(size: CGSizeMake(768, 1024))
    var toLocation: CGPoint?
    var fromLocation: CGPoint?
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(card: Card) {
        //self.frontTexture = SKTexture(image: card.getCardFace(Deck.DeckFronts.Default)!)
        //self.backTexture = SKTexture(image: card.getCardBack(Deck.DeckBacks.Default)!)
        backTexture = SKTexture(imageNamed: "cardBack")
        frontTexture = SKTexture(imageNamed: "dsflshf")
        print(card.getCardFace(solitaireScene.SolitaireGame.deck.frontType))
        
        self.faceUp = false
        
        super.init(texture: backTexture, color: UIColor.blackColor(), size: backTexture.size())
        self.userInteractionEnabled = true
    }
    
    func flipCardOver() {
        if faceUp {
            self.texture = self.backTexture
            self.faceUp = false
        } else {
            self.texture = self.frontTexture
            self.faceUp = true
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if touch.tapCount > 1 {
                flipCardOver()
            }
            zPosition++
            // test for where the card was touched
            fromLocation = solitaireScene.snapToCGPoint(position)
            }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if solitaireScene.CGPointToPile(fromLocation!)?.name == solitaireScene.SolitaireGame.deck.name {
                
            } else {
                let location = touch.locationInNode(scene!) // make sure this is scene, not self
                let touchedNode = nodeAtPoint(location)
                touchedNode.position = location
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {

            // test for where the card was touched
            toLocation = solitaireScene.snapToCGPoint(position)
            
            let newPile = solitaireScene.CGPointToPile(toLocation!)
            let oldPile = solitaireScene.CGPointToPile(fromLocation!)
            
            let snapToSpot = SKAction.moveTo(toLocation!, duration: 0.01)
            let goBack = SKAction.moveTo(fromLocation!, duration: 0.01)
            
            if newPile == nil {
                self.runAction(goBack)
            }
            else if newPile != nil && oldPile != nil {
                if solitaireScene.SolitaireGame.checkMove(oldPile!, newPile: newPile!) {
                    self.runAction(snapToSpot)
                    solitaireScene.SolitaireGame.moveCard(oldPile!, toPile: newPile!)
                    
                } else {
                    self.runAction(goBack)
                }
            }
        }
    }
}



class SolitaireScene: SKScene {
    let SolitaireGame = Solitaire()
    let gameDelegate = SolitaireDelegate()

    var cardSize = CGSize(width: 0, height: 0)

    var deckLocation = CGPoint(x: 0, y: 0)
    var wastePileLocation = CGPoint(x: 0, y: 0)
    var foundationLocations = [CGPoint](count: 4, repeatedValue: CGPoint(x: 0, y: 0))
    var tableuLocations = [CGPoint](count: 7, repeatedValue: CGPoint(x: 0, y: 0))
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.cardSize = CGSize(width: self.scene!.size.width/8, height: self.scene!.size.height/4)
        self.deckLocation = CGPoint(x: self.scene!.frame.minX + cardSize.width/2, y: self.scene!.frame.maxY - cardSize.height)
        self.wastePileLocation = CGPoint(x: self.scene!.frame.minX + 3*cardSize.width/2, y: self.scene!.frame.maxY - cardSize.height)
        for var i = 0; i < foundationLocations.count; i++ {
            foundationLocations[i] = CGPoint(x: self.scene!.frame.minX + (CGFloat(4+i))*cardSize.width, y: self.scene!.frame.maxY - cardSize.height)
        }
        for var i = 0; i <  tableuLocations.count; i++ {
            tableuLocations[i] = CGPoint(x: self.scene!.frame.minX + (CGFloat(1+i))*cardSize.width, y: self.scene!.frame.maxY - 2*cardSize.height)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.greenColor()
        
        
        deal()
        gameDelegate.gameDidStart(SolitaireGame)
        while !gameDelegate.isWinner(SolitaireGame) {
            gameDelegate.roundDidStart(SolitaireGame)
            // take a turn
            //turn()
            gameDelegate.roundDidEnd(SolitaireGame)
            gameDelegate.numberOfRounds++
            gameDelegate.increaseScore(SolitaireGame)
        }
        gameDelegate.gameDidEnd(SolitaireGame)
        
        
        
    }
    
    func deal() {
        gameDelegate.deal(self.SolitaireGame)
        var dealtCount = 0
        
        for var i = 0; i < tableuLocations.count; i++ {
            
            for var j = 0; j <= i; j++ {
                let tableuSprite = CardSprite(card: SolitaireGame.tableus[i].cardAt(j)!)
                tableuSprite.size = cardSize
                tableuSprite.position = tableuLocations[i]
                dealtCount++
                self.addChild(tableuSprite)
            }
            let topCard = SolitaireGame.tableus[i].topCard()
            let topCardSprite = nodeAtPoint(tableuLocations[i]) as! CardSprite
            if (topCard != nil) {
                topCardSprite.flipCardOver()
            }
            
        }
        
        var count = 0
        while dealtCount < 52 {
            let deckSprite = CardSprite(card: SolitaireGame.deck.cardAt(count++)!)
            deckSprite.size = cardSize
            deckSprite.position = deckLocation
            self.addChild(deckSprite)
            dealtCount++
        }
        
    }
    
    func snapToCGPoint(oldPoint: CGPoint) -> CGPoint {
        var newPoint = oldPoint
        let deckArea = CGRectMake(deckLocation.x - cardSize.width/2, deckLocation.y - cardSize.height/2, cardSize.width, cardSize.height)
        let wasteArea = CGRectMake(wastePileLocation.x - cardSize.width/2, wastePileLocation.y - cardSize.height/2, cardSize.width, cardSize.height)
        
        var foundationsArea = [CGRect]()
        for location in foundationLocations {
            foundationsArea.append(CGRectMake(location.x - cardSize.width/2, location.y - cardSize.height/2, cardSize.width, cardSize.height))
        }
        
        
        var tableusArea = [CGRect]()
        for location in tableuLocations {
            tableusArea.append(CGRectMake(location.x - cardSize.width/2, location.y - cardSize.height/2, cardSize.width, cardSize.height))
        }
        
        if CGRectContainsPoint(deckArea, oldPoint) {
            newPoint = deckLocation
            return newPoint
        } else if CGRectContainsPoint(wasteArea, oldPoint) {
            newPoint = wastePileLocation
            return newPoint
        } else {
            for var i = 0; i < foundationsArea.count; i++ {
                if CGRectContainsPoint(foundationsArea[i], oldPoint) {
                    newPoint = foundationLocations[i]
                    return newPoint
                }
            }
            for var j = 0; j < tableusArea.count; j++ {
                if CGRectContainsPoint(tableusArea[j], oldPoint) {
                    newPoint = tableuLocations[j]
                    return newPoint
                }
            }
            return newPoint
        }
        
    }
    
    func CGPointToPile(point: CGPoint) -> StackPile? {
        let stackLocation = snapToCGPoint(point)
        if stackLocation == wastePileLocation {
            return SolitaireGame.wastePile
        }
        else if stackLocation == deckLocation {
            return SolitaireGame.deck
        } else {
            for var i = 0; i < foundationLocations.count; i++ {
                if stackLocation == foundationLocations[i] {
                    return SolitaireGame.foundations[i]
                }
            }
            for var j = 0; j < tableuLocations.count; j++ {
                if stackLocation == tableuLocations[j] {
                    return SolitaireGame.tableus[j]
                }
            }
            return nil
        }
        
    }
}
