//
//  SolitaireScene.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit
import SpriteKit

class CardConstants {
    let DRAGGED_ZINDEX : CGFloat = 9999;
    
    let CARD_CASCADE_OFFSET = 15;
    
    let PILE_X_OFFSET : CGFloat = 7;
    let PILE_Y_OFFSET : CGFloat = 7;
    
    let TABLEU_LEFT_OFFSET : CGFloat = 0.75;
    let FOUNDATION_LEFT_OFFSET : CGFloat = 4;
    
    let POSITION_CORRECTLY_TIME = 0.5;
    
    let DECK_X_FACTOR : CGFloat = 3/4;
    let TOP_ROW_Y_FACTOR : CGFloat = 1;
    
    let MOVING_Y_ADJUSTMENT : CGFloat = 10;
}

// Extends from SpriteNode to create a specified card sprite
class CardSprite: SKSpriteNode {
    
    // Constants
    let cardConstants = CardConstants();
    
    // Properties
    let card: Card
    let frontTexture: SKTexture
    let backTexture: SKTexture
    var faceUp: Bool
    
    weak var solitaireScene: SolitaireScene?
    weak var solitaireGame: Solitaire?
    
    var toLocation: CGPoint?        // Where the user lifted their finger
    var fromLocation: CGPoint?      // Where the user began dragging
    
    weak var newPile: StackPile?    // Pile to which the user dragged
    weak var oldPile: StackPile?
    // Original pile from which the user dragged
    
    var touchedHidden = false;      // Did the user touch a card that was face down?
    var flipHidden = false;         // Should the hidden card be flipped?
    var ignoreTouch = false;        // Should the last touch be ignored?  Used when user touches a card in the foundation pile.
    
    var oldYPositions : [CGFloat] = [];      //Array of Y values when cards started moving
    
    // required to prevent crashing
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // initializer sets the card value and references the gamescene being used
    init(gameScene: SolitaireScene, card: Card) {
        self.card = card
        self.solitaireScene = gameScene
        self.solitaireGame = gameScene.SolitaireGame
        
        self.frontTexture = SKTexture(image: card.getCardFace(Deck.DeckFronts.Default)!)
        self.backTexture = SKTexture(image: card.getCardBack(Deck.DeckBacks.Default)!)
        
        self.faceUp = false
        
        super.init(texture: backTexture, color: UIColor.blackColor(), size: backTexture.size())
        
        self.userInteractionEnabled = true
        self.name = "\(card.getRank())\(card.getSuit())"
    }
    
    // flips of card by changing the tecture
    func flipCardOver() {
        if(!faceUp) {
            self.texture = self.frontTexture
            self.faceUp = true
            self.userInteractionEnabled = true
        }
    }
    
    // draws card from deck pile and places in waste pile
    // called when deck pile is tapped
    func drawCard() {
        toLocation = solitaireScene!.snapToCGPoint(solitaireScene!.wastePileLocation)
        newPile = solitaireGame!.wastePile
        oldPile = solitaireGame!.deck
        
        self.flipCardOver()
        self.zPosition = CGFloat(solitaireScene!.SolitaireGame.wastePile.numberOfCards())
        
        solitaireScene!.SolitaireGame.moveTopCard(oldPile!, toPile: newPile!)
        self.runAction(SKAction.moveTo(toLocation!, duration: 0.25))
        
        // If the deck is empty, reload the deck with cards from waste pile
        if solitaireGame!.deck.numberOfCards() == 0 {
            solitaireScene!.addReloadOption()
        }
    }
    
