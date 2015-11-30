//
//  GameSceneViewController.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import SpriteKit

var gameScene: SKScene?;

class GameSceneViewController: UIViewController {
    var gameType: GameType!;    // What game should we play.
    var newGame: Bool = true;   // Should we begin a new game.
    var selectedMenuOption: Menu!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let spriteView: SKView = self.view as! SKView
        spriteView.showsDrawCount = true
        spriteView.showsNodeCount = true
        spriteView.showsFPS = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if(gameType == nil && newGame) {
            performSegueWithIdentifier("gameToMenu", sender: nil);
            return;
        } else if(gameScene == nil && !newGame) {
            performSegueWithIdentifier("gameToMenu", sender: nil);
            return;
        }
        
        if(newGame) {
            switch(gameType!) {
            case .Solitaire:
                gameScene = SolitaireScene(gameScene: self, game: Solitaire(), gameDelegate: SolitaireDelegate(), size: CGSizeMake(768, 1024));
            case .Rummy:
                gameScene = RummyScene(gameScene: self, game: Rummy(numberOfPlayers: 4), size: CGSizeMake(768, 1024));
            }
        }
        
        let spriteView:SKView = self.view as! SKView
        spriteView.presentScene(gameScene)
        
//        menuButton = SKSpriteNode(texture: SKTexture(imageNamed: "menuButtonTexture"));
//        menuButton.zPosition = 99999;
//        menuButton.size = CGSize(width: 40, height: 100);
//        menuButton.position = CGPoint(x: CGRectGetMinX(gameScene.frame) + 50, y: CGRectGetMaxY(gameScene.frame) - 50);
//        
//        gameScene.addChild(menuButton);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.destinationViewController is DetailViewController) {
            (segue.destinationViewController as! DetailViewController).selectedMenuOption = selectedMenuOption;
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}

