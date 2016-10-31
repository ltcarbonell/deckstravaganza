//
//  RummyScene.swift
//  Deckstravaganza
//
//  Created by Luis Carbonell on 10/26/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

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
    init(card: Card, touchesBeganClosure: @escaping (RummyCardSprite)->Void, touchesMovedClosure: @escaping (RummyCardSprite)->Void, touchesEndedClosure: @escaping (RummyCardSprite)->Void) {
        self.card = card
        
        self.frontTexture = SKTexture(image: card.getCardFace(Deck.DeckFronts.Default)!)
        self.backTexture = SKTexture(image: card.getCardBack(Deck.DeckBacks.PatternBlue)!)
        
        self.touchesBeganClosure = touchesBeganClosure
        self.touchesMovedClosure = touchesMovedClosure
        self.touchesEndedClosure = touchesEndedClosure
        
        self.faceUp = false
        
        super.init(texture: backTexture, color: UIColor.black, size: backTexture.size())
        self.isUserInteractionEnabled = true
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            touchesEndedClosure(self)
        }
    }
}

class RummyScene: SKScene {
    let GameScene: GameSceneViewController
    let RummyGame: Rummy
    
    let SCALE_FACTOR: CGFloat = 0.7
    
    var cardSize = CGSize(width: 0, height: 0)
    
    var deckLocation = CGPoint(x: 0,y: 0)
    var wastePileLocation = CGPoint(x: 0, y: 0)
    var handLocations = [CGPoint(x: 0,y: 0)]
    var countLocations = [CGPoint(x: 0, y: 0)]
    var meldLocation = CGPoint(x: 0,y: 0)
    
    //var isWinner = false
    //var isPlayerTurn = false
    var isDealButtonOnScreen = false
    
    var cardCountNodeArray: [SKLabelNode] = []
    var scoreboardNodes: [SKNode] = []
    
    var buttonsOnScreen = [GameViewControllerButton]()
    
    var touchedUpSoundEffect = AVAudioPlayer()
    let touchedUpSoundEffectPath = Bundle.main.path(forResource: "cardPlace1", ofType: "wav")
    
    var touchedDownSoundEffect = AVAudioPlayer()
    let touchedDownSoundEffectPath = Bundle.main.path(forResource: "cardSlide1", ofType: "wav")
    
    var shuffleSoundEffect = AVAudioPlayer()
    let shuffleSoundEffectPath = Bundle.main.path(forResource: "cardShuffle1", ofType: "wav")
    
    var moveSoundEffect = AVAudioPlayer()
    let moveSoundEffectPath = Bundle.main.path(forResource: "cardShove1", ofType: "wav")
    
