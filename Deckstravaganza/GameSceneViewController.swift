//
//  GameSceneViewController.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import SpriteKit

var gameScene: SKScene?;
var spriteView: SKView = SKView();

class GameSceneViewController: UIViewController, UINavigationBarDelegate {
    var gameType: GameType!;    // What game should we play.
    var newGame: Bool = true;   // Should we begin a new game.
    var selectedMenuOption: Menu!;
    var selectedOptions: [AdjustableSetting]?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        spriteView = SKView(frame: self.view.frame);
        spriteView.showsDrawCount = true
        spriteView.showsNodeCount = true
        spriteView.showsFPS = true
        
        self.view.addSubview(spriteView);
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
                let game = Solitaire(selectedOptions: selectedOptions);
                gameScene = SolitaireScene(gameScene: self, game: game, gameDelegate: SolitaireDelegate(), size: CGSizeMake(768, 1024));
            case .Rummy:
                let game = Rummy(selectedOptions: selectedOptions);
                gameScene = RummyScene(gameScene: self, game: game, size: CGSizeMake(768, 1024));
            }
        }
        
        spriteView.presentScene(gameScene)
        
        // Create navigation bar.
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30));
        navigationBar.delegate = self;
        navigationBar.backgroundColor = UIColor.whiteColor();
        navigationBar.alpha = 0.7;
        
        // Create the navigation item
        let barItem = UINavigationItem();
        
        // Create navigation bar items
        let backButton = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: "backToMenu:");
        let newGameButton = UIBarButtonItem(title: "New Game", style: .Plain, target: self, action: "startNewGame:");
        
        backButton.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 15), forBarMetrics: UIBarMetrics.Default);
        newGameButton.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 10), forBarMetrics: UIBarMetrics.Default);
        
        barItem.leftBarButtonItem = backButton;
        barItem.rightBarButtonItem = newGameButton;
        
        navigationBar.items = [barItem];
        
        if(self.navigationController != nil) {
            self.navigationController!.setNavigationBarHidden(true, animated: true);
            self.navigationController!
        }
        
        self.view.addSubview(navigationBar);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.destinationViewController is DetailViewController) {
            (segue.destinationViewController as! DetailViewController).selectedMenuOption = selectedMenuOption;
        }
    }
    
    func backToMenu(sender: UIBarButtonItem) {
        if(self.navigationController != nil) {
            self.navigationController!.popToRootViewControllerAnimated(true);
        } else if let menuSplitViewController = self.splitViewController as? MenuSplitViewController {
            menuSplitViewController.toggleMasterView();
        }
    }
    
    func startNewGame(sender: UIBarButtonItem?) {
        gameScene!.removeEverything();
        spriteView.presentScene(nil);
        gameScene = nil;
        
        switch(gameType!) {
        case .Solitaire:
            gameScene = SolitaireScene(gameScene: self, game: Solitaire(), gameDelegate: SolitaireDelegate(), size: CGSizeMake(768, 1024));
        case .Rummy:
            gameScene = RummyScene(gameScene: self, game: Rummy(numberOfPlayers: 2), size: CGSizeMake(768, 1024));
        }
    
        spriteView.presentScene(gameScene);
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

extension SKScene {
    func removeEverything() {
        self.removeAllActions();
        self.removeAllChildren();
        self.removeFromParent();
    }
}

