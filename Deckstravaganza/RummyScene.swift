//
//  RummyScene.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 10/26/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import SpriteKit

class RummyCardSprite: SKSpriteNode {
    
    // Properties
    let frontTexture: SKTexture
    let backTexture: SKTexture
    var faceUp: Bool
    var card: Card
    
    var rummyScene: RummyScene
    var rummyGame: Rummy
    
    // required to prevent crashing
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // initializer sets the card value and references the gamescene being used
    init(gameScene: GameSceneViewController, card: Card) {
        self.card = card
        self.rummyScene = gameScene.gameScene! as! RummyScene
        self.rummyGame = gameScene.game!
        
        self.frontTexture = SKTexture(image: card.getCardFace(Deck.DeckFronts.Default)!)
        self.backTexture = SKTexture(image: card.getCardBack(Deck.DeckBacks.Default)!)
        
        self.faceUp = false
        
        super.init(texture: backTexture, color: UIColor.blackColor(), size: backTexture.size())
        self.userInteractionEnabled = true
        self.name = "\(card.getRank())\(card.getSuit())"
    }
    
    // flips of card by changing the tecture
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
        for _ in touches {
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(scene!)
            let touchedNode = nodeAtPoint(location)
            touchedNode.position = location
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for _ in touches {
            
        }
    }
}

class RummyScene: SKScene {
    
    let GameScene : GameSceneViewController
    let RummyGame : Rummy
    let RummyGameDelegate : RummyDelegate
    
    var cardSize = CGSize(width: 0, height: 0)
    
    var deckLocation = CGPoint(x: 0,y: 0)
    var wastePileLocation = CGPoint(x: 0, y: 0)
    var handLocations = [[CGPoint(x: 0,y: 0)]]
    
    init(gameScene : GameSceneViewController, game: Rummy, gameDelegate: RummyDelegate, size: CGSize) {
        
        self.GameScene = gameScene
        self.RummyGame = game // as! Rummy
        self.RummyGameDelegate = gameDelegate // as! RummyDelegate
        
        super.init(size: size)
        
        // initializes the various CGPoints and CGSizes used by gamescene
        self.cardSize = CGSize(width: self.scene!.size.width/10, height: self.scene!.size.height/5)
        
        // Sets the location for where the deck and waste pile are located in the frame
        self.deckLocation = CGPoint(x: self.scene!.frame.midX - cardSize.width/2, y: self.scene!.frame.midY)
        self.wastePileLocation = CGPoint(x: self.scene!.frame.midX + cardSize.width/2 , y: self.scene!.frame.midY)

        // Sets the locations of where the players' hands begin
        switch RummyGame.playersHands.count {
            case 2:
                self.handLocations = [[CGPoint(x: self.frame.midX,y: self.frame.maxY-cardSize.height)], [CGPoint(x: self.frame.midX, y: self.frame.minY+cardSize.height)]]
            case 3:
                break
            case 4:
                break
                //self.handLocations = [[CGPoint(x: self.frame.midX,y: self.frame.maxY-cardSize.height)],[CGPoint(x: self.frame.maxX-cardSize.width, y: self.frame.midY)], [CGPoint(x: self.frame.midX, y: self.frame.minY+cardSize.height)],[CGPoint(x: self.frame.minX+cardSize.width, y: self.frame.midY)]]
            case 5:
                break
            case 6:
                break
            default:
                break
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blueColor()
        
        // Must first deal the cards
        self.deal()
        
        // Once cards are dealt
            //begin hand
                //begin round
                    //begin turn player i
                        // if player score = 500 -> end turn, end round, end hand, end game
                    // end turn player i, begin turn player i+1, repeat for n turns
                //end round
            //end hand
        // Redeal cards -> begin hand if score != 500
        
        
    }
    
    func deal() {
        
        
        // First set the location of the players' hands based on the number of players
        for handIndex in 0..<handLocations.count {
            for cardIndex in 0..<RummyGame.playersHands[handIndex].numberOfCards() {
                if handLocations[handIndex][0].x == self.frame.midX {
                    handLocations[handIndex].append(CGPoint(x:handLocations[handIndex][0].x + CGFloat(cardIndex+1)*cardSize.width/3 , y: handLocations[handIndex][0].y))
                }
                
            }
        }
        
        // Create the sprites for the cards that go into the deck
        for index in 0..<self.RummyGame.deck.numberOfCards() {
            let deckSprite = RummyCardSprite(gameScene: self.GameScene, card: self.RummyGame.deck.cardAt(index)!)
            deckSprite.size = cardSize
            deckSprite.position = deckLocation
            self.addChild(deckSprite)
        }
        
        RummyGameDelegate.deal(self.RummyGame)
        
        // Create the sprites for the cards that go into the players's hands
        for handIndex in 0..<self.RummyGame.playersHands.count {
            for cardIndex in 0..<self.RummyGame.playersHands[handIndex].numberOfCards() {
                //let handSprite = RummyCardSprite(gameScene: self.GameScene, card: self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!)
                
                let handSprite = self.childNodeWithName("\(self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getRank())\(self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getSuit())") //as! RummyCardSprite
                print(handSprite!.name)
                //handSprite.size = cardSize
                //if handSprite != nil {
                    //handSprite!.runAction(SKAction.moveTo(handLocations[handIndex][cardIndex], duration: 0.1))
                    //handSprite.flipCardOver()
                //}
                
                //handSprite. = handLocations[handIndex][cardIndex]
                
                //self.addChild(handSprite)
            }
        }
        
        // Create the sprites for the cards that go into the waste pile
        //let wasteCardSprite = RummyCardSprite(gameScene: self.GameScene, card: self.RummyGame.wastePile.topCard()!)
        //wasteCardSprite.size = cardSize
//        wasteCardSprite.position = wastePileLocation
//        wasteCardSprite.flipCardOver()
//        self.addChild(wasteCardSprite)
        
    }
    
    func checkMove() {
        
    }
}