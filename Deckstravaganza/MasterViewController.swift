//
//  MasterViewController.swift
//  Deckstravaganza
//
//  Created by Stephen on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

protocol MenuSelectionDelegate: class {
    func menuSelected(newMenu: Menu)
}

class MasterViewController: UITableViewController {
    weak var delegate: MenuSelectionDelegate?
    var menus: [[Menu]] = [
        [Menu(name: "Continue", description: "Continue Playing Last Game")],
        [
            Menu(name: "New Game", description: "New Game", clickable: false),
            Menu(name: "\tSolitaire", description: "New Solitaire Game", level: 2, viewGameOptions: true, gameType: .Solitaire),
            Menu(name: "\tRummy", description: "New Rummy Game", level: 2, viewGameOptions: true, gameType: .Rummy)
        ]
    ];

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menus.count;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let menuItems = menus[section].count;
        
        if(menus[section].first!.clickable) {
            return menuItems;
        } else {
            return menuItems - 1;
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(!menus[section].first!.clickable) {
            return menus[section].first!.name;
        }
        
        return nil;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...
        if(!menus[indexPath.section].first!.clickable) {
            let menuItem = self.menus[indexPath.section][indexPath.row + 1];
            cell.textLabel?.text = menuItem.name;
            
            return cell;
        }
        
        let menuItem = self.menus[indexPath.section][indexPath.row];
        cell.textLabel?.text = menuItem.name;
        
        return cell
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedMenu: Menu;
        if(self.menus[indexPath.section].first!.clickable) {
            selectedMenu = self.menus[indexPath.section][indexPath.row];
        } else {
            selectedMenu = self.menus[indexPath.section][indexPath.row + 1];
        }
        
        self.delegate?.menuSelected(selectedMenu)
    
        if let detailViewController = self.delegate as? DetailViewController {
            detailViewController.tearDownMenuUI();
            detailViewController.setupMenuUI();
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