    func movePile() {
        let tempStack : StackPile = StackPile();
        var yPositionDeltas : [CGFloat] = [];
        let baseYPosition : CGFloat;
        
        if(newPile!.topCard() != nil && toLocation!.y != solitaireScene!.topRowYPos) {
            baseYPosition = nodeFromCard(newPile!.topCard()!).position.y - CGFloat(cardConstants.CARD_CASCADE_OFFSET);
        } else if(toLocation!.y == solitaireScene!.bottomRowYPos) {
            baseYPosition = solitaireScene!.bottomRowYPos;
        } else {
            baseYPosition = solitaireScene!.topRowYPos;
        }
        
        while(!oldPile!.isEmpty() && !oldPile!.topCard()!.isEqualTo(self.card)) {
            let tempCard = oldPile!.pull()!;
            let cardNode = nodeFromCard(tempCard);
            
            yPositionDeltas.append(self.position.y - cardNode.position.y);
            
            tempStack.push(tempCard);
        }
        
        // Add self
        yPositionDeltas.append(0);
        tempStack.push(oldPile!.pull()!);
        
        var count = tempStack.numberOfCards();
        while(!tempStack.isEmpty()) {
            let tempCard = tempStack.pull()!;
            let cardNode = nodeFromCard(tempCard);
            let cardPosition : CGPoint;
            
            if(baseYPosition != solitaireScene!.topRowYPos) {
                cardPosition = CGPoint(x: toLocation!.x, y: (CGFloat(baseYPosition) - yPositionDeltas[--count]));
            } else {
                cardPosition = CGPoint(x: toLocation!.x, y: baseYPosition);
            }
            
            cardNode.zPosition = CGFloat(newPile!.numberOfCards());
            cardNode.runAction(SKAction.moveTo(cardPosition, duration: cardConstants.POSITION_CORRECTLY_TIME));
            
            newPile!.push(tempCard);
        }
        
        solitaireScene!.flipTopCards();
    }
    
    func nodeFromCard(card: Card) -> CardSprite {
        let cardName = "\(card.getRank())\(card.getSuit())";
        
        return self.solitaireScene!.childNodeWithName(cardName) as! CardSprite;
    }
    
    /**
    * Returns all face up cards in the stack starting with the top card facing toward the user.
    */
    func getAboveCards(pile: StackPile) -> [Card] {
        var cards:[Card] = [self.card]
        
        // If this is the waste pile, just return the top card.
        if(!self.solitaireGame!.wastePile.isEmpty() && pile.topCard()!.isEqualTo(self.solitaireGame!.wastePile.topCard()!, ignoreSuit: false)) {
            return cards;
        }
        
        var reachedSelectedCard = false;
        for index in 0..<pile.numberOfCards() {
            let card = pile.cardAt(index)!;
            let cardNode = nodeFromCard(card);
            
            if(!cardNode.faceUp) {
                continue;
            } else if(self.card.isEqualTo(card)) {
                reachedSelectedCard = true;
            } else if(reachedSelectedCard) {
                cards.append(card);
            }
        }
        
        return cards
    }
    
    // MARK: TOUCH CONTROLS 
    
    /**
    * Increase this card's z-index so it is above all other cards and save the fromLocation.
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        fromLocation = solitaireScene!.snapToCGPoint(self.position);
        let touchedPile = solitaireScene!.CGPointToPile(fromLocation!);
        
        if(touchedPile != nil) {
            if(!faceUp) {
                touchedHidden = true;
                
                if(!faceUp && touchedPile!.topCard()!.isEqualTo(self.card)) {
                    // Only flip the card over if it is the first card on the stack and it isn't already flipped.
                    flipHidden = true;
                }
            } else {
                if(fromLocation!.y == solitaireScene!.bottomRowYPos || fromLocation!.x == solitaireScene!.wastePileLocation.x) {
                    let cardsAbove = getAboveCards(touchedPile!);
                    
                    for index in 0..<cardsAbove.count {
                        let tempCard = nodeFromCard(cardsAbove[index]);
                        
                        oldYPositions.append(tempCard.position.y);
                        tempCard.zPosition = cardConstants.DRAGGED_ZINDEX + CGFloat(index);
                    }
                    
                    touchedHidden = false;
                    flipHidden = false;
                    ignoreTouch = false;
                } else {
                    ignoreTouch = true;
                }
            }
            
        }
    }
    
    /**
    * Move the card being dragged and any cards above it with the user's finger.
    */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!;
        
