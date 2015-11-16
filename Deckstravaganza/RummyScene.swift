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
    var touchesBeganClosure: (RummyCardSprite)->Void
    var touchesMovedClosure: (RummyCardSprite)->Void
    var touchesEndedClosure: (RummyCardSprite)->Void
    
    // required to prevent crashing
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // initializer sets the card value and references the gamescene being used
    init(card: Card, touchesBeganClosure: (RummyCardSprite)->Void, touchesMovedClosure: (RummyCardSprite)->Void, touchesEndedClosure: (RummyCardSprite)->Void) {
        self.card = card
        
        self.frontTexture = SKTexture(image: card.getCardFace(Deck.DeckFronts.Default)!)
        self.backTexture = SKTexture(image: card.getCardBack(Deck.DeckBacks.Default)!)
        
        self.touchesBeganClosure = touchesBeganClosure
        self.touchesMovedClosure = touchesMovedClosure
        self.touchesEndedClosure = touchesEndedClosure
        
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
         touchesBeganClosure(self)
        }
    }
    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        touchesMovedClosure(self)
//        for touch in touches {
//            let location = touch.locationInNode(scene!)
//            let touchedNode = nodeAtPoint(location)
//            touchedNode.position = location
//        }
//    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for _ in touches {
            touchesEndedClosure(self)
        }
    }
}

class RummyScene: SKScene {
    let GameScene: GameSceneViewController
    let RummyGame: Rummy
    //let RummyGameDelegate : RummyDelegate
    
    var cardSize = CGSize(width: 0, height: 0)
    
    var deckLocation = CGPoint(x: 0,y: 0)
    var wastePileLocation = CGPoint(x: 0, y: 0)
    var handLocations = [[CGPoint(x: 0,y: 0)]]
    var meldLocation = CGPoint(x: 0,y: 0)
    
    var isWinner = false
    var isPlayerTurn = false
    
    var buttonsOnScreen = [GameViewControllerButton]()
    
    init(gameScene : GameSceneViewController, game: Rummy, /*gameDelegate: RummyDelegate,*/ size: CGSize) {
    
        self.GameScene = gameScene
        self.RummyGame = game // as! Rummy
        //self.RummyGameDelegate = gameDelegate // as! RummyDelegate
        
        super.init(size: size)
        
        // initializes the various CGPoints and CGSizes used by gamescene
        self.cardSize = CGSize(width: self.scene!.size.width/10, height: self.scene!.size.height/5)
        
        // Sets the location for where the deck and waste pile are located in the frame
        self.deckLocation = CGPoint(x: self.scene!.frame.midX - cardSize.width/2, y: self.scene!.frame.midY)
        self.wastePileLocation = CGPoint(x: self.scene!.frame.midX + cardSize.width/2 , y: self.scene!.frame.midY)
        
        // Sets the location for where the melds should be location
        self.meldLocation = CGPoint(x: self.scene!.frame.minX + cardSize.width, y: self.scene!.frame.maxY - cardSize.height)

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
        
        self.shuffle()
        
        // Must first deal the cards, use a GameViewButton to deal
        addDealButton()
        
        for player in RummyGame.players {
            setUserInteractionEnabledPlayerHand(false, player: player)
        }
        
    }
    
    
    // MARK: Function that add buttons to the scene
    func addDealButton() {
        let dealButton = GameViewControllerButton(defaultButtonImage: "start", buttonAction: deal)
        dealButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        dealButton.size = CGSize(width: 100, height: 200)
        self.addChild(dealButton)
    }
    
    func addMeldButton() {
        let meldButton = GameViewControllerButton(defaultButtonImage: "MeldButtonImg", buttonAction: meld)
        meldButton.size = CGSize(width: 100, height: 200)
        meldButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        meldButton.zPosition = 100
        self.addChild(meldButton)
        buttonsOnScreen.append(meldButton)
        
    }
    
