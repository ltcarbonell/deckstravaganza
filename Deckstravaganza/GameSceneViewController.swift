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
        spriteView.showsDrawCount = false
        spriteView.showsNodeCount = false
        spriteView.showsFPS = false
        
        self.view.addSubview(spriteView);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(gameType == nil && newGame) {
            performSegue(withIdentifier: "gameToMenu", sender: nil);
            return;
        } else if(gameScene == nil && !newGame) {
            performSegue(withIdentifier: "gameToMenu", sender: nil);
            return;
        }
        
        if(newGame) {
            switch(gameType!) {
            case .solitaire:
                let game = Solitaire(selectedOptions: selectedOptions);
                gameScene = SolitaireScene(gameScene: self, game: game, gameDelegate: SolitaireDelegate(), size: CGSize(width: 768, height: 1024));
            case .rummy:
                let game = Rummy(selectedOptions: selectedOptions);
                gameScene = RummyScene(gameScene: self, game: game, size: CGSize(width: 768, height: 1024));
            }
        }
        
        spriteView.presentScene(gameScene)
        
        // Create navigation bar.
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30));
        navigationBar.delegate = self;
        navigationBar.backgroundColor = UIColor.white;
        navigationBar.alpha = 0.7;
        
        // Create the navigation item
        let barItem = UINavigationItem();
        
        // Create navigation bar items
        let backButton = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(GameSceneViewController.backToMenu(_:)));
        let newGameButton = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(GameSceneViewController.startNewGame(_:)));
        
        backButton.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 15), for: UIBarMetrics.default);
        newGameButton.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 10), for: UIBarMetrics.default);
        
        barItem.leftBarButtonItem = backButton;
        barItem.rightBarButtonItem = newGameButton;
        
        navigationBar.items = [barItem];
        
        if(self.navigationController != nil) {
            self.navigationController!.setNavigationBarHidden(true, animated: false);
        }
        
        self.view.addSubview(navigationBar);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.destination is DetailViewController) {
            (segue.destination as! DetailViewController).selectedMenuOption = selectedMenuOption;
        }
    }
    
    func backToMenu(_ sender: UIBarButtonItem) {
        if(self.navigationController != nil) {
            self.navigationController!.popToRootViewController(animated: true);
        } else if let menuSplitViewController = self.splitViewController as? MenuSplitViewController {
            menuSplitViewController.toggleMasterView();
        }
    }
    
    func startNewGame(_ sender: UIBarButtonItem?) {
        gameScene!.removeEverything();
        spriteView.presentScene(nil);
        gameScene = nil;
        
        switch(gameType!) {
        case .solitaire:
            let game = Solitaire(selectedOptions: selectedOptions);
            gameScene = SolitaireScene(gameScene: self, game: game, gameDelegate: SolitaireDelegate(), size: CGSize(width: 768, height: 1024));
        case .rummy:
            let game = Rummy(selectedOptions: selectedOptions);
            gameScene = RummyScene(gameScene: self, game: game, size: CGSize(width: 768, height: 1024));
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