        if (faceUp && !ignoreTouch) {
            let location = touch.locationInNode(scene!) // make sure this is scene, not self
            let touchedNode = nodeAtPoint(location)
            touchedNode.position = location
            
            let touchedPile = solitaireScene!.CGPointToPile(fromLocation!)
            if touchedPile != nil {
                let aboveCards = getAboveCards(touchedPile!)
                
                for index in 0..<aboveCards.count {
                    let tempCard = nodeFromCard(aboveCards[index]);
                    let tempCardYOffset = CGFloat(-(cardConstants.CARD_CASCADE_OFFSET * index)) - (0.5 * solitaireScene!.cardSize.height) + cardConstants.MOVING_Y_ADJUSTMENT;
                    
                    tempCard.position.y = location.y + tempCardYOffset;
                    tempCard.position.x = location.x
                }
            }
        }
    }
    
    /**
    * Determine if the move is valid.  If it wasn't move the cards back to the original stack.
    * Otherwise, card all cards in the moved stack to the new stack.
    */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchedPile = solitaireScene!.CGPointToPile(fromLocation!);
        
        // test for where the card was touched
        toLocation = solitaireScene!.snapToCGPoint(position)
        
        // find where the card is going to and where it is coming from
        newPile = solitaireScene!.CGPointToPile(toLocation!)
        oldPile = solitaireScene!.CGPointToPile(fromLocation!)
        
        if(touchedHidden) {
            if(flipHidden) {
                if(newPile!.name == solitaireGame!.deck.name && oldPile!.name == solitaireGame!.deck.name) {
                    drawCard();
                } else {
                    flipCardOver();
                }
                
                touchedHidden = false;
                flipHidden = false;
            }
        } else if(!ignoreTouch) {
            // Function variables
            let animationDuration = 0.5;
            
            // Closure for handling moving a card back to oldPile
            let moveCardsBack = {
                () -> Void in
                
                let cardsAbove = self.getAboveCards(touchedPile!);
                let cardBelow = self.oldPile?.cardAt(self.oldPile!.numberOfCards() - cardsAbove.count - 1);
                var cardBelowNode : CardSprite? = nil;
                
                if(cardBelow != nil) {
                    cardBelowNode = self.nodeFromCard(cardBelow!);
                }
                
                for(var index = 0; index < cardsAbove.count; index++) {
                    let tempCardName = "\(cardsAbove[index].getRank())\(cardsAbove[index].getSuit())";
                    let tempCard = self.solitaireScene!.childNodeWithName(tempCardName);
                    let tempCardYPosition : CGFloat;
                    let tempCardZPosition : CGFloat;
                    
                    if(cardBelowNode != nil) {
                        tempCardYPosition = cardBelowNode!.position.y - ((CGFloat(index) + 1) * CGFloat(self.cardConstants.CARD_CASCADE_OFFSET));
                        tempCardZPosition = cardBelowNode!.zPosition + CGFloat(index) + 1;
                    } else {
                        tempCardYPosition = self.fromLocation!.y;
                        tempCardZPosition = 0;
                    }
                    
                    let tempCardLocation = CGPoint(x: self.fromLocation!.x, y: tempCardYPosition);
                    
                    tempCard!.zPosition = tempCardZPosition;
                    
                    tempCard!.runAction(SKAction.moveTo(tempCardLocation, duration: animationDuration));
                }
            }
            
            if newPile == nil {
                // If the new pile is not a valid position, move back to correct location
                moveCardsBack();
            } else if newPile != nil && oldPile != nil {
                // If both piles are valid determine where the card is going to and coming from and check if the move is valid
                if solitaireGame!.checkMove(card, previousPile: oldPile!, newPile: newPile!) {
                    if(toLocation! != fromLocation!) {
                        movePile();
                        
                        let isFoundation = solitaireScene!.foundationsContainPoint(toLocation!);
                        if(self.card.getRank() == .King && isFoundation) {
                            // Check if the game is over.
                            let foundationCardCount = solitaireGame!.foundation1.count() + solitaireGame!.foundation2.count() + solitaireGame!.foundation3.count() + solitaireGame!.foundation3.count();
                            
                            if(foundationCardCount >= 52) {
                                solitaireScene!.endGame();
                            }
                        } else if(isFoundation) {
                            // No need to keep references to the solitaireScene and solitaireGame anymore.
                            self.solitaireScene = nil;
                            self.solitaireGame = nil;
                            self.newPile = nil;
                            self.oldPile = nil;
                        }
                    }
                } else {
                    // Invalid move.  Move stack back to original location.
                    moveCardsBack();
                }
            }
        }
        
        ignoreTouch = false;
    }
}