    init(gameScene : GameSceneViewController, game: Rummy, size: CGSize) {
        
        self.GameScene = gameScene
        self.RummyGame = game
        
        super.init(size: size)
        
        // initializes the various CGPoints and CGSizes used by gamescene
        self.cardSize = CGSize(width: self.scene!.size.width/9, height: self.scene!.size.height/4.5)
        
        // Sets the location for where the deck and waste pile are located in the frame
        self.deckLocation = CGPoint(x: self.scene!.frame.minX + 1.5*cardSize.width, y: self.scene!.frame.midY)
        self.wastePileLocation = CGPoint(x: self.scene!.frame.minX + 1.5*cardSize.width + 1.2*cardSize.width , y: self.scene!.frame.midY)
        
        // Sets the location for where the melds should be location
        self.meldLocation = CGPoint(x: self.scene!.frame.midX - 0.85*cardSize.width, y: self.scene!.frame.maxY - 1.75*cardSize.height)
        
        // Sets the locations of where the players' hands begin
        switch RummyGame.playersHands.count {
        case 2:
            self.handLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height/3)]
            self.countLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height)]
        case 3:
            self.handLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3),CGPoint(x: self.frame.maxX-cardSize.width/3, y: self.frame.midY), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height/3)]
            self.countLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3),CGPoint(x: self.frame.maxX-cardSize.width, y: self.frame.midY), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height)]
        case 4:
            self.handLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3),CGPoint(x: self.frame.maxX-cardSize.width/3, y: self.frame.midY), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height/3),CGPoint(x: self.frame.minX+cardSize.width/3, y: self.frame.midY)]
            self.countLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3),CGPoint(x: self.frame.maxX-cardSize.width, y: self.frame.midY), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height),CGPoint(x: self.frame.minX+cardSize.width, y: self.frame.midY)]
        case 5:
            self.handLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3),CGPoint(x: self.frame.maxX-cardSize.width/3, y: self.frame.midY-cardSize.height), CGPoint(x: self.frame.maxX-cardSize.width/3, y: self.frame.midY+cardSize.height), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height/3),CGPoint(x: self.frame.minX+cardSize.width/3, y: self.frame.midY+cardSize.height)]
            self.countLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3),CGPoint(x: self.frame.maxX-cardSize.width, y: self.frame.midY-cardSize.height), CGPoint(x: self.frame.maxX-cardSize.width, y: self.frame.midY+cardSize.height), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height),CGPoint(x: self.frame.minX+cardSize.width, y: self.frame.midY+cardSize.height)]
        case 6:
            self.handLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3),CGPoint(x: self.frame.maxX-cardSize.width/3, y: self.frame.midY-cardSize.height), CGPoint(x: self.frame.maxX-cardSize.width/3, y: self.frame.midY+cardSize.height), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height/3),CGPoint(x: self.frame.minX+cardSize.width/3, y: self.frame.midY+cardSize.height),CGPoint(x: self.frame.minX+cardSize.width/3, y: self.frame.midY-cardSize.height)]
            self.countLocations = [CGPoint(x: self.frame.midX,y: self.frame.minY+cardSize.height/3),CGPoint(x: self.frame.maxX-cardSize.width, y: self.frame.midY-cardSize.height), CGPoint(x: self.frame.maxX-cardSize.width, y: self.frame.midY+cardSize.height), CGPoint(x: self.frame.midX, y: self.frame.maxY-cardSize.height),CGPoint(x: self.frame.minX+cardSize.width, y: self.frame.midY+cardSize.height),CGPoint(x: self.frame.minX+cardSize.width, y: self.frame.midY-cardSize.height)]
        default:
            break
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        createBackground()
        if self.RummyGame.deck.numberOfCards() == 52 && !isDealButtonOnScreen {
            print(self.RummyGame.round,self.RummyGame.roundScores)
            addDealButton()
        } else {
            print(self.RummyGame.round,self.RummyGame.roundScores)
        }
    }
    
    
    // MARK: Function that add buttons to the scene
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "poker-table-felt")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.size.height = self.frame.height
        background.size.width = self.frame.width
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -10
        self.addChild(background)
    }
    
    func startGame() {
        createBackground()
        self.removeChildren(in: scoreboardNodes)
        self.RummyGame.resetGame()
        
        self.shuffle()
        self.deal()
        
        for player in self.RummyGame.players {
            setUserInteractionEnabledPlayerHand(false, player: player)
        }
        
    }
    
    func startRound() {
        createBackground()
        self.removeChildren(in: scoreboardNodes)
        
        self.shuffle()
        self.deal()
        
        for player in RummyGame.players {
            setUserInteractionEnabledPlayerHand(false, player: player)
        }
    }
    
    func addDealButton() {
        let dealButton = GameViewControllerButton(defaultButtonImage: "start_game_image", buttonAction: startGame)
        dealButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        dealButton.size = CGSize(width: 300, height: 200)
        self.addChild(dealButton)
        isDealButtonOnScreen = true
    }
    
    func addMeldButton() {
        let meldButton = GameViewControllerButton(defaultButtonImage: "MeldButtonImg", buttonAction: meld)
        meldButton.size = CGSize(width: 1.5*cardSize.width, height: 1.5*cardSize.height/3)
        meldButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - cardSize.height)
        meldButton.zPosition = 100
        self.addChild(meldButton)
        buttonsOnScreen.append(meldButton)
        
    }
    
    func addDiscardButton() {
        let discardButton = GameViewControllerButton(defaultButtonImage: "DiscardButtonImg", buttonAction: discard)
        discardButton.size = CGSize(width: 1.5*cardSize.width, height: 1.5*cardSize.height/3)
        discardButton.position = CGPoint(x: self.frame.midX + 1.1*discardButton.size.width, y: self.frame.midY - cardSize.height)
        discardButton.zPosition = 100
        self.addChild(discardButton)
        buttonsOnScreen.append(discardButton)
    }
    
    func addLayOffButton() {
        let layOffButton = GameViewControllerButton(defaultButtonImage: "LayOffButtonImg", buttonAction: layOff)
        layOffButton.size = CGSize(width: 1.5*cardSize.width, height: 1.5*cardSize.height/3)
        layOffButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - cardSize.height)
        layOffButton.zPosition = 100
        self.addChild(layOffButton)
        buttonsOnScreen.append(layOffButton)
    }
    
    func addReloadButton() {
        let reloadButton = GameViewControllerButton(defaultButtonImage: "CardPlaceholder", buttonAction: reload)
        reloadButton.size = cardSize
        reloadButton.position = deckLocation
        self.addChild(reloadButton)
    }
    
    func addScoreBoard(_ isWinner: Bool) {
        var winningScore: Int = 0
        if isWinner {
            for player in self.RummyGame.players {
                if player.score >= self.RummyGame.targetScore {
                    winningScore = player.score
                }
            }
        }
        
        let scoreboardBackground = SKSpriteNode(imageNamed: "MessageBackgroundTexture")
        scoreboardBackground.size = CGSize(width: self.frame.width/1.4, height: self.frame.height/1.4)
        scoreboardBackground.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        scoreboardBackground.zPosition = 999
        self.scoreboardNodes.append(scoreboardBackground)
        self.addChild(scoreboardBackground)
        
        
        let scoreboardTable = CGRect(x: scoreboardBackground.position.x - scoreboardBackground.size.width/2, y: scoreboardBackground.position.y - scoreboardBackground.size.height/2, width: scoreboardBackground.size.width, height: scoreboardBackground.size.height)
        
        
        let numberOfPlayers = self.RummyGame.players.count
        var columns = [CGFloat]()
        for index in 0...numberOfPlayers {
            columns.append(scoreboardTable.minX + (1 + CGFloat(index))*scoreboardTable.width/(CGFloat(numberOfPlayers)+2))
        }
        var rows = [CGFloat]()
        for index in 0...self.RummyGame.roundScores.count+2 {
            rows.append(scoreboardTable.maxY - (0.5 + CGFloat(index))*scoreboardTable.height/CGFloat(self.RummyGame.roundScores.count+2))
        }
        
        let roundTitleNode = SKLabelNode(text: "Round")
        roundTitleNode.fontName = "PT Sans"
        roundTitleNode.fontColor = UIColor.white
        roundTitleNode.position.x = columns[0]
        roundTitleNode.position.y = rows[0]
        roundTitleNode.zPosition = 1000
        self.scoreboardNodes.append(roundTitleNode)
        self.addChild(roundTitleNode)
        
        let totalScoreTitleNode = SKLabelNode(text: "Total")
        totalScoreTitleNode.fontName = "PT Sans"
        totalScoreTitleNode.fontColor = UIColor.white
        totalScoreTitleNode.position.x = columns[0]
        totalScoreTitleNode.position.y = rows[self.RummyGame.roundScores.count + 1]
        totalScoreTitleNode.zPosition = 1000
        self.scoreboardNodes.append(totalScoreTitleNode)
        self.addChild(totalScoreTitleNode)
        
        for player in self.RummyGame.players {
            let playerNameNode = SKLabelNode(text: player.userName)
            playerNameNode.fontName = "PT Sans"
            playerNameNode.position.x = columns[player.playerNumber+1]
            playerNameNode.position.y = rows[0]
            playerNameNode.zPosition = 1000
            self.scoreboardNodes.append(playerNameNode)
            self.addChild(playerNameNode)
            
            let totalScoreNode = SKLabelNode(text: String(player.score))
            totalScoreNode.fontName = "PT Sans"
            totalScoreNode.position.x = columns[player.playerNumber+1]
            totalScoreNode.position.y = rows[self.RummyGame.roundScores.count + 1]
            totalScoreNode.zPosition = 1000
            self.scoreboardNodes.append(totalScoreNode)
            self.addChild(totalScoreNode)
            
            if isWinner && player.score == winningScore {
                playerNameNode.fontColor = UIColor.green
                totalScoreNode.fontColor = UIColor.green
            }
        }
        
        for roundIndex in 0..<self.RummyGame.roundScores.count {
            let roundIndexNode = SKLabelNode(text: String(roundIndex+1))
            roundIndexNode.fontName = "PT Sans"
            roundIndexNode.position.x = columns[0]
            roundIndexNode.position.y = rows[roundIndex+1]
            roundIndexNode.zPosition = 1000
            self.scoreboardNodes.append(roundIndexNode)
            self.addChild(roundIndexNode)
            
            for player in self.RummyGame.players {
                print(self.RummyGame.roundScores)
                let roundScore = SKLabelNode(text: String(self.RummyGame.roundScores[roundIndex][player.playerNumber]))
                roundScore.fontName = "PT Sans"
                roundScore.position.x = columns[player.playerNumber+1]
                roundScore.position.y = rows[roundIndex+1]
                roundScore.zPosition = 1000
                self.scoreboardNodes.append(roundScore)
                self.addChild(roundScore)
                
                if isWinner && player.score == winningScore {
                    roundScore.fontColor = UIColor.green
                }
            }
        }
        
        if isWinner {
            let startGameNode = GameViewControllerButton(defaultButtonImage: "play_again_game_image", buttonAction: startGame)
            startGameNode.size = CGSize(width: scoreboardTable.width/3, height: scoreboardTable.width/5)
            startGameNode.position.x = scoreboardTable.midX
            startGameNode.position.y = scoreboardTable.minX - 0.25*startGameNode.size.height
            startGameNode.zPosition = 1000
            self.addChild(startGameNode)
        } else {
            let startRoundNode = GameViewControllerButton(defaultButtonImage: "start_round_image", buttonAction: startRound)
            startRoundNode.size = CGSize(width: scoreboardTable.width/3, height: scoreboardTable.width/5)
            startRoundNode.position.x = scoreboardTable.midX
            startRoundNode.position.y = scoreboardTable.minX - 0.25*startRoundNode.size.height
            startRoundNode.zPosition = 1000
            self.addChild(startRoundNode)
        }
        
    }
    
    func checkAndAddValidButtonOptions() {
        // Remove all buttons currently on the screen
        self.removeChildren(in: buttonsOnScreen)
        self.buttonsOnScreen = []
        
        // if one card is selected discard move add discard button and layoff button
        if self.RummyGame.selectedCards.numberOfCards() == 1 {
            if  self.RummyGame.melds.count > 0 {
                addLayOffButton()
            }
            addDiscardButton()
        }
            // if more than one card is selected add layoff button and meldbutton
        else if self.RummyGame.selectedCards.numberOfCards() > 1{
            addMeldButton()
        }
    }
    
    // MARK: Functions used for implementing the game rules and moves
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
        // Create the sprites for the cards that go into the players's hands
        reorganizePlayersHand()
                
        // Create the sprites for the cards that go into the waste pile
        let wastePileSprite = self.childNode(withName: "\(self.RummyGame.wastePile.topCard()!.getRank())\(self.RummyGame.wastePile.topCard()!.getSuit())") as! RummyCardSprite
        wastePileSprite.flipCardOver()
        wastePileSprite.run(SKAction.move(to: wastePileLocation, duration: 0.1))
        printCardsForDebug()
    }
    
    func cardWasDrawn(_ cardSprite: RummyCardSprite) {
        self.RummyGame.didDrawCard = true
        
        // Move card into the hand of the player
        cardSprite.run(SKAction.move(to: CGPoint(x:self.handLocations[self.RummyGame.currentPlayerNumber].x + CGFloat(self.RummyGame.playersHands[self.RummyGame.currentPlayerNumber].numberOfCards())*cardSize.width/3 , y: handLocations[self.RummyGame.currentPlayerNumber].y), duration: 0.5))
        
        cardSprite.zPosition = CGFloat(self.RummyGame.playersHands[self.RummyGame.currentPlayerNumber].numberOfCards())
        if cardSprite.faceUp {
            self.RummyGame.drawFromWastePile(cardSprite.card)
        } else {
            cardSprite.flipCardOver()
            self.RummyGame.drawFromDeck(cardSprite.card)
        }
        if self.RummyGame.players[self.RummyGame.currentPlayerNumber].isComputer {
            if cardSprite.faceUp {
                cardSprite.flipCardOver()
            }
        }
        
        if self.RummyGame.deck.numberOfCards() == 0 {
            addReloadButton()
        }
        
        setUserInteractionEnabledDeck(false)
        setUserInteractionEnabledWastePile(false)
        setUserInteractionEnabledPlayerHand(true, player: self.RummyGame.players.first!)
    }
    
    func aiCardWasDrawn(_ cardSprite: RummyCardSprite) {
        self.RummyGame.didDrawCard = true
        if cardSprite.card.isEqualTo(self.RummyGame.wastePile.topCard()!, ignoreSuit: false) {
            self.RummyGame.drawFromWastePile(cardSprite.card)
        } else {
            self.RummyGame.drawFromDeck(cardSprite.card)
        }
        
        if self.RummyGame.deck.numberOfCards() == 0 {
            addReloadButton()
        }
        
        setUserInteractionEnabledDeck(false)
        setUserInteractionEnabledWastePile(false)
        setUserInteractionEnabledPlayerHand(true, player: self.RummyGame.players.first!)
    }
    
    func moveAIDrawnCard(_ cardSprite: RummyCardSprite) {
        // Move card into the hand of the player
        cardSprite.run(SKAction.sequence([SKAction.move(to: CGPoint(x:self.handLocations[self.RummyGame.currentPlayerNumber].x - cardSize.width/3 , y: handLocations[self.RummyGame.currentPlayerNumber].y), duration: 0.5)]))
    }
    
    func discard() {
        print("discard")
        let cardSpriteDiscarded = self.childNode(withName: "\(self.RummyGame.selectedCards.cardAt(0)!.getRank())\(self.RummyGame.selectedCards.cardAt(0)!.getSuit())") as! RummyCardSprite
        if !cardSpriteDiscarded.faceUp {
            cardSpriteDiscarded.flipCardOver()
        }
        
        self.RummyGame.discard(self.RummyGame.selectedCards.removeCard(cardSpriteDiscarded.card)!)
        checkAndAddValidButtonOptions()
        
        // Reorganized the waste pile's zPosition so they are in correct order
        for cardIndex in 0..<self.RummyGame.wastePile.numberOfCards() {
            let currentCard = self.childNode(withName: "\(self.RummyGame.wastePile.cardAt(cardIndex)!.getRank())\(self.RummyGame.wastePile.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            currentCard.zPosition = CGFloat(cardIndex)
        }
        
        for player in self.RummyGame.players {
            setUserInteractionEnabledPlayerHand(false, player: player)
        }
        setUserInteractionEnabledDeck(true)
        setUserInteractionEnabledWastePile(true)
        cardSpriteDiscarded.run(SKAction.move(to: wastePileLocation, duration: 0.5))
        playMovedCardSoundEffect()
        moveDidEndTurn()
    }
    
    func aiDiscard() {
        print("AI discard")
        let cardSpriteDiscarded = self.childNode(withName: "\(self.RummyGame.selectedCards.cardAt(0)!.getRank())\(self.RummyGame.selectedCards.cardAt(0)!.getSuit())") as! RummyCardSprite
        
        self.RummyGame.discard(self.RummyGame.selectedCards.removeCard(cardSpriteDiscarded.card)!)
        checkAndAddValidButtonOptions()
        
        // Reorganized the waste pile's zPosition so they are in correct order
        for cardIndex in 0..<self.RummyGame.wastePile.numberOfCards() {
            let currentCard = self.childNode(withName: "\(self.RummyGame.wastePile.cardAt(cardIndex)!.getRank())\(self.RummyGame.wastePile.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            currentCard.zPosition = CGFloat(cardIndex)
        }
        
        for player in self.RummyGame.players {
            setUserInteractionEnabledPlayerHand(false, player: player)
        }
        setUserInteractionEnabledDeck(true)
        setUserInteractionEnabledWastePile(true)
    }
    
    func meld() {
        print("meld")
        var cardSpritesMeld = [RummyCardSprite]()
        for cardIndex in 0..<self.RummyGame.selectedCards.numberOfCards() {
            cardSpritesMeld.append(self.childNode(withName: "\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getRank())\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite)
        }
        if self.RummyGame.isSelectedCardsValidMeld() {
            // Move the cards to a meld pile
            self.RummyGame.meldSelectedCards()
            let cardCount = cardSpritesMeld.count
            for cardIndex in 0..<cardCount {
                let gridX = (self.RummyGame.melds.count - 1)%3
                let gridY = (self.RummyGame.melds.count - 1)/3
                let newX = meldLocation.x + (CGFloat(gridX) * 1.75*self.cardSize.width + CGFloat(cardIndex)/CGFloat(cardCount)*SCALE_FACTOR*cardSize.width)
                let newY = meldLocation.y - 6*(CGFloat(gridY)*self.cardSize.height)/5
                let newMeldLocation = CGPoint(x: newX, y: newY)
                cardSpritesMeld[cardIndex].zPosition = CGFloat(cardIndex)
                cardSpritesMeld[cardIndex].run(SKAction.group([SKAction.move(to: newMeldLocation, duration: 0.5),SKAction.scale(by: SCALE_FACTOR, duration: 0.5)]))
                if !cardSpritesMeld[cardIndex].faceUp {
                    cardSpritesMeld[cardIndex].flipCardOver()
                }
                playMovedCardSoundEffect()
                checkAndAddValidButtonOptions()
            }
        } else {
            didPlayInvalidMove()
        }
        reorganizePlayersHand()
        reorganizeMeldedCards()
        setUserInteractionEnabledMelds(false)
        if self.RummyGame.playersHands[self.RummyGame.currentPlayerNumber].numberOfCards() == 0 {
            moveDidEndTurn()
        }
    }
    
    func aiMeld() {
        print("AI meld")
        var cardSpritesMeld = [RummyCardSprite]()
        for cardIndex in 0..<self.RummyGame.selectedCards.numberOfCards() {
            cardSpritesMeld.append(self.childNode(withName: "\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getRank())\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite)
        }
        self.RummyGame.meldSelectedCards()
            
        setUserInteractionEnabledMelds(false)
        for cardSprite in cardSpritesMeld {
            cardSprite.run(SKAction.scale(by: SCALE_FACTOR, duration: 0.5))
        }
    }
    
    func layOff() {
        print("layoff")
        var cardSpritesLayOff = [RummyCardSprite]()
        for cardIndex in 0..<self.RummyGame.selectedCards.numberOfCards() {
            cardSpritesLayOff.append(self.childNode(withName: "\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getRank())\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite)
        }
        let meldIndicies = self.RummyGame.checkForMeldOptions()
        if self.RummyGame.isSelectedCardsValidLayOff() {
            // Move the cards to a meld pile
            let meldIndex = meldIndicies.first!
            self.RummyGame.layOffSelectedCards(meldIndex, insertIndex: 0)
            self.RummyGame.melds[meldIndex].meld.sortByRank(true)
            // Move them to the correct location of that specific meld
            for sprite in cardSpritesLayOff {
                let gridX = (meldIndex)%3
                let gridY = (meldIndex)/3
                let newMeldLocation = CGPoint(x: meldLocation.x + (CGFloat(gridX) * 1.75*self.cardSize.width) , y: meldLocation.y - (CGFloat(gridY) * 2*self.cardSize.height))
                sprite.run(SKAction.group([SKAction.move(to: newMeldLocation, duration: 0.5), SKAction.scale(by: SCALE_FACTOR, duration: 0.5)]))
                if !sprite.faceUp {
                    sprite.flipCardOver()
                }
                playMovedCardSoundEffect()
                checkAndAddValidButtonOptions()
            }
            
        } else {
            didPlayInvalidMove()
        }
        reorganizePlayersHand()
        reorganizeMeldedCards()
        if self.RummyGame.playersHands[self.RummyGame.currentPlayerNumber].numberOfCards() == 0 {
            moveDidEndTurn()
        }
    }
    
    func aiLayOff() {
        print("AI layoff")
        var cardSpritesLayOff = [RummyCardSprite]()
        for cardIndex in 0..<self.RummyGame.selectedCards.numberOfCards() {
            cardSpritesLayOff.append(self.childNode(withName: "\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getRank())\(self.RummyGame.selectedCards.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite)
        }
        for cardSprite in cardSpritesLayOff {
            cardSprite.run(SKAction.scale(by: SCALE_FACTOR, duration: 0.5))
        }
        let meldIndicies = self.RummyGame.checkForMeldOptions()
        // Move the cards to a meld pile
        let meldIndex = meldIndicies.first!
        self.RummyGame.layOffSelectedCards(meldIndex, insertIndex: 0)
        self.RummyGame.melds[meldIndex].meld.sortByRank(true)
    }
    
    func reload() {
        while self.RummyGame.wastePile.numberOfCards() > 1 {
            self.RummyGame.deck.push(self.RummyGame.wastePile.removeCardAt(0)!)
        }
        self.RummyGame.deck.shuffle()
        for cardIndex in 0..<self.RummyGame.deck.numberOfCards() {
            let deckSprite = self.childNode(withName: "\(self.RummyGame.deck.cardAt(cardIndex)!.getRank())\(self.RummyGame.deck.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            deckSprite.flipCardOver()
            deckSprite.run(SKAction.move(to: deckLocation, duration: 0.1))
            deckSprite.zPosition = CGFloat(cardIndex)
        }
    }
    
    func runAllComputerTurns() {
        print("Running computer turns...")
        setUserInteractionEnabledDeck(false)
        setUserInteractionEnabledWastePile(false)
        for player in self.RummyGame.players {
            setUserInteractionEnabledPlayerHand(false, player: player)
        }
        setUserInteractionEnabledMelds(false)
        setUserInteractionEnabledDeck(true)
        setUserInteractionEnabledWastePile(true)
        
        let userNumber = self.RummyGame.players.first!.playerNumber
        while (userNumber != self.RummyGame.currentPlayerNumber  && !self.RummyGame.isRoundOver) {
            print(self.RummyGame.currentPlayerNumber)
            let computerPlayer = self.RummyGame.computerPlayers[self.RummyGame.currentPlayerNumber - 1]
            AITurn(computerPlayer)
        }
        
        
    }
    
    func AITurn(_ computer: RummyAI) {
        print("Taking computer turn", computer.player.playerNumber)
        printCardsForDebug()
        
        var drawnCardSprite: RummyCardSprite
        
        computer.countHands()
        if computer.shouldDrawCardFromWaste() {
            drawnCardSprite = self.childNode(withName: "\(self.RummyGame.wastePile.topCard()!.getRank())\(self.RummyGame.wastePile.topCard()!.getSuit())") as! RummyCardSprite
        } else {
            if self.RummyGame.deck.isEmpty() {
                self.reload()
            }
            drawnCardSprite = self.childNode(withName: "\(self.RummyGame.deck.topCard()!.getRank())\(self.RummyGame.deck.topCard()!.getSuit())") as! RummyCardSprite
            
        }
        self.aiCardWasDrawn(drawnCardSprite)
        
        self.RummyGame.playersHands[computer.player.playerNumber].sortByRank(true)
        computer.countHands()
        while computer.shouldMeldCards() {
            self.aiMeld()
            computer.countHands()
        }
        self.run(SKAction.wait(forDuration: 0.5), completion: reorganizePlayersHand)
        self.run(SKAction.wait(forDuration: 0.5), completion: reorganizeMeldedCards)
        while computer.shouldLayOffCards() {
            self.aiLayOff()
            computer.countHands()
        }
        self.run(SKAction.wait(forDuration: 0.5), completion: reorganizeMeldedCards)
        let discardCard = self.RummyGame.playersHands[computer.player.playerNumber].cardAt(computer.getDiscardCardIndex(drawnCardSprite.card))!
        self.RummyGame.addSelectedCard(discardCard)
        self.aiDiscard()
        if discardCard.isEqualTo(drawnCardSprite.card, ignoreSuit: false) {
            let moveToHand = SKAction.move(to: handLocations[computer.player.playerNumber], duration: 0.5)
            let moveToWaste = SKAction.move(to: wastePileLocation, duration: 0.5)
            drawnCardSprite.run(SKAction.sequence([SKAction.wait(forDuration: 0.5) , moveToHand, moveToWaste]))
            self.run(SKAction.wait(forDuration: 1.5), completion: reorganizeWastePileCards)
        } else {
            self.run(SKAction.wait(forDuration: 1.5), completion: reorganizeWastePileCards)
        }
        
        
        if self.RummyGame.checkRoundEnded() {
            turnDidEndRound()
        } else {
            self.RummyGame.turnDidStart()
        }
        
        print("Finished computer turn", computer.player.playerNumber)
        printCardsForDebug()
        
    }
    
    // MARK: Functions used for recognizing movements and implementing using cardSprites
    func setUserInteractionEnabledDeck(_ value: Bool) {
        for cardIndex in 0..<self.RummyGame.deck.numberOfCards() {
            let deckSprite = self.childNode(withName: "\(self.RummyGame.deck.cardAt(cardIndex)!.getRank())\(self.RummyGame.deck.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            deckSprite.zPosition = CGFloat(cardIndex)
            deckSprite.isUserInteractionEnabled = value
        }
    }
    
    func setUserInteractionEnabledWastePile(_ value: Bool) {
        for cardIndex in 0..<self.RummyGame.wastePile.numberOfCards() {
            let wastePileSprite = self.childNode(withName: "\(self.RummyGame.wastePile.cardAt(cardIndex)!.getRank())\(self.RummyGame.wastePile.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            wastePileSprite.isUserInteractionEnabled = value
        }
    }
    
    func setUserInteractionEnabledPlayerHand(_ value: Bool, player: Player) {
        for cardIndex in 0..<self.RummyGame.playersHands[player.playerNumber].numberOfCards() {
            let handSprite = self.childNode(withName: "\(self.RummyGame.playersHands[player.playerNumber].cardAt(cardIndex)!.getRank())\(self.RummyGame.playersHands[player.playerNumber].cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            handSprite.isUserInteractionEnabled = value
        }
    }
    
    func setUserInteractionEnabledMelds(_ value: Bool) {
        for meldIndex in 0..<self.RummyGame.melds.count {
            for cardIndex in 0..<self.RummyGame.melds[meldIndex].meld.numberOfCards() {
                let meldSprite = self.childNode(withName: "\(self.RummyGame.melds[meldIndex].meld.cardAt(cardIndex)!.getRank())\(self.RummyGame.melds[meldIndex].meld.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
                meldSprite.isUserInteractionEnabled = value
            }
        }
    }
    
    func isCardOnTopOfDeck(_ cardSprite: RummyCardSprite) -> Bool {
        var result = false
        let topCard = self.RummyGame.deck.topCard()
        if topCard != nil {
            if topCard!.isEqualTo(cardSprite.card, ignoreSuit:  false) {
                result = true
            }
        }
        return result
    }
    
    func isCardOnTopOfWastePile(_ cardSprite: RummyCardSprite) -> Bool {
        var result = false
        let topCard = self.RummyGame.wastePile.topCard()
        if topCard != nil {
            if topCard!.isEqualTo(cardSprite.card, ignoreSuit:  false) {
                result = true
            }
        }
        return result
    }
    
    func didPlayInvalidMove() {
        
        let alert = UIAlertView(title: "Invalid move",
            message:  nil,
            delegate: nil,
            cancelButtonTitle: "Try Again")
        alert.show()
        
        reorganizePlayersHand()
        
        self.RummyGame.selectedCards.removeAllCards()
        checkAndAddValidButtonOptions()
    }
    
    func reorganizePlayersHand() {
        self.removeChildren(in: self.cardCountNodeArray)
        for handIndex in 0..<self.RummyGame.playersHands.count {
            if handIndex == 0 {
                self.RummyGame.playersHands[handIndex].sortByRank(true)
                for cardIndex in 0..<self.RummyGame.playersHands[handIndex].numberOfCards() {
                    let handSprite = self.childNode(withName: "\(self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getRank())\(self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
                    if !handSprite.faceUp {
                        handSprite.flipCardOver()
                    }
                    let newXLocation = handLocations[handIndex].x + CGFloat(cardIndex)*cardSize.width/3
                    let newYLocation = handLocations[handIndex].y
                    handSprite.run(SKAction.move(to: CGPoint(x: newXLocation, y: newYLocation) , duration: 0.5))
                    handSprite.zPosition = CGFloat(cardIndex)
                }
            } else {
                self.RummyGame.playersHands[handIndex].sortByRank(true)
                for cardIndex in 0..<self.RummyGame.playersHands[handIndex].numberOfCards() {
                    let handSprite = self.childNode(withName: "\(self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getRank())\(self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
                    let newXLocation = handLocations[handIndex].x
                    let newYLocation = handLocations[handIndex].y
                    handSprite.run(SKAction.move(to: CGPoint(x: newXLocation, y: newYLocation) , duration: 0.5))
                    handSprite.zPosition = CGFloat(cardIndex)
                    if handSprite.faceUp {
                        handSprite.flipCardOver()
                    }
                    let cardCount = SKLabelNode(fontNamed: "PT Sans")
                    cardCount.position = countLocations[handIndex]
                    cardCount.fontSize = 30
                    cardCount.fontColor = UIColor.black
                    cardCount.text = "\(self.RummyGame.playersHands[handIndex].numberOfCards())"
                    cardCount.zPosition = 999
                    
                    self.addChild(cardCount)
                    self.cardCountNodeArray.append(cardCount)
                }
            }
        }
    }
    
    func reorganizeMeldedCards() {
        for meldIndex in 0..<self.RummyGame.melds.count {
            var cardSpritesMeld = [RummyCardSprite]()
            self.RummyGame.melds[meldIndex].meld.sortByRank(true)
            for cardIndex in 0..<self.RummyGame.melds[meldIndex].meld.numberOfCards() {
                cardSpritesMeld.append(self.childNode(withName: "\(self.RummyGame.melds[meldIndex].meld.cardAt(cardIndex)!.getRank())\(self.RummyGame.melds[meldIndex].meld.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite)
            }
            let numberOfCardsInMeld = self.RummyGame.melds[meldIndex].meld.numberOfCards()
            for cardIndex in 0..<numberOfCardsInMeld {
                let gridX = (meldIndex)%3
                let gridY = (meldIndex)/3
                let newX = meldLocation.x + (CGFloat(gridX) * 1.75*self.cardSize.width + CGFloat(cardIndex)/CGFloat(numberOfCardsInMeld)*cardSize.width)
                let newY = meldLocation.y - 6*(CGFloat(gridY)*self.cardSize.height)/5
                let newMeldLocation = CGPoint(x: newX, y: newY)
                if !cardSpritesMeld[cardIndex].faceUp {
                    cardSpritesMeld[cardIndex].flipCardOver()
                }
                cardSpritesMeld[cardIndex].zPosition = CGFloat(cardIndex)
                cardSpritesMeld[cardIndex].run(SKAction.move(to: newMeldLocation, duration: 0.5))
            }
        }
    }
    
    func reorganizeWastePileCards() {
        let numberOfCardsInWaste = self.RummyGame.wastePile.numberOfCards()
        for cardIndex in 0..<numberOfCardsInWaste {
            let wasteSprite = self.childNode(withName: "\(self.RummyGame.wastePile.cardAt(cardIndex)!.getRank())\(self.RummyGame.wastePile.cardAt(cardIndex)!.getSuit())") as! RummyCardSprite
            if !wasteSprite.faceUp {
                wasteSprite.flipCardOver()
            }
            wasteSprite.run(SKAction.move(to: wastePileLocation , duration: 0.5))
            wasteSprite.zPosition = CGFloat(cardIndex)
        }
    }
    
    // MARK: Delegate functions for the Rummy Game
    func moveDidEndTurn() {
        print("Turn ended")
        if self.RummyGame.checkRoundEnded() {
            turnDidEndRound()
        } else {
            self.RummyGame.turnDidStart()
            runAllComputerTurns()
        }
    }
    
    func turnDidEndRound() {
        self.RummyGame.increaseScore()
        self.RummyGame.round += 1
        if self.RummyGame.checkGameEnded() {
            roundDidEndGame()
        } else {
            self.RummyGame.turn = 0
            self.RummyGame.currentPlayerNumber = self.RummyGame.turn%self.RummyGame.players.count
            for player in self.RummyGame.players {
                print(player.playerNumber, player.score)
            }
            self.RummyGame.deck.newDeck()
            self.RummyGame.wastePile.removeAllCards()
            self.RummyGame.melds.removeAll()
            for playerHand in self.RummyGame.playersHands {
                playerHand.removeAllCards()
            }
            self.removeAllChildren()
            addScoreBoard(false)
        }
        print("Round ended");
    }
    
    func roundDidEndGame() {
        self.RummyGame.turn = 0
        self.RummyGame.deck.newDeck()
        self.RummyGame.wastePile.removeAllCards()
        self.RummyGame.melds.removeAll()
        for playerHand in self.RummyGame.playersHands {
            playerHand.removeAllCards()
        }
        self.removeAllChildren()
        let alert = UIAlertView(title: "\(self.RummyGame.players[self.RummyGame.currentPlayerNumber].userName) Won!",
            message:  nil,
            delegate: nil,
            cancelButtonTitle: "Go to Scoreboard")
        alert.show()
        addScoreBoard(true)
        
    }
    
    
    // MARK: Touch recognizers
    func touchesBeganClosure(_ cardSprite: RummyCardSprite) {
        print("Began")
        
    }
    
    func touchesMovedClosure(_ cardSprite: RummyCardSprite) {
        print("Moved")
    }
    
    func touchesEndedClosure(_ cardSprite: RummyCardSprite) {
        print("Ended")
        
        if isCardOnTopOfDeck(cardSprite) || isCardOnTopOfWastePile(cardSprite) {
            cardWasDrawn(cardSprite)
            playMovedCardSoundEffect()
        } // Card must already have been drawn
        else {
            if self.RummyGame.selectedCards.contains(cardSprite.card) {
                cardSprite.run(SKAction.move(by: CGVector(dx: 0, dy: -50), duration: 0.5))
                self.RummyGame.selectedCards.removeCard(cardSprite.card)
                playTouchedDownCardSoundEffect()
            } else {
                cardSprite.run(SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.5))
                self.RummyGame.addSelectedCard(cardSprite.card)
                playTouchedUpCardSoundEffect()
            }
        }
        
        checkAndAddValidButtonOptions()
    }
    
    func playTouchedUpCardSoundEffect() {
        do {
            try touchedUpSoundEffect = AVAudioPlayer(contentsOf: URL(fileURLWithPath: touchedUpSoundEffectPath!))
            touchedUpSoundEffect.play()
        } catch {
            print("Something bad happened.")
        }
    }
    
    
    func playTouchedDownCardSoundEffect() {
        do {
            try touchedDownSoundEffect = AVAudioPlayer(contentsOf: URL(fileURLWithPath: touchedDownSoundEffectPath!))
            touchedDownSoundEffect.play()
        } catch {
            print("Something bad happened.")
        }
    }
    
    func playShuffleCardSoundEffect() {
        do {
            try shuffleSoundEffect = AVAudioPlayer(contentsOf: URL(fileURLWithPath: shuffleSoundEffectPath!))
            shuffleSoundEffect.play()
        } catch {
            print("Something bad happened.")
        }
    }
    
    
    func playMovedCardSoundEffect() {
        do {
            try moveSoundEffect = AVAudioPlayer(contentsOf: URL(fileURLWithPath: moveSoundEffectPath!))
            moveSoundEffect.play()
        } catch {
            print("Something bad happened.")
        }
    }
    
    // MARK: DEBUG
    func printCardsForDebug() {
        print("MELDS")
        for meldIndex in 0..<self.RummyGame.melds.count {
            for cardIndex in 0..<self.RummyGame.melds[meldIndex].meld.numberOfCards() {
                print(meldIndex,cardIndex, self.RummyGame.melds[meldIndex].meld.cardAt(cardIndex)!.getRank(),self.RummyGame.melds[meldIndex].meld.cardAt(cardIndex)!.getSuit())
            }
        }
        
        print("SELECTED CARDS")
        for cardIndex in 0..<self.RummyGame.selectedCards.numberOfCards() {
            print(cardIndex, self.RummyGame.selectedCards.cardAt(cardIndex)!.getRank(),self.RummyGame.selectedCards.cardAt(cardIndex)!.getSuit())
        }
        
        print("PLAYERS HANDS")
        for handIndex in 0..<self.RummyGame.playersHands.count {
            for cardIndex in 0..<self.RummyGame.playersHands[handIndex].numberOfCards() {
                print(handIndex,cardIndex, self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getRank(),self.RummyGame.playersHands[handIndex].cardAt(cardIndex)!.getSuit())
            }
        }
        
        
        print("WASTE")
        for cardIndex in 0..<self.RummyGame.wastePile.numberOfCards() {
            print(cardIndex, self.RummyGame.wastePile.cardAt(cardIndex)!.getRank(),self.RummyGame.wastePile.cardAt(cardIndex)!.getSuit())
        }
        
        print("DECK")
        for cardIndex in 0..<self.RummyGame.deck.numberOfCards() {
            print(cardIndex, self.RummyGame.deck.cardAt(cardIndex)!.getRank(),self.RummyGame.deck.cardAt(cardIndex)!.getSuit())
        }
    }
    
}
