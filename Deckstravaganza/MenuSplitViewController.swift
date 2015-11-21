//
//  MenuSplitViewController.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 10/26/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit
import GameKit

class MenuSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = .AllVisible;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem()
        UIApplication.sharedApplication().sendAction(barButtonItem.action, to: barButtonItem.target, from: nil, forEvent: nil)
    }
    
    func authenticateLocalPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if error != nil {
                print(error)
            }
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }else{
                print((GKLocalPlayer().authenticated))
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

}