class SolitaireScene: SKScene {
    let GameScene : GameSceneViewController
    let SolitaireGame : Solitaire
    let SolitaireGameDelegate : SolitaireDelegate
    let cardConstants = CardConstants();

    // Card variables
    var cardSize = CGSize(width: 0, height: 0)
    var cardSprites:[CardSprite] = []

    // Locations for the various piles in scene
    var deckLocation = CGPoint(x: 0, y: 0)
    var wastePileLocation = CGPoint(x: 0, y: 0)
    var foundationLocations = [CGPoint](count: 4, repeatedValue: CGPoint(x: 0, y: 0))
    var tableuLocations = [CGPoint](count: 7, repeatedValue: CGPoint(x: 0, y: 0))
    
    // End of Game variables
    var reloadSprite: GameViewControllerButton?
    var endMessageBackground: SKSpriteNode?;
    let endMessageBackgroundTexture: SKTexture = SKTexture(imageNamed: "MessageBackgroundTexture");
    let endMessage = SKLabelNode(text: "Congratulations! You won.");
    let endButton = SKLabelNode(text: "New Game");
    var gameOver = false;
    
    
    // Position variables
    var deckXPos : CGFloat = 0;
    var topRowYPos : CGFloat = 0;
    var bottomRowYPos : CGFloat = 0;
    var wasteXPos : CGFloat = 0;
    
    var newGame: Bool = true;
    
    init(gameScene : GameSceneViewController, game: Solitaire, gameDelegate: SolitaireDelegate, size: CGSize) {
        newGame = true;
        
        self.GameScene = gameScene
        self.SolitaireGame = game
        self.SolitaireGameDelegate = gameDelegate
        
        super.init(size: size)
        
        // initializes the various CGPoints and CGSizes used by gamescene
        self.cardSize = CGSize(width: self.scene!.size.width/8, height: self.scene!.size.height/4)
        
        // Set pile locations.
        deckXPos = self.scene!.frame.minX + (cardConstants.DECK_X_FACTOR * cardSize.width);
        wasteXPos = deckXPos + cardSize.width + 15;
        topRowYPos = self.scene!.frame.maxY - (cardConstants.TOP_ROW_Y_FACTOR * cardSize.height);
        bottomRowYPos = self.scene!.frame.maxY - (2.2 * cardSize.height);
        
        self.deckLocation = CGPoint(x: deckXPos, y: topRowYPos)
        self.wastePileLocation = CGPoint(x: wasteXPos, y: topRowYPos)
        
        for var i = 0; i < foundationLocations.count; i++ {
            let xPos = self.scene!.frame.minX + ((cardConstants.FOUNDATION_LEFT_OFFSET + CGFloat(i)) * cardSize.width) + (cardConstants.PILE_X_OFFSET * CGFloat(i));
            
            foundationLocations[i] = CGPoint(x: xPos, y: topRowYPos);
        }
        
        for i in 0..<7 {
            let xPos = self.scene!.frame.minX + ((cardConstants.TABLEU_LEFT_OFFSET + CGFloat(i)) * cardSize.width) + (cardConstants.PILE_X_OFFSET * CGFloat(i));
            
            tableuLocations[i] = CGPoint(x: xPos, y: bottomRowYPos);
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.greenColor()
        
        if(newGame) {
            self.deal()
        }
        
        newGame = false;
        
//        SolitaireGameDelegate.gameDidStart(SolitaireGame)
//        
//        while !SolitaireGameDelegate.isWinner(SolitaireGame) {
//            SolitaireGameDelegate.roundDidStart(SolitaireGame)
//            
//            // take a turn
//            SolitaireGameDelegate.roundDidEnd(SolitaireGame)
//            SolitaireGameDelegate.numberOfRounds++
//            SolitaireGameDelegate.increaseScore(SolitaireGame)
//        }
//        
//        SolitaireGameDelegate.gameDidEnd(SolitaireGame)
    }
    
    func deal() {
        var dealtCount = 0;
        
        SolitaireGameDelegate.deal(self.SolitaireGame);
        
        // staggers the piles in the tableus so parts of all cards are visible
        for var i = 0; i < tableuLocations.count; i++ {
            for var j = 0; j <= i; j++ {
                let newTableuCardSprite = CardSprite(gameScene: self, card: self.SolitaireGame.tableus[i].cardAt(j)!)
                
                //tableuLocations[i].y = tableuLocations[i].y + cardOffset(j)
                let cardLocation = CGPoint(x: tableuLocations[i].x, y: tableuLocations[i].y + cardOffset(j));
                
                newTableuCardSprite.size = cardSize
                newTableuCardSprite.position = cardLocation;
                newTableuCardSprite.zPosition = CGFloat(j)
                
                cardSprites.append(newTableuCardSprite)
                self.addChild(newTableuCardSprite)
                
                dealtCount++
            }
        }
        
        // places the rest of the cards in the deck pile
        var count = 0
        while dealtCount < 52 {
            let newDeckCardSprite = CardSprite(gameScene: self, card: self.SolitaireGame.deck.cardAt(count++)!);
            
            newDeckCardSprite.size = cardSize
            newDeckCardSprite.position = deckLocation
            
            cardSprites.append(newDeckCardSprite)
            self.addChild(newDeckCardSprite)
            
            dealtCount++
        }
        
        flipTopCards()
    }
    
    // used to offset the cards in piles
    func cardOffset(index: Int) -> CGFloat {
        let cardOffset = CGFloat(-cardConstants.CARD_CASCADE_OFFSET);
        
        return CGFloat(index) * cardOffset;
    }
    
    // takes in a CGPoint and returns the CGPoint of the pile at that locations
    // returns nil if no pile
    func snapToCGPoint(oldPoint: CGPoint) -> CGPoint {
        let deckArea = CGRectMake(deckLocation.x - cardSize.width/2, deckLocation.y - cardSize.height/2, cardSize.width, cardSize.height)
        let wasteArea = CGRectMake(wastePileLocation.x - cardSize.width/2, wastePileLocation.y - cardSize.height/2, cardSize.width, cardSize.height)
        
        var foundationsArea = [CGRect]()
        for location in foundationLocations {
            foundationsArea.append(CGRectMake(location.x - cardSize.width/2, location.y - cardSize.height/2, cardSize.width, cardSize.height))
        }
        
        var tableusArea = [CGRect]()
        for(var index = 0; index < tableuLocations.count; index++) {
            let cardsInTableu = SolitaireGame.tableus[index].numberOfCards();
            let tableuHeight = CGFloat(cardsInTableu * cardConstants.CARD_CASCADE_OFFSET) + cardSize.height;
            
            tableusArea.append(CGRectMake(tableuLocations[index].x - (cardSize.width / 2), tableuLocations[index].y - (tableuHeight / 2), cardSize.width, tableuHeight));
        }
        
        if CGRectContainsPoint(deckArea, oldPoint) {
            return deckLocation
        } else if CGRectContainsPoint(wasteArea, oldPoint) {
            return wastePileLocation
        } else {
            for var i = 0; i < foundationsArea.count; i++ {
                if CGRectContainsPoint(foundationsArea[i], oldPoint) {
                    return foundationLocations[i]
                }
            }
            
            for var j = 0; j < tableusArea.count; j++ {
                if CGRectContainsPoint(tableusArea[j], oldPoint) {
                    return tableuLocations[j]
                }
            }
            
            return oldPoint;
        }
    }
    
    // Takes in a CGPoint and returns the StackPile at that location
    // Uses snapToCGPoint to ensure the CGPoints are correct
    // Returns nil if no stackpile at point
    func CGPointToPile(point: CGPoint) -> StackPile? {
        let stackLocation = snapToCGPoint(point)
        
        if stackLocation == wastePileLocation {
            return SolitaireGame.wastePile
        } else if stackLocation == deckLocation {
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
    
    // Check if the specified point is in a foundation pile.
    func foundationsContainPoint(point: CGPoint) -> Bool {
        for(var index = 0; index < foundationLocations.count; index++) {
            if(point == foundationLocations[index]) {
                return true;
            }
        }
        
        return false;
    }
    
    // flips over all the top cards of the tableus to be face up
    // called after a move has completed
    func flipTopCards() {
        for var i = 0; i < tableuLocations.count; i++ {
            let topCard = self.SolitaireGame.tableus[i].topCard()
            
            if (topCard != nil) {
                let topCardSprite = nodeAtPoint(tableuLocations[i]) as? CardSprite
                
                if(topCardSprite != nil) {
                    if !topCardSprite!.faceUp {
                        topCardSprite!.flipCardOver()
                    }
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
        let cardNodes = nodesAtPoint(wastePileLocation) as! [CardSprite]
        
        reloadSprite?.removeFromParent()
        
        for node in cardNodes {
            node.removeFromParent()
        }
        
        for _ in 0..<self.SolitaireGame.wastePile.numberOfCards() {
            self.SolitaireGame.deck.addToStackFromLastCardOf(self.SolitaireGame.wastePile)
        }
        
        for index in 0..<self.SolitaireGame.deck.numberOfCards() {
            let deckSprite = CardSprite(gameScene: self, card: self.SolitaireGame.deck.cardAt(index)!)
            
            deckSprite.size = cardSize
            deckSprite.position = deckLocation
            
            self.addChild(deckSprite)
        }
    }
    
    func endGame() {
        // Make the cards fly off the screen.
        let moveDownAction = SKAction.moveByX(-cardSize.width, y: UIScreen.mainScreen().bounds.height, duration: 0.5);
        let bounceUpAction = SKAction.moveByX(-cardSize.width / 2, y: -(UIScreen.mainScreen().bounds.height * 0.3), duration: 0.25);
        let bounceDownAction = SKAction.moveByX(-cardSize.width / 0.3, y: UIScreen.mainScreen().bounds.height, duration: 0.25 / 0.3);
        
        var waitTime = 0.0;
        for cardSprite in cardSprites {
            let waitAction = SKAction.waitForDuration(waitTime);
            waitTime += 0.4;
            
            let actions = SKAction.sequence([waitAction, moveDownAction, bounceUpAction, bounceDownAction]);
            cardSprite.runAction(actions);
        }
        
        self.endMessageBackground = SKSpriteNode(texture: endMessageBackgroundTexture);
        self.endMessageBackground!.size = CGSize(width: self.frame.width / 2, height: self.frame.height / 2);
        self.endMessageBackground!.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        self.endMessageBackground!.zPosition = 99999;
        
        self.endMessage.fontColor = UIColor.redColor();
        self.endMessage.fontName = "ChalkboardSE-Light";
        self.endMessage.position = CGPoint(x: 0, y: (self.endMessageBackground!.frame.height / 2) - 100);
        self.endMessage.zPosition = 100000;
        
        self.endButton.fontColor = UIColor.redColor();
        self.endButton.fontName = "ChalkboardSE-Light";
        self.endButton.position = CGPoint(x: 0, y: -(self.endMessageBackground!.frame.height / 2) + 100);
        self.endButton.zPosition = 100000;
        
        self.endMessageBackground!.addChild(self.endMessage);
        self.endMessageBackground!.addChild(self.endButton);
        self.addChild(endMessageBackground!);
        
        gameOver = true;
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(gameOver) {
            if(self.endButton.containsPoint(touches.first!.locationInNode(self.endMessageBackground!))) {
                gameScene!.removeEverything();
                self.view!.presentScene(nil);
                gameScene = nil;
                
                gameScene = SolitaireScene(gameScene: self.GameScene, game: Solitaire(), gameDelegate: SolitaireDelegate(), size: CGSizeMake(768, 1024));
                
                spriteView.presentScene(gameScene);
            }
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
