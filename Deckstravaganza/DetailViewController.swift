//
//  DetailViewController.swift
//  Deckstravaganza
//
//  Created by Stephen on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit
import SpriteKit

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        testGameUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    var menu: Menu!{
        didSet (newMenu) {
            if(menu.name == "Test")
           {
                self.hideAllUI()
                self.testGameUI()
            }
            if(menu.name == "New")
            {
               self.newGameUI()
            }
            if(menu.name == "Continue")
            {
                self.hideAllUI()
                self.continueGameUI()
            }
            if(menu.name == "Saved Games")
            {
                self.hideAllUI()
                self.savedGameUI()
            }
        }
    }
    
    var Description = UILabel(frame: CGRectMake(0,0,200,21))
    let btntwo = UIButton(type: UIButtonType.System)
    let multlabel = UILabel(frame: CGRectMake(0,0,200,21))
    let switch1 = UISwitch(frame:CGRectMake(150, 300, 0, 0))
    
    func testGameUI(){
        
        btntwo.hidden = false
        Description.hidden = false
        
        Description.text = menu.description
        Description.center = CGPointMake(120, 160)
        Description.textAlignment = NSTextAlignment.Center
        self.view.addSubview(Description)
        
        btntwo.setTitle(menu.name, forState: .Normal)
        btntwo.backgroundColor = UIColor.whiteColor()
        btntwo.frame = CGRectMake(160, 150, 100, 50)
        btntwo.center = CGPointMake(350, 160 )
        btntwo.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btntwo)
    
    }
    
    func newGameUI(){
        
        multlabel.hidden = false
        switch1.hidden = false
        
        multlabel.center = CGPointMake(100, 100)
        multlabel.textAlignment = NSTextAlignment.Center
        multlabel.text = "Multiplayer"
        self.view.addSubview(multlabel)
        
        switch1.on = true
        switch1.setOn(true, animated: false)
        switch1.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
        switch1.center = CGPointMake(200, 100)
        self.view.addSubview(switch1)
        
        Description.text = "Game Settings"
        Description.center = CGPointMake(75, 75)
        Description.textAlignment = NSTextAlignment.Center
        self.view.addSubview(Description)
        
        btntwo.setTitle("Play", forState: .Normal)
        btntwo.frame = CGRectMake(200, 200, 100, 50)
        btntwo.center = CGPointMake(200, 300)
        btntwo.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btntwo)    }
    
    func continueGameUI(){
        
        btntwo.hidden = false
        Description.hidden = false
        
        Description.text = menu.description
        Description.center = CGPointMake(120, 160)
        Description.textAlignment = NSTextAlignment.Center
        self.view.addSubview(Description)
        
        btntwo.setTitle(menu.name, forState: .Normal)
        btntwo.center = CGPointMake(350, 165)
        btntwo.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btntwo)
     
    }
    
    func savedGameUI(){
        btntwo.hidden = false
        Description.hidden = false
        
        Description.text = menu.description
        Description.center = CGPointMake(120, 160)
        Description.textAlignment = NSTextAlignment.Center
        self.view.addSubview(Description)
        
        btntwo.setTitle(menu.name, forState: .Normal)
        btntwo.center = CGPointMake(350, 165)
        btntwo.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btntwo)
    }
    
    func hideAllUI(){
        btntwo.hidden = true
        Description.hidden = true
        multlabel.hidden = true
        switch1.hidden = true
    }
    
    func switchValueDidChange(sender:UISwitch!)
    {
        if (sender.on == true){
            print("on")
        }
        else{
            print("off")
        }
    }
    
    func buttonAction(sender:UIButton!)
    {
        print("Button tapped")
        performSegueWithIdentifier("menuToGameSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier != nil && segue.identifier == "menuToGameSegue") {
            if let menuSplitViewController = self.splitViewController as? MenuSplitViewController {
                menuSplitViewController.toggleMasterView();
            }
        }
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
    



 extension DetailViewController: MenuSelectionDelegate {
    func menuSelected(newMenu: Menu) {
        menu = newMenu
    }   
} 