//
//  DetailViewController.swift
//  Deckstravaganza
//
//  Created by Stephen on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

let FIELD_START_FROM_TOP: CGFloat = 50;
let FIELD_TOP_MARGIN: CGFloat = 10;
let FIELD_HEIGHT: CGFloat = 40;
let TITLE_SIZE: CGFloat = 25;

class DetailViewController: UIViewController, GCHelperDelegate {
    let titleMargin: CGFloat = 50;
    let buttonFrame = CGRect(x: 0, y: 0, width: 100, height: 50);
    var selectedMenuOption: Menu!;
    var gameOptions: [AdjustableSetting]? = nil;
    var newGame: Bool = true;
    
    var menuDescription = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 30))
    var formFields: [GameFormElement] = [];
    
    var buttonOption = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 20));
    
//    let btntwo = UIButton(type: UIButtonType.System)
//    let multlabel = UILabel(frame: CGRectMake(0,0,200,21))
//    let switch1 = UISwitch(frame:CGRectMake(150, 300, 0, 0))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the menu
        tearDownMenuUI();
        setupMenuUI();
    }
    
    override func viewDidAppear(animated: Bool) {
        self.view.setNeedsDisplay();
        self.view.setNeedsLayout();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tearDownMenuUI() {
        for element in formFields {
            element.removeFromSuperview();
        }
        
        menuDescription.removeFromSuperview();
        buttonOption.removeFromSuperview();
    }
    
    /// Method called when a match has been initiated.
    func matchStarted(){
        
    }
    
    /// Method called when the device received data about the match from another device in the match.
    func match(match: GKMatch, didReceiveData: NSData, fromPlayer: String){
        
    }
    
    /// Method called when the match has ended.
    func matchEnded(){
        
    }
    
    
    
    
    
    
    func setupMenuUI() {
        gameOptions = nil;
        menuDescription.text = selectedMenuOption.description;
        menuDescription.font = UIFont.systemFontOfSize(25, weight: UIFontWeightBold);
        menuDescription.textAlignment = .Center;
        
        if(splitViewController != nil) {
            menuDescription.center = CGPoint(x: (UIScreen.mainScreen().bounds.width - splitViewController!.primaryColumnWidth) / 2, y: titleMargin);
        } else {
            menuDescription.center = CGPoint(x: CGRectGetMidX(UIScreen.mainScreen().bounds), y: titleMargin);
        }
        
        self.view.addSubview(menuDescription);
        
        if(selectedMenuOption.viewGameOptions && selectedMenuOption.gameType != nil) {
            switch(selectedMenuOption.gameType!) {
            case .Solitaire:
                gameOptions = Solitaire().getGameOptions();
            case .Rummy:
                gameOptions = Rummy(numberOfPlayers: 1).getGameOptions();
            }
        }
        
        let elementFrame : CGRect;
        if(splitViewController != nil) {
            elementFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width - splitViewController!.primaryColumnWidth, height: FIELD_HEIGHT);
        } else {
            elementFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: FIELD_HEIGHT);
        }
        
        var numberFields = 0;
        if(gameOptions != nil) {
            for gameOption in gameOptions! {
                let element: GameFormElement;
                let elementLabel = UILabel();
                elementLabel.text = gameOption.settingName;
                
                switch(gameOption.formType) {
                case .Cards:
                    element = GameFormElement(frame: CGRect(), settingName: "", formLabel: nil, formField: UIView());
                    break;
                case .DropDown:
                    let elementField = GenericPickerView(data: gameOption.options);
                    elementField.dataSource = elementField;
                    elementField.delegate = elementField;
                    
                    element = GameFormElement(frame: elementFrame, settingName: gameOption.settingName, formLabel: elementLabel, formField: elementField);
                case .Slider:
                    let elementField = GenericSliderView(data: gameOption.options);
                    
                    element = GameFormElement(frame: elementFrame, settingName: gameOption.settingName, formLabel: elementLabel, formField: elementField);
                case .Switch:
                    let elementField = GenericSwitchView();
                    
                    /* All switches are assumed to be for multiplayer settings. */
                    elementField.addTarget(self, action: "updateMultiplayer:", forControlEvents: UIControlEvents.AllTouchEvents);
                    
                    element = GameFormElement(frame: elementFrame, settingName: gameOption.settingName, formLabel: elementLabel, formField: elementField);
                }
                
                element.center = CGPoint(x: CGRectGetMidX(elementFrame), y: FIELD_START_FROM_TOP + FIELD_TOP_MARGIN + (CGFloat(numberFields) * FIELD_HEIGHT) + TITLE_SIZE);
                
                formFields.append(element);
                
                self.view.addSubview(formFields.last!);
                
                numberFields++;
            }
        }
        
        buttonOption.frame = buttonFrame;
        buttonOption.center = CGPoint(x: CGRectGetMidX(elementFrame), y: FIELD_START_FROM_TOP + FIELD_TOP_MARGIN + (CGFloat(numberFields) * FIELD_HEIGHT) + TITLE_SIZE);
        buttonOption.alpha = 0.8;
        buttonOption.backgroundColor = UIColor.clearColor();
        buttonOption.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0), forState: .Normal);
        buttonOption.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 0.5), forState: .Highlighted);
        buttonOption.userInteractionEnabled = true;
        
        if(selectedMenuOption.name == "Continue") {
            buttonOption.setTitle("Continue", forState: .Normal);
            
            newGame = false;
            
            if(gameScene == nil) {
                // Continue should be disabled.
                buttonOption.userInteractionEnabled = false;
                buttonOption.setTitleColor(UIColor.lightGrayColor(), forState: .Normal);
            }
        } else {
            buttonOption.setTitle("Play", forState: .Normal);

            newGame = true;
        }
        
        self.view.addSubview(buttonOption);
        
        buttonOption.hidden = false;
        buttonOption.setNeedsDisplay();
        buttonOption.setNeedsLayout();
        
        buttonOption.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside);
    }
    
    func buttonPressed(sender: UIButton?) {
        if(sender != nil) {
            if(sender!.titleLabel?.text == "Continue") {
                if(gameScene == nil) {
                    return;
                }
            }
        }
        
        performSegueWithIdentifier("menuToGameSegue", sender: nil);
    }
    
    func updateMultiplayer(sender: UISwitch?) {
        if(sender != nil) {
            if(sender!.on) {
                // Start multiplayer.
        GCHelper.sharedInstance.findMatchWithMinPlayers(2, maxPlayers: 4, viewController: self, delegate: self)
                
            } else {
                // Check if multiplayer is on and turn off if necessary.
            }
        }
    }
  