    func addDiscardButton() {
        let discardButton = GameViewControllerButton(defaultButtonImage: "DiscardButtonImg", buttonAction: discard)
        discardButton.size = CGSize(width: 100, height: 200)
        discardButton.position = CGPoint(x: CGRectGetMidX(self.frame) + discardButton.size.width, y: CGRectGetMidY(self.frame))
        discardButton.zPosition = 100
        self.addChild(discardButton)
        buttonsOnScreen.append(discardButton)
    }
    
    func addLayOffButton() {
        let layOffButton = GameViewControllerButton(defaultButtonImage: "LayOffButtonImg", buttonAction: layOff)
        layOffButton.size = CGSize(width: 100, height: 200)
        layOffButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + layOffButton.size.height)
        layOffButton.zPosition = 100
        self.addChild(layOffButton)
        buttonsOnScreen.append(layOffButton)
    }
    
    func checkAndAddValidButtonOptions() {
        // Remove all buttons currently on the screen
        self.removeChildrenInArray(buttonsOnScreen)
        self.buttonsOnScreen = []
        
        // if one card is selected discard move add discard button and layoff button
        if self.RummyGame.selectedCards.numberOfCards() == 1 {
            addDiscardButton()
            addLayOffButton()
        }
        // if more than one card is selected add layoff button and meldbutton
        else if self.RummyGame.selectedCards.numberOfCards() > 1 {
            addLayOffButton()
            addMeldButton()
        }
    }
    
    // MARK: Functions used for imlpementing the game rules and moves
    func shuffle() {
        // Create the sprites for the cards that go into the deck
        for index in 0..<self.RummyGame.deck.numberOfCards() {
            let deckSprite = RummyCardSprite(card: self.RummyGame.deck.cardAt(index)!, touchesBeganClosure: touchesBeganClosure, touchesMovedClosure: touchesMovedClosure, touchesEndedClosure: touchesEndedClosure)
            deckSprite.size = cardSize
            deckSprite.position = deckLocation
            self.addChild(deckSprite)
        }
        RummyGame.deal()
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

        // Create the sprites for the cards that go into the players's hands
        for handIndex in 0..<self.RummyGame.playersHands.count {
            for cardIndex in 0..<self.RummyGame.playersHands[handIndex].numberOfCards() {
                let handSprite = self.childNodeWithName("\(self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getRank())\(self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
                handSprite.flipCardOver()
                handSprite.runAction(SKAction.moveTo(handLocations[handIndex][cardIndex], duration: 0.1))
            }
        }
        
        // Create the sprites for the cards that go into the waste pile
        let wastePileSprite = self.childNodeWithName("\(self.RummyGame.wastePile.topCard()!.getRank())\(self.RummyGame.wastePile.topCard()!.getSuit())") as! RummyCardSprite
        wastePileSprite.flipCardOver()
        wastePileSprite.runAction(SKAction.moveTo(wastePileLocation, duration: 0.1))
        
    }
    
    func meld() {
        print("meld")
        var cardSpritesMeld = [RummyCardSprite]()
        for cardIndex in 0..<self.RummyGame.selectedCards.numberOfCards() {
            cardSpritesMeld.append(self.childNodeWithName("\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getRank())\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite)
        }
        if self.RummyGame.isValidMeld(self.RummyGame.selectedCards) {
            // Move the cards to a meld pile
            self.RummyGame.meldCards(self.RummyGame.selectedCards)
            for sprite in cardSpritesMeld {
                sprite.runAction(SKAction.moveTo(meldLocation, duration: 0.5))
            }
        } else {
        
        }
    }
    
    func discard() {
        print("discard")
        let cardSpriteDiscarded = self.childNodeWithName("\(self.RummyGame.selectedCards.cardAt(0)!.getRank())\(self.RummyGame.selectedCards.cardAt(0)!.getSuit())") as! RummyCardSprite
        cardSpriteDiscarded.runAction(SKAction.moveTo(wastePileLocation, duration: 0.5))
        
        self.RummyGame.discard(self.RummyGame.selectedCards.removeCard(cardSpriteDiscarded.card)!)
        checkAndAddValidButtonOptions()
        
        self.RummyGame.turnDidEnd()
        setUserInteractionEnabledDeck(true)
        for player in self.RummyGame.players {
            setUserInteractionEnabledPlayerHand(false, player: player)
        }
        setUserInteractionEnabledWastePile(true)
    }
    
    func layOff() {
        print("layoff")
    }
    
    // MARK: Functions used for recognizing movements and implementing using cardSprites
    func setUserInteractionEnabledDeck(value: Bool) {
        for cardIndex in 0..<self.RummyGame.deck.numberOfCards() {
            let deckSprite = self.childNodeWithName("\(self.RummyGame.deck.cardAt(cardIndex)!.getRank())\(self.RummyGame.deck.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            deckSprite.userInteractionEnabled = value
        }
    }
    
    func setUserInteractionEnabledWastePile(value: Bool) {
        for cardIndex in 0..<self.RummyGame.wastePile.numberOfCards() {
            let wastePileSprite = self.childNodeWithName("\(self.RummyGame.wastePile.cardAt(cardIndex)!.getRank())\(self.RummyGame.wastePile.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            wastePileSprite.userInteractionEnabled = value
        }
    }
    
    func setUserInteractionEnabledPlayerHand(value: Bool, player: Player) {
        for cardIndex in 0..<self.RummyGame.playersHands[player.playerNumber].numberOfCards() {
            let handSprite = self.childNodeWithName("\(self.RummyGame.playersHands[player.playerNumber].cardAt(cardIndex)!.getRank())\(self.RummyGame.playersHands[player.playerNumber].cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            handSprite.userInteractionEnabled = value
        }
    }
    
    func isCardOnTopOfDeck(cardSprite: RummyCardSprite) -> Bool {
        var result = false
        if self.RummyGame.deck.topCard()!.isEqualTo(cardSprite.card, ignoreSuit:  false) {
            result = true
        }
        return result
    }
    
    func isCardOnTopOfWastePile(cardSprite: RummyCardSprite) -> Bool {
        var result = false
        if self.RummyGame.wastePile.numberOfCards() > 0 {
            if self.RummyGame.wastePile.topCard()!.isEqualTo(cardSprite.card, ignoreSuit:  false) {
                result = true
            }
        }
        return result
    }
    
    func cardWasDrawn(cardSprite: RummyCardSprite) {
        self.RummyGame.didDrawCard = true
        
        // Move card into the hand of the player
        cardSprite.runAction(SKAction.moveTo(CGPoint(x:self.handLocations[0][0].x - cardSize.width/3 , y: handLocations[0][0].y), duration: 0.5))
        if cardSprite.faceUp {
            self.RummyGame.drawFromWastePile(cardSprite.card)
        } else {
            cardSprite.flipCardOver()
            self.RummyGame.drawFromDeck(cardSprite.card)
        }
        
        setUserInteractionEnabledDeck(false)
        setUserInteractionEnabledWastePile(false)
        setUserInteractionEnabledPlayerHand(true, player: self.RummyGame.players[0])
    }
    
    
    // MARK: Touch recognizers
    func touchesBeganClosure(cardSprite: RummyCardSprite) {
        print("Began")
        // Card must first be drawn for each turn
        
    }
    
    func touchesMovedClosure(cardSprite: RummyCardSprite) {
        print("Moved")
    }
    
    func touchesEndedClosure(cardSprite: RummyCardSprite) {
        print("Ended")
        if isCardOnTopOfDeck(cardSprite) || isCardOnTopOfWastePile(cardSprite) {
            cardWasDrawn(cardSprite)
        } // Card must already have been drawn
        else {
            if self.RummyGame.selectedCards.contains(cardSprite.card) {
                cardSprite.runAction(SKAction.moveBy(CGVector(dx: 0, dy: 50), duration: 0.5))
                self.RummyGame.selectedCards.removeCard(cardSprite.card)
            } else {
                cardSprite.runAction(SKAction.moveBy(CGVector(dx: 0, dy: -50), duration: 0.5))
                self.RummyGame.addSelectedCard(cardSprite.card)
            }
        }
        checkAndAddValidButtonOptions()
        // Check valid turn
        // Check round ended
        // Check game ended
    }
}
