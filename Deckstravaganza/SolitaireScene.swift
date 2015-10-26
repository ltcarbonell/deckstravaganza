//
//  SolitaireScene.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import SpriteKit

// Extends from SpriteNode to create a specified card sprite
class CardSprite: SKSpriteNode {
    
    // Properties
    let frontTexture: SKTexture
    let backTexture: SKTexture
    var faceUp: Bool
    var card: Card
    
    var solitaireScene: SolitaireScene
    var solitaireGame: Solitaire
    var toLocation: CGPoint?
    var fromLocation: CGPoint?
    
    var newPile: StackPile?
    var oldPile: StackPile?
    
    // required to prevent crashing
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // initializer sets the card value and references the gamescene being used
    init(gameScene: GameSceneViewController, card: Card) {
        self.card = card
        self.solitaireScene = gameScene.solitaireScene
        self.solitaireGame = solitaireScene.SolitaireGame
        
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
    
    // draws card from deck pile and places in waste pile
    // called when deck pile is tapped
    func drawCard() {
        toLocation = solitaireScene.snapToCGPoint(solitaireScene.wastePileLocation)
        newPile = solitaireScene.CGPointToPile(toLocation!)!
        self.flipCardOver()
        self.zPosition = CGFloat(solitaireScene.SolitaireGame.wastePile.numberOfCards())
        solitaireScene.SolitaireGame.moveTopCard(oldPile!, toPile: newPile!)
        self.runAction(SKAction.moveTo(toLocation!, duration: 0.25))
    }
    
    // updates the current tableu locations based off of the number of cards in tableu piles
    // called once the card is moved from solitaire game
    func didMoveTopCardSprite() {
        //solitaireScene.updateTableuLocations()
        for i in 0..<solitaireScene.tableuLocations.count {
            if toLocation == solitaireScene.tableuLocations[i] && toLocation != fromLocation {
                solitaireScene.tableuLocations[i].y = solitaireScene.tableuLocations[i].y + solitaireScene.cardOffset(6)
                toLocation!.y = solitaireScene.tableuLocations[i].y
                zPosition = CGFloat(solitaireGame.tableus[i].numberOfCards())
            }
            if fromLocation == solitaireScene.tableuLocations[i] && toLocation != fromLocation {
                solitaireScene.tableuLocations[i].y = solitaireScene.tableuLocations[i].y - solitaireScene.cardOffset(6)
            }
        }
        self.runAction(SKAction.moveTo(toLocation!, duration: 0.01))
        solitaireGame.moveTopCard(oldPile!, toPile: newPile!)
        solitaireScene.flipTopCards()
    }
    
    // called when a card is moved that is not the top card
    // takes in a integer that represents the total number of cards being moved
    func didMoveNonTopCardSprite(number: Int) {
        solitaireGame.moveGroupedCards(number, fromPile: oldPile!, toPile: newPile!)
    }
    
    func getAboveCards(pile: StackPile) -> [Card] {
        var cards:[Card] = [self.card]
        for index in 0..<pile.numberOfCards() {
            if self.card.isEqualTo((pile.cardAt(pile.numberOfCards() - index - 1))!) {
                return cards
            }
            else {
                cards.append(pile.cardAt(pile.numberOfCards() - index - 1)!)
            }
        }
        return cards
    }
    
    // MARK:
    /* TOUCH CONTROLS */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for _ in touches {
            zPosition=zPosition+50
            // test for where the card was touched
            fromLocation = solitaireScene.snapToCGPoint(position)
            }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if faceUp {
                let location = touch.locationInNode(scene!) // make sure this is scene, not self
                let touchedNode = nodeAtPoint(location)
                touchedNode.position = location
                
                let touchedPile = solitaireScene.CGPointToPile(fromLocation!)
                if touchedPile != nil {
                    let aboveCards = getAboveCards(touchedPile!)
                    //let aboveCards:[Card] = []
                    for index in 0..<aboveCards.count {
                        let other = solitaireScene.childNodeWithName("\(aboveCards[index].getRank())\(aboveCards[index].getSuit())")
                        other?.position.y = location.y + solitaireScene.cardOffset(6*index+6)
                        other?.position.x = location.x
                        other?.zPosition = touchedNode.zPosition + CGFloat(index)
                    }
                }
                
                
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for _ in touches {
            solitaireScene.SolitaireGame.printPileNumbers()
            // test for where the card was touched
            toLocation = solitaireScene.snapToCGPoint(position)
            
            // find where the card is going to and where it is coming from
            newPile = solitaireScene.CGPointToPile(toLocation!)
            oldPile = solitaireScene.CGPointToPile(fromLocation!)
            
            print(self.card.getSuit(),self.card.getRank())
            
            // creates an action that will move card back to the location it came from
            let goBack = SKAction.moveTo(fromLocation!, duration: 0.01)
            
            let originalZPosition = zPosition - 50
            
            // of the new pile is not a valid position, move back to correct location
            if newPile == nil {
                self.runAction(goBack)
                zPosition = originalZPosition
            }
            // if both piles are valid determine where the card is going to and coming from
            else if newPile != nil && oldPile != nil {
                // if the deck is tapped
                if newPile!.name == solitaireGame.deck.name && oldPile!.name == solitaireGame.deck.name {
                    drawCard()
                    // if deck is empty, reload the deck with cards from waste pile
                    if solitaireGame.deck.numberOfCards() == 0 {
                        solitaireScene.addReloadOption()
                    }
                } else {
                    
                    print(oldPile!.numberOfCards(), newPile!.numberOfCards())
                    // checks if a valid move
                    if solitaireGame.checkMove(card, previousPile: oldPile!, newPile: newPile!) {
                        print(self.card.getRank(),self.card.getSuit())
                        // if the card moves is equal to the top card, only need to move top card
                        if self.card.isEqualTo(oldPile!.topCard()!) {
                            didMoveTopCardSprite()
                        }
                        // else if the card moved isnt the top card
                        else {
                            for index in 0..<oldPile!.numberOfCards() {
                                // find index of the correct card then move the card at the correct index
                                if self.card.isEqualTo(oldPile!.cardAt(index)!) {
                                    print("Moving Group with \(card.getRank()) of \(card.getSuit()) and index \(index)")
                                    didMoveNonTopCardSprite(index)
                                    break
                                }
                            }
                        }
                        
                        solitaireGame.printPileNumbers()
                    // if invalid move, go back to position
                    } else {
                        self.runAction(goBack)
                        zPosition = originalZPosition
                    }
                }
            }
        }
    }
}



class SolitaireScene: SKScene {
    let GameScene : GameSceneViewController
    let SolitaireGame : Solitaire
    let SolitaireGameDelegate : SolitaireDelegate

    var cardSize = CGSize(width: 0, height: 0)
    var cardSprites:[CardSprite] = []

    // defines the locations for the various piles in scene
    var deckLocation = CGPoint(x: 0, y: 0)
    var wastePileLocation = CGPoint(x: 0, y: 0)
    var foundationLocations = [CGPoint](count: 4, repeatedValue: CGPoint(x: 0, y: 0))
    var tableuLocations = [CGPoint](count: 7, repeatedValue: CGPoint(x: 0, y: 0))
    
    var reloadSprite: GameViewControllerButton?
    
    init(gameScene : GameSceneViewController, size: CGSize) {
        self.GameScene = gameScene
        self.SolitaireGame = self.GameScene.solitaireGame!
        self.SolitaireGameDelegate = self.GameScene.solitaireGameDelegate!
        
        super.init(size: size)
        
        // initializes the various CGPoints and CGSizes used by gamescene
        self.cardSize = CGSize(width: self.scene!.size.width/8, height: self.scene!.size.height/4)
        self.deckLocation = CGPoint(x: self.scene!.frame.minX + cardSize.width/2, y: self.scene!.frame.maxY - cardSize.height)
        self.wastePileLocation = CGPoint(x: self.scene!.frame.minX + 3*cardSize.width/2, y: self.scene!.frame.maxY - cardSize.height)
        for var i = 0; i < foundationLocations.count; i++ {
            foundationLocations[i] = CGPoint(x: self.scene!.frame.minX + (CGFloat(4+i))*cardSize.width, y: self.scene!.frame.maxY - cardSize.height)
        }
        for i in 0..<7 {
            tableuLocations[i] = CGPoint(x: self.scene!.frame.minX + (CGFloat(1+i))*cardSize.width, y: self.scene!.frame.maxY - 2*cardSize.height)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.greenColor()
        
        self.deal()
        SolitaireGameDelegate.gameDidStart(SolitaireGame)
        while !SolitaireGameDelegate.isWinner(SolitaireGame) {
            SolitaireGameDelegate.roundDidStart(SolitaireGame)
            // take a turn
            //turn()
            SolitaireGameDelegate.roundDidEnd(SolitaireGame)
            SolitaireGameDelegate.numberOfRounds++
            SolitaireGameDelegate.increaseScore(SolitaireGame)
        }
        SolitaireGameDelegate.gameDidEnd(SolitaireGame)
    }
    
    func deal() {
        SolitaireGameDelegate.deal(self.SolitaireGame)
        var dealtCount = 0
        
        // staggers the piles in the tableus so parts of all cards are visible
        for var i = 0; i < tableuLocations.count; i++ {
            for var j = 0; j <= i; j++ {
                let tableuSprite = CardSprite(gameScene: self.GameScene, card: self.SolitaireGame.tableus[i].cardAt(j)!)
                tableuSprite.size = cardSize
                tableuLocations[i].y = tableuLocations[i].y + cardOffset(j)
                tableuSprite.position = tableuLocations[i]
                tableuSprite.zPosition = CGFloat(j)
                dealtCount++
                cardSprites.append(tableuSprite)
                self.addChild(tableuSprite)
            }
        }
        
        // places the rest of the cards in the deck pile
        var count = 0
        while dealtCount < 52 {
            let deckSprite = CardSprite(gameScene: self.GameScene, card: self.SolitaireGame.deck.cardAt(count++)!)
            deckSprite.size = cardSize
            deckSprite.position = deckLocation
            cardSprites.append(deckSprite)
            self.addChild(deckSprite)
            dealtCount++
        }
        flipTopCards()
    }
    
    // used to offset the cards in piles
    func cardOffset(index: Int) -> CGFloat {
        let cardOffset = -cardSize.height/40
        return CGFloat(index) * cardOffset
    }
    
    // takes in a CGPoint and returns the CGPoint of the pile at that locations
    // returns nil if no pile
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
    
    // Takes in a CGPoint and returns the StackPile at that location
    // Uses snapToCGPoint to ensure the CGPoints are correct
    // Returns nil if no stackpile at point
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
    
    // flips over all the top cards of the tableus to be face up
    // called after a move has completed
    func flipTopCards() {
        for var i = 0; i < tableuLocations.count; i++ {
            let topCard = self.SolitaireGame.tableus[i].topCard()
            if (topCard != nil) {
                let topCardSprite = nodeAtPoint(tableuLocations[i]) as! CardSprite
                if !topCardSprite.faceUp {
                    topCardSprite.flipCardOver()
                }
            }
        }
    }
    
    // adds the reload deck sprite to scene only when the deck is empty
    func addReloadOption() {
        reloadSprite = GameViewControllerButton(defaultButtonImage: "button", buttonAction: reloadDeck)
        reloadSprite!.size = cardSize
        reloadSprite!.position = deckLocation
        addChild(reloadSprite!)
    }
    
    // moves the card sprites from the waste pile back into the deck pile
    func reloadDeck() {
        reloadSprite?.removeFromParent()
        let cardNodes = nodesAtPoint(wastePileLocation) as! [CardSprite]
        for node in cardNodes {
            node.removeFromParent()
        }
        for _ in 0..<self.SolitaireGame.wastePile.numberOfCards() {
            self.SolitaireGame.deck.addToStackFromLastCardOf(self.SolitaireGame.wastePile)
        }
        self.SolitaireGame.printPileNumbers()
        for index in 0..<self.SolitaireGame.deck.numberOfCards() {
            let deckSprite = CardSprite(gameScene: self.GameScene, card: self.SolitaireGame.deck.cardAt(index)!)
            deckSprite.size = cardSize
            deckSprite.position = deckLocation
            self.addChild(deckSprite)
        }
    }
    
    // updates the tableulocations after a card is moved
    // NOT CURRENTLY IMPLEMENTED
    /*func updateTableuLocations() {
        for i in 0..<7 {
            let multiplier = SolitaireGame.tableus[i].numberOfCards()
            tableuLocations[i] = CGPoint(x: self.scene!.frame.minX + (CGFloat(1+i))*cardSize.width, y: self.scene!.frame.maxY - 2*cardSize.height + cardOffset(multiplier))
        }
    }*/
}
