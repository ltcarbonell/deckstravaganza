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
        
        newGameUI()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var Description: UILabel!

    
    
    
    var menu: Menu!{
        didSet (newMenu) {
            self.newGameUI()
        }
    }
    
    func newGameUI(){
        let btntwo = UIButton(type: UIButtonType.System)
        
        Description?.text = menu.description
        
        btntwo.setTitle(menu.name, forState: .Normal)
        btntwo.backgroundColor = UIColor.whiteColor()
        btntwo.frame = CGRectMake(160, 160, 100, 50)
        btntwo.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(btntwo)
    
    }
    
    func buttonAction(sender:UIButton!)
    {
        print("Button tapped")
        performSegueWithIdentifier("testSegue", sender: nil)
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