//
//  SolitaireScene.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
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
    let TOP_ROW_Y_FACTOR : CGFloat = 3/4;
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
    
    var solitaireScene: SolitaireScene
    var solitaireGame: Solitaire
    
    var toLocation: CGPoint?        // Where the user lifted their finger
    var fromLocation: CGPoint?      // Where the user began dragging
    
    var newPile: StackPile?         // Pile to which the user dragged
    var oldPile: StackPile?         // Original pile from which the user dragged
    
    var touchedHidden = false;      // Did the user touch a card that was face down?
    var flipHidden = false;         // Should the hidden card be flipped?
    var ignoreTouch = false;        // Should the last touch be ignored?  Used when user touches a card in the foundation pile.
    
    var oldYPositions : [CGFloat] = [];      //Array of Y values when cards started moving
    
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
        if(!faceUp) {
            self.texture = self.frontTexture
            self.faceUp = true
            self.userInteractionEnabled = true
        }
    }
    
    // draws card from deck pile and places in waste pile
    // called when deck pile is tapped
    func drawCard() {
        toLocation = solitaireScene.snapToCGPoint(solitaireScene.wastePileLocation)
        newPile = solitaireGame.wastePile
        oldPile = solitaireGame.deck
        
        self.flipCardOver()
        self.zPosition = CGFloat(solitaireScene.SolitaireGame.wastePile.numberOfCards())
        
        solitaireScene.SolitaireGame.moveTopCard(oldPile!, toPile: newPile!)
        self.runAction(SKAction.moveTo(toLocation!, duration: 0.25))
        
        // If the deck is empty, reload the deck with cards from waste pile
        if solitaireGame.deck.numberOfCards() == 0 {
            solitaireScene.addReloadOption()
        }
    }
    
    func movePile() {
        let tempStack : StackPile = StackPile();
        var yPositionDeltas : [CGFloat] = [];
        let baseYPosition : CGFloat;
        
        if(newPile!.topCard() != nil) {
            baseYPosition = nodeFromCard(newPile!.topCard()!).position.y - CGFloat(cardConstants.CARD_CASCADE_OFFSET);
        } else if(toLocation!.y == solitaireScene.bottomRowYPos) {
            baseYPosition = solitaireScene.bottomRowYPos;
        } else {
            baseYPosition = solitaireScene.topRowYPos;
        }
        
        while(!oldPile!.isEmpty() && !oldPile!.topCard()!.isEqualTo(self.card)) {
            let tempCard = oldPile!.pull()!;
            let cardNode = nodeFromCard(tempCard);
            
            yPositionDeltas.append(self.position.y - cardNode.position.y);
            print(yPositionDeltas[yPositionDeltas.count - 1]);
            
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
            
            if(baseYPosition == solitaireScene.bottomRowYPos) {
                cardPosition = CGPoint(x: toLocation!.x, y: (CGFloat(baseYPosition) - yPositionDeltas[--count]));
            } else {
                cardPosition = CGPoint(x: toLocation!.x, y: baseYPosition);
            }
            
            cardNode.zPosition = CGFloat(newPile!.numberOfCards());
            cardNode.runAction(SKAction.moveTo(cardPosition, duration: cardConstants.POSITION_CORRECTLY_TIME));
            
            newPile!.push(tempCard);
        }
        
        solitaireScene.flipTopCards();
    }
    
    func nodeFromCard(card: Card) -> CardSprite {
        let cardName = "\(card.getRank())\(card.getSuit())";
        
        return self.solitaireScene.childNodeWithName(cardName) as! CardSprite;
    }
    
    /**
    * Returns all face up cards in the stack starting with the top card facing toward the user.
    */
    func getAboveCards(pile: StackPile) -> [Card] {
        var cards:[Card] = [self.card]
        
        // If this is the waste pile, just return the top card.
        if(!self.solitaireGame.wastePile.isEmpty() && pile.topCard()!.isEqualTo(self.solitaireGame.wastePile.topCard()!, ignoreSuit: false)) {
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
    
    // MARK:
    /* TOUCH CONTROLS */
    
    /**
    * Increase this card's z-index so it is above all other cards and save the fromLocation.
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        fromLocation = solitaireScene.snapToCGPoint(self.position);
        let touchedPile = solitaireScene.CGPointToPile(fromLocation!);
        
        if(touchedPile != nil) {
            if(!faceUp) {
                touchedHidden = true;
                
                if(!faceUp && touchedPile!.topCard()!.isEqualTo(self.card)) {
                    // Only flip the card over if it is the first card on the stack and it isn't already flipped.
                    flipHidden = true;
                }
            } else {
                if(fromLocation!.y == solitaireScene.bottomRowYPos || fromLocation!.x == solitaireScene.wastePileLocation.x) {
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
            
            let touchedPile = solitaireScene.CGPointToPile(fromLocation!)
            if touchedPile != nil {
                let aboveCards = getAboveCards(touchedPile!)
                
                for index in 0..<aboveCards.count {
                    let tempCard = nodeFromCard(aboveCards[index]);
                    let tempCardYOffset = CGFloat(-(cardConstants.CARD_CASCADE_OFFSET * index));
                    print(tempCardYOffset);
                    
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
        let touchedPile = solitaireScene.CGPointToPile(fromLocation!);
        
        // test for where the card was touched
        toLocation = solitaireScene.snapToCGPoint(position)
        
        // find where the card is going to and where it is coming from
        newPile = solitaireScene.CGPointToPile(toLocation!)
        oldPile = solitaireScene.CGPointToPile(fromLocation!)
        
        print(newPile?.name);
        print(oldPile?.name);
        
        if(touchedHidden) {
            if(flipHidden) {
                if(newPile!.name == solitaireGame.deck.name && oldPile!.name == solitaireGame.deck.name) {
                    drawCard();
                } else {
                    flipCardOver();
                }
                
                touchedHidden = false;
                flipHidden = false;
            }
        } else if(!ignoreTouch) {
            // DEBUG //
            solitaireScene.SolitaireGame.printPileNumbers()
            print(self.card.getSuit(),self.card.getRank())
            
            // Function variables
            let animationDuration = 0.5;
            
            // Closure for handling moving a card back to oldPile
            let moveCardsBack = {
                () -> Void in
                
                let cardBelow = self.oldPile?.topCard();
                let cardBelowNode = self.nodeFromCard(cardBelow!);
                let cardsAbove = self.getAboveCards(touchedPile!);
                
                for(var index = 0; index < cardsAbove.count; index++) {
                    let tempCardName = "\(cardsAbove[index].getRank())\(cardsAbove[index].getSuit())";
                    let tempCard = self.solitaireScene.childNodeWithName(tempCardName);
                    
                    let tempCardZPosition = cardBelowNode.zPosition + CGFloat(index) + 1;
                    
                    let tempCardLocation = CGPoint(x: self.fromLocation!.x, y: self.oldYPositions[index]);
                    
                    // DEBUG //
                    print(tempCardZPosition);
                    print(tempCardLocation);
                    
                    tempCard!.zPosition = tempCardZPosition;
                    
                    tempCard!.runAction(SKAction.moveTo(tempCardLocation, duration: animationDuration));
                    
                    // DEBUG //
                    print(tempCard?.position);
                }
            }
            
            if newPile == nil {
                // If the new pile is not a valid position, move back to correct location
                moveCardsBack();
            } else if newPile != nil && oldPile != nil {
                // If both piles are valid determine where the card is going to and coming from
                
                // DEBUG //
                print(oldPile!.numberOfCards(), newPile!.numberOfCards())
                
                // checks if a valid move
                if solitaireGame.checkMove(card, previousPile: oldPile!, newPile: newPile!) {
                    // DEBUG //
                    print(self.card.getRank(),self.card.getSuit())
                    
                    if(toLocation! != fromLocation!) {
                        movePile();
                    }
                    
                    // DEBUG //
                    solitaireGame.printPileNumbers()
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
    
    // Position variables
    var deckXPos : CGFloat = 0;
    var topRowYPos : CGFloat = 0;
    var bottomRowYPos : CGFloat = 0;
    var wasteXPos : CGFloat = 0;
    
    init(gameScene : GameSceneViewController, size: CGSize) {
        self.GameScene = gameScene
        self.SolitaireGame = self.GameScene.solitaireGame!
        self.SolitaireGameDelegate = self.GameScene.solitaireGameDelegate!
        
        super.init(size: size)
        
        // initializes the various CGPoints and CGSizes used by gamescene
        self.cardSize = CGSize(width: self.scene!.size.width/8, height: self.scene!.size.height/4)
        
        // Set pile locations.
        deckXPos = self.scene!.frame.minX + (cardConstants.DECK_X_FACTOR * cardSize.width);
        wasteXPos = deckXPos + cardSize.width + 15;
        topRowYPos = self.scene!.frame.maxY - (cardConstants.TOP_ROW_Y_FACTOR * cardSize.height);
        bottomRowYPos = self.scene!.frame.maxY - (2 * cardSize.height);
        
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
        
        self.deal()
        
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
                let newTableuCardSprite = CardSprite(gameScene: self.GameScene, card: self.SolitaireGame.tableus[i].cardAt(j)!)
                
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
            let newDeckCardSprite = CardSprite(gameScene: self.GameScene, card: self.SolitaireGame.deck.cardAt(count++)!);
            
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
        
        // DEBUG //
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
