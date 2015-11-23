//
//  DetailViewController.swift
//  Deckstravaganza
//
//  Created by Stephen on 9/28/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit
import SpriteKit

let FIELD_START_FROM_TOP: CGFloat = 50;
let FIELD_TOP_MARGIN: CGFloat = 10;
let FIELD_HEIGHT: CGFloat = 50;

class DetailViewController: UIViewController {
    let titleMargin: CGFloat = 20;
    let buttonFrame = CGRect(x: 0, y: 0, width: 100, height: 50);
    var selectedMenuOption: Menu!;
    var gameOptions: [AdjustableSetting]? = nil;
    
    var menuDescription = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width / 2, 21))
    var formFields: [GameFormElement] = [];
    
    var buttonOption = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 20));
    
//    let btntwo = UIButton(type: UIButtonType.System)
//    let multlabel = UILabel(frame: CGRectMake(0,0,200,21))
//    let switch1 = UISwitch(frame:CGRectMake(150, 300, 0, 0))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the screen.
        tearDownMenuUI();
        setupMenuUI();
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
    
    func setupMenuUI() {
        gameOptions = nil;
        menuDescription.text = selectedMenuOption.description;
        menuDescription.center = CGPoint(x: menuDescription.frame.width / 2 + titleMargin, y: titleMargin);
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
                let elementLabel = UILabel();
                elementLabel.text = gameOption.settingName;
                
                switch(gameOption.formType) {
                case .Cards:
                    break;
                case .DropDown:
                    let elementField = GenericPickerView(data: gameOption.options);
                    elementField.dataSource = elementField;
                    elementField.delegate = elementField;
                    
                    let element: GameFormElement = GameFormElement(frame: elementFrame, settingName: gameOption.settingName, formLabel: elementLabel, formField: elementField);
                    element.center = CGPoint(x: CGRectGetMidX(elementFrame), y: FIELD_START_FROM_TOP + FIELD_TOP_MARGIN + (CGFloat(numberFields) * FIELD_HEIGHT));
                    
                    formFields.append(element);
                    
                    self.view.addSubview(formFields.last!);
                case .Slider:
                    break;
                case .Switch:
                    break;
                }
                
                numberFields++;
            }
        }
        
        buttonOption.frame = buttonFrame;
        buttonOption.center = CGPoint(x: CGRectGetMidX(elementFrame), y: FIELD_START_FROM_TOP + FIELD_TOP_MARGIN + (CGFloat(numberFields) * FIELD_HEIGHT));
        buttonOption.alpha = 0.8;
        buttonOption.backgroundColor = UIColor.clearColor();
        buttonOption.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0), forState: .Normal);
        buttonOption.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 0.5), forState: .Highlighted);
        buttonOption.userInteractionEnabled = true;
        
        if(selectedMenuOption.name == "Continue") {
            buttonOption.setTitle("Continue", forState: .Normal);
        } else {
            buttonOption.setTitle("Play", forState: .Normal);
        }
        
        self.view.addSubview(buttonOption);
        
        buttonOption.hidden = false;
        buttonOption.setNeedsDisplay();
        buttonOption.setNeedsLayout();
        
        buttonOption.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside);
    }
    
    func buttonPressed(sender: UIButton?) {
        performSegueWithIdentifier("menuToGameSegue", sender: nil);
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