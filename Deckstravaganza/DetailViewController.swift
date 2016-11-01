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
    
    var menuDescription = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
    var formFields: [GameFormElement] = [];
    
    var buttonOption = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 20));

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the menu
        tearDownMenuUI();
        setupMenuUI();
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    var _ourRandomNumber: Int = Int(arc4random())
    var _isPlayer1: Bool = false
    var _receivedAllRandomNumbers: Bool = false
    var orderOfPlayers: NSMutableArray = []
    var  playerIdKey = "PlayerId"
    var randomNumberKey = "randomNumber"
    
    /// Method called when a match has been initiated.
    func matchStarted(){
        orderOfPlayers.add([playerIdKey: GKLocalPlayer.localPlayer().playerID!, randomNumberKey: _ourRandomNumber])
        
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
    func match(_ match: GKMatch, didReceiveData data: Data, fromPlayer playerID: String){
        
        let message = (data as NSData).bytes.bindMemory(to: Message.self, capacity: data.count).pointee
        if message.messageType == MessageType.kMessageTypeRandomNumber {
            let messageRandomNumber = (data as NSData).bytes.bindMemory(to: MessageRandomNumber.self, capacity: data.count).pointee
            print("recieved random number ", messageRandomNumber.randomNumber)
            var tie: Bool = false
            if (messageRandomNumber.randomNumber == _ourRandomNumber) {
                print("tie")
                tie = true
                self._ourRandomNumber = Int(arc4random())
                self.sendRandomNumber()
            }
            else {
                let dictionary: [AnyHashable: Any]  = [playerIdKey : playerID, randomNumberKey: messageRandomNumber.randomNumber]
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
        _ = MessageRandomNumber(message: Message(messageType: .kMessageTypeRandomNumber), randomNumber: _ourRandomNumber)
//        let data = Data(bytes: UnsafePointer<UInt8>(&message1), count: sizeof(MessageRandomNumber))
        //  let data = str.dataUsingEncoding(NSUTF8StringEncoding)
//        self.sendData(data)
    }
    
    func sendGameBegin() {
        _ = MessageGameBegin(message: Message(messageType: .kMessageTypeGameBegin))
//        let data = Data(bytes: UnsafePointer<UInt8>(&message2), count: sizeof(MessageGameBegin))
//        self.sendData(data)
    }
    
    func tryStartGame(){
        if _isPlayer1 && _gameState == .kGameStateWaitingForStart {
            self._gameState = .kGameStateActive
            self.sendGameBegin()
        }
        
    }
    
    func processReceivedRandomNumber(_ randomNumberDetails: [AnyHashable: Any]) {
        //1
        if orderOfPlayers.contains(randomNumberDetails) {
            orderOfPlayers.removeObject(at: orderOfPlayers.index(of: randomNumberDetails))
        }
        //2
        orderOfPlayers.add(randomNumberDetails)
        //3
        let sortByRandomNumber: NSSortDescriptor = NSSortDescriptor(key: randomNumberKey, ascending: false)
        let sortDescriptors: [NSSortDescriptor] = [sortByRandomNumber]
        orderOfPlayers.sort(using: sortDescriptors)
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
    
    func sendData(_ data: Data){
        do{
            try GCHelper.sharedInstance.match.sendData(toAllPlayers: data, with: .reliable)
        }
        catch{
            print("An unknown error has occured")
        }
    }
    
///////////////////////////////////////// END MULTIPLAYER /////////////////////////////////////////////////////////////////////////////////////
    
    func setupMenuUI() {
        gameOptions = nil;
        menuDescription.text = selectedMenuOption.description;
        menuDescription.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold);
        menuDescription.textAlignment = .center;
        
        if(splitViewController != nil) {
            menuDescription.center = CGPoint(x: (UIScreen.main.bounds.width - splitViewController!.primaryColumnWidth) / 2, y: titleMargin);
        } else {
            menuDescription.center = CGPoint(x: UIScreen.main.bounds.midX, y: titleMargin);
        }
        
        self.view.addSubview(menuDescription);
        
        if(selectedMenuOption.viewGameOptions && selectedMenuOption.gameType != nil) {
            switch(selectedMenuOption.gameType!) {
            case .solitaire:
                gameOptions = Solitaire(selectedOptions: nil).getGameOptions();
            case .rummy:
                gameOptions = Rummy(selectedOptions: nil).getGameOptions();
            }
        }
        
        let elementFrame : CGRect;
        if(splitViewController != nil) {
            elementFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - splitViewController!.primaryColumnWidth, height: FIELD_HEIGHT);
        } else {
            elementFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: FIELD_HEIGHT);
        }
        
        var numberFields = 0;
        if(gameOptions != nil) {
            for gameOption in gameOptions! {
                let element: GameFormElement;
                let elementLabel = UILabel();
                elementLabel.text = gameOption.settingName;
                
                switch(gameOption.formType) {
                case .cards:
                    element = GameFormElement(frame: CGRect(), settingName: "", formLabel: nil, formField: UIView());
                    break;
                case .dropDown:
                    let elementField = GenericPickerView(data: gameOption.options);
                    elementField.dataSource = elementField;
                    elementField.delegate = elementField;
                    
                    element = GameFormElement(frame: elementFrame, settingName: gameOption.settingName, formLabel: elementLabel, formField: elementField);
                case .slider:
                    let elementField = GenericSliderView(data: gameOption.options);
                    
                    element = GameFormElement(frame: elementFrame, settingName: gameOption.settingName, formLabel: elementLabel, formField: elementField);
                case .switch:
                    let elementField = GenericSwitchView();
                    
                    /* All switches are assumed to be for multiplayer settings. */
                    elementField.addTarget(self, action: #selector(DetailViewController.updateMultiplayer(_:)), for: UIControlEvents.allTouchEvents);
                    
                    element = GameFormElement(frame: elementFrame, settingName: gameOption.settingName, formLabel: elementLabel, formField: elementField);
                }
                
                element.center = CGPoint(x: elementFrame.midX, y: FIELD_START_FROM_TOP + FIELD_TOP_MARGIN + (CGFloat(numberFields) * FIELD_HEIGHT) + TITLE_SIZE);
                
                formFields.append(element);
                
                self.view.addSubview(formFields.last!);
                
                numberFields += 1;
            }
        }
        
        buttonOption.frame = buttonFrame;
        buttonOption.center = CGPoint(x: elementFrame.midX, y: FIELD_START_FROM_TOP + FIELD_TOP_MARGIN + (CGFloat(numberFields) * FIELD_HEIGHT) + TITLE_SIZE);
        buttonOption.alpha = 0.8;
        buttonOption.backgroundColor = UIColor.clear;
        buttonOption.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0), for: UIControlState());
        buttonOption.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 0.5), for: .highlighted);
        buttonOption.isUserInteractionEnabled = true;
        
        if(selectedMenuOption.name == "Continue") {
            buttonOption.setTitle("Continue", for: UIControlState());
            
            newGame = false;
            
            if(gameScene == nil) {
                // Continue should be disabled.
                buttonOption.isUserInteractionEnabled = false;
                buttonOption.setTitleColor(UIColor.lightGray, for: UIControlState());
            }
        } else {
            buttonOption.setTitle("Play", for: UIControlState());

            newGame = true;
        }
        
        self.view.addSubview(buttonOption);
        
        buttonOption.isHidden = false;
        buttonOption.setNeedsDisplay();
        buttonOption.setNeedsLayout();
        
        buttonOption.addTarget(self, action: #selector(DetailViewController.buttonPressed(_:)), for: .touchUpInside);
    }
    
    func buttonPressed(_ sender: UIButton?) {
        if(sender != nil) {
            if(sender!.titleLabel?.text == "Continue") {
                if(gameScene == nil) {
                    return;
                }
            }
        }
        
        performSegue(withIdentifier: "menuToGameSegue", sender: sender);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameViewController = (segue.destination as? GameSceneViewController) {
            gameViewController.gameType = selectedMenuOption.gameType;
            gameViewController.newGame = self.newGame;
            gameViewController.selectedMenuOption = self.selectedMenuOption;
            
            var selectedOptions = gameOptions;
            
            if(sender != nil && selectedOptions != nil) {
                if((sender! as! UIButton).titleLabel?.text != "Continue") {
                    for index in (0 ..< selectedOptions!.count).reversed() {
                        switch(selectedOptions![index].formType) {
                        case .cards:
                            break;
                        case .dropDown:
                            selectedOptions![index].options = [(formFields[index].formField as! GenericPickerView).getResults()];
                        case .slider:
                            selectedOptions![index].options = [(formFields[index].formField as! GenericSliderView).getResults()];
                        case .switch:
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
    
    func updateMultiplayer(_ sender: UISwitch?) {
        if(sender != nil) {
            if(sender!.isOn) {
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
    func menuSelected(_ newMenu: Menu) {
        selectedMenuOption = newMenu;
    }   
} 
