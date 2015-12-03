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

enum GameState : Int {
    case kGameStateWaitingForMatch = 0
    case kGameStateWaitingForStart
    case kGameStateActive
    case kGameStateDone
    case kGameStateWaitingForRandomNumber
}

enum MessageType : Int {
    case kMessageTypeGameBegin
    case kMessageTypeAction
    case kMessageTypeGameOver
    case kMessageTypeRandomNumber
}

struct Message{
    var messageType: MessageType
}

struct MessageRandomNumber{
    var message: Message
    var randomNumber: Int
}

struct MessageGameBegin{
    var message: Message
}

struct MessageGameAction{
    var message: Message
}

struct MessageGameOver{
    var message: Message
    var player1Won: Bool
}

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
    
    
/////////////////////////////////////// BEGIN MULTIPLAYER ///////////////////////////////////////////////////////
    
    var _gameState: GameState = .kGameStateWaitingForMatch
    var _ourRandomNumber: Int = random()
    var _isPlayer1: Bool = false
    var _receivedAllRandomNumbers: Bool = false
    var orderOfPlayers: NSMutableArray = []
    var  playerIdKey = "PlayerId"
    var randomNumberKey = "randomNumber"
    
    /// Method called when a match has been initiated.
    func matchStarted(){
        orderOfPlayers.addObject([playerIdKey: GKLocalPlayer.localPlayer().playerID!, randomNumberKey: _ourRandomNumber])
        
        // performSegueWithIdentifier("menuToGameSegue", sender: nil);
        print("Match has started successfully")
        
        if _receivedAllRandomNumbers {
            _gameState = .kGameStateWaitingForStart
        }
        else {
            _gameState = .kGameStateWaitingForRandomNumber
        }
        self.sendRandomNumber()
        print("sent random number", _ourRandomNumber)
        self.tryStartGame()
    }
    
    /// Method called when the device received data about the match from another device in the match.
    func match(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: String){
        
        let message = UnsafePointer<Message>(data.bytes).memory
        if message.messageType == MessageType.kMessageTypeRandomNumber {
            let messageRandomNumber = UnsafePointer<MessageRandomNumber>(data.bytes).memory
            print("recieved random number ", messageRandomNumber.randomNumber)
            var tie: Bool = false
            if (messageRandomNumber.randomNumber == _ourRandomNumber) {
                print("tie")
                tie = true
                self._ourRandomNumber = random()
                self.sendRandomNumber()
            }
            else {
                let dictionary: [NSObject : AnyObject]  = [playerIdKey : playerID, randomNumberKey: messageRandomNumber.randomNumber]
                // dictionary[playerID] = messageRandomNumber.randomNumber
                
                self.processReceivedRandomNumber(dictionary)
                
            }
            if _receivedAllRandomNumbers {
              //  self._isPlayer1 = self.isLocalPlayerPlayer1()
            }
            if !tie && _receivedAllRandomNumbers {
                //5
                if _gameState == .kGameStateWaitingForRandomNumber {
                    self._gameState = .kGameStateWaitingForStart
                }
                self.tryStartGame()
            }
            
        }
        
    }
    
    /// Method called when the match has ended.
    func matchEnded(){
        
    }
    
    func sendRandomNumber(){
        var message1 = MessageRandomNumber(message: Message(messageType: .kMessageTypeRandomNumber), randomNumber: _ourRandomNumber)
        let data = NSData(bytes: &message1, length: sizeof(MessageRandomNumber))
        //  let data = str.dataUsingEncoding(NSUTF8StringEncoding)
        self.sendData(data)
    }
    
    func sendGameBegin() {
        var message2 = MessageGameBegin(message: Message(messageType: .kMessageTypeGameBegin))
        let data = NSData(bytes: &message2, length: sizeof(MessageGameBegin))
        self.sendData(data)
    }
    
    func tryStartGame(){
        if _isPlayer1 && _gameState == .kGameStateWaitingForStart {
            self._gameState = .kGameStateActive
            self.sendGameBegin()
        }
        
    }
    
    func processReceivedRandomNumber(randomNumberDetails: [NSObject : AnyObject]) {
        //1
        if orderOfPlayers.containsObject(randomNumberDetails) {
            orderOfPlayers.removeObjectAtIndex(orderOfPlayers.indexOfObject(randomNumberDetails))
        }
        //2
        orderOfPlayers.addObject(randomNumberDetails)
        //3
        let sortByRandomNumber: NSSortDescriptor = NSSortDescriptor(key: randomNumberKey, ascending: false)
        let sortDescriptors: [NSSortDescriptor] = [sortByRandomNumber]
        orderOfPlayers.sortUsingDescriptors(sortDescriptors)
        //4
        // if self.allRandomNumbersAreReceived() {
        self._receivedAllRandomNumbers = true
        //  }
        
    }
    
    //  func allRandomNumbersAreReceived() -> Bool{
    //       var receivedRandomNumbers: [AnyObject] = NSMutableArray() as [AnyObject]
    //       for dict: [NSObject: AnyObject] in orderOfPlayers {
    //       receivedRandomNumbers.addObject(dict[randomNumberKey])
    //   }
    //       var arrayOfUniqueRandomNumbers: [AnyObject] = NSSet.setWithArray(receivedRandomNumbers).allObjects()
    //   if arrayOfUniqueRandomNumbers.count == GCHelper.sharedInstance.match.playerIDs.count + 1 {
    //       return true
    //  }
    
    //      return false
    //  }
    
    
 //   func isLocalPlayerPlayer1() -> Bool {
        
 //       let dictionary: [NSObject : String] = orderOfPlayers[0]
 //       if (dictionary[playerIdKey] == GKLocalPlayer.localPlayer().playerID) {
 //           print("I'm player 1")
 //           return true
  //      }
  //      return false
        
 //   }
    
    func sendData(data: NSData){
        do{
            try GCHelper.sharedInstance.match.sendDataToAllPlayers(data, withDataMode: .Reliable)
        }
        catch{
            print("An unknown error has occured")
        }
    }
    
///////////////////////////////////////// END MULTIPLAYER /////////////////////////////////////////////////////////////////////////////////////
    
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
                gameOptions = Solitaire(selectedOptions: nil).getGameOptions();
            case .Rummy:
                gameOptions = Rummy(selectedOptions: nil).getGameOptions();
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
        
        performSegueWithIdentifier("menuToGameSegue", sender: sender);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let gameViewController = (segue.destinationViewController as? GameSceneViewController) {
            gameViewController.gameType = selectedMenuOption.gameType;
            gameViewController.newGame = self.newGame;
            gameViewController.selectedMenuOption = self.selectedMenuOption;
            
            var selectedOptions = gameOptions;
            
            if(sender != nil && selectedOptions != nil) {
                if((sender! as! UIButton).titleLabel?.text != "Continue") {
                    for(var index = selectedOptions!.count - 1; index >= 0; index--) {
                        switch(selectedOptions![index].formType) {
                        case .Cards:
                            break;
                        case .DropDown:
                            selectedOptions![index].options = [(formFields[index].formField as! GenericPickerView).getResults()];
                        case .Slider:
                            selectedOptions![index].options = [(formFields[index].formField as! GenericSliderView).getResults()];
                        case .Switch:
                            selectedOptions![index].options = [(formFields[index].formField as! GenericSwitchView).getResults()];
                        }
                    }
                }
            }
            
            gameViewController.selectedOptions = selectedOptions;
            
            if let menuSplitViewController = self.splitViewController as? MenuSplitViewController {
                menuSplitViewController.toggleMasterView();
            }
        }
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