//
//  GameSceneViewController.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import SpriteKit


class GameSceneViewController: UIViewController {
    var solitaireScene : SolitaireScene!;
    var solitaireGame : Solitaire!;
    var solitaireGameDelegate : SolitaireDelegate!;
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        GameSceneViewController = UIViewController()
//        super.init()
//        
//        self.solitaireScene = SolitaireScene(gameScene: self, size: CGSizeMake(768, 1024))
//        self.solitaireGame = Solitaire()
//        self.solitaireGameDelegate = SolitaireDelegate()
//    }
//    
//    convenience override init() {
//        self.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        GameSceneViewController = UIViewController()
//        super.init(coder: aDecoder)
//    }
    
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
        //solitaireScene = SolitaireScene(size: CGSizeMake(768, 1024))
        
        self.solitaireGame = Solitaire()
        self.solitaireGameDelegate = SolitaireDelegate()
        self.solitaireScene = SolitaireScene(gameScene: self, size: CGSizeMake(768, 1024))
        
        let spriteView:SKView = self.view as! SKView
        spriteView.presentScene(solitaireScene)
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
