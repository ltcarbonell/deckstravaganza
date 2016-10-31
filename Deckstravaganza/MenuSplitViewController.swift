//
//  MenuSplitViewController.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 10/26/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit
import GameKit

class MenuSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self;
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible;
        
        authenticateLocalPlayer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Return YES to prevent UIKit from applying its default behavior
        return true
    }
    
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem;
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil);
//        self.navigationController.
    }
    
    func authenticateLocalPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }else{
                print((GKLocalPlayer().isAuthenticated))
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