//    var menu: Menu!{
//        didSet (newMenu) {
//            if(menu.name == "Test")
//           {
//                self.hideAllUI()
//                self.testGameUI()
//            }
//            if(menu.name == "New")
//            {
//               self.newGameUI()
//            }
//            if(menu.name == "Continue")
//            {
//                self.hideAllUI()
//                self.continueGameUI()
//            }
//            if(menu.name == "Saved Games")
//            {
//                self.hideAllUI()
//                self.savedGameUI()
//            }
//        }
//    }
    
    
//    func testGameUI(){
//        
//        btntwo.hidden = false
//        Description.hidden = false
//        
//        Description.text = menu.description
//        Description.center = CGPointMake(120, 160)
//        Description.textAlignment = NSTextAlignment.Center
//        self.view.addSubview(Description)
//        
//        btntwo.setTitle(menu.name, forState: .Normal)
//        btntwo.backgroundColor = UIColor.whiteColor()
//        btntwo.frame = CGRectMake(160, 150, 100, 50)
//        btntwo.center = CGPointMake(350, 160 )
//        btntwo.addTarget(self, action: "testAction:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(btntwo)
//    
//    }
    
//    func newGameUI(){
//        
//        multlabel.hidden = false
//        switch1.hidden = false
//        
//        multlabel.center = CGPointMake(100, 100)
//        multlabel.textAlignment = NSTextAlignment.Center
//        multlabel.text = "Multiplayer"
//        self.view.addSubview(multlabel)
//        
//        switch1.on = true
//        switch1.setOn(true, animated: false)
//        switch1.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
//        switch1.center = CGPointMake(200, 100)
//        self.view.addSubview(switch1)
//        
//        Description.text = "Game Settings"
//        Description.center = CGPointMake(75, 75)
//        Description.textAlignment = NSTextAlignment.Center
//        self.view.addSubview(Description)
//        
//        btntwo.setTitle("Play", forState: .Normal)
//        btntwo.frame = CGRectMake(200, 200, 100, 50)
//        btntwo.center = CGPointMake(200, 300)
//        btntwo.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(btntwo)    }
//    
//    func continueGameUI(){
//        
//        btntwo.hidden = false
//        Description.hidden = false
//        
//        Description.text = menu.description
//        Description.center = CGPointMake(120, 160)
//        Description.textAlignment = NSTextAlignment.Center
//        self.view.addSubview(Description)
//        
//        btntwo.setTitle(menu.name, forState: .Normal)
//        btntwo.center = CGPointMake(350, 165)
//        btntwo.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(btntwo)
//     
//    }
//    
//    func savedGameUI(){
//        btntwo.hidden = false
//        Description.hidden = false
//        
//        Description.text = menu.description
//        Description.center = CGPointMake(120, 160)
//        Description.textAlignment = NSTextAlignment.Center
//        self.view.addSubview(Description)
//        
//        btntwo.setTitle(menu.name, forState: .Normal)
//        btntwo.center = CGPointMake(350, 165)
//        btntwo.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(btntwo)
//    }
//    
//    func hideAllUI(){
//        btntwo.hidden = true
//        Description.hidden = true
//        multlabel.hidden = true
//        switch1.hidden = true
//    }
//    
//    func switchValueDidChange(sender:UISwitch!)
//    {
//        if (sender.on == true){
//            print("on")
//        }
//        else{
//            print("off")
//        }
//    }
//    
//    func testAction(sender:UIButton!)
//    {
//        print("Button tapped")
//        performSegueWithIdentifier("menuToGameSegue", sender: nil)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier != nil && segue.identifier == "menuToGameSegue") {
            if let menuSplitViewController = self.splitViewController as? MenuSplitViewController {
                menuSplitViewController.toggleMasterView();
            }
            
            if let gameViewController = segue.destinationViewController as? GameSceneViewController {
                gameViewController.gameType = selectedMenuOption.gameType;
                gameViewController.newGame = self.newGame;
                gameViewController.selectedMenuOption = self.selectedMenuOption;
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
        selectedMenuOption = newMenu;
    }   
} 