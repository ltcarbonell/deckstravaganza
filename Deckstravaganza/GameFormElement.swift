//
//  GameFormElement.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 11/16/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class GameFormElement: UIView {
    let settingName: String;
    var formLabel: UILabel?;
    var formField: UIView;

    init(frame: CGRect, settingName: String, formLabel: UILabel?, formField: UIView) {
        self.settingName = settingName;
        self.formLabel = formLabel;
        self.formField = formField;
        
        super.init(frame: frame);
        
        setUpLayout();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpLayout() {
        let fieldXPosition: CGFloat;
        var defaultFrame: CGRect;
        
        if(formField as? GenericFormElements != nil) {
            defaultFrame = (formField as? GenericFormElements)!.getDefaultFrame();
            
            if(defaultFrame.width > self.frame.width / 2) {
                defaultFrame.size.width = self.frame.width / 2;
            }
            
            if(defaultFrame.height > self.frame.height) {
                defaultFrame.size.height = self.frame.height;
            }
        } else {
            defaultFrame = CGRect(x: 0, y: 0, width: self.frame.width / 2, height: self.frame.height);
        }
        
        formField.frame = defaultFrame;
        
        if(formLabel != nil) {
            formLabel!.center = CGPoint(x: 0, y: self.frame.midY);
            formLabel!.frame = CGRect(x: 0, y: 0, width: self.frame.width / 2, height: self.frame.height);
            formLabel!.textAlignment = .center;
            
            fieldXPosition = self.frame.midX + self.frame.width / 4;
            
            self.addSubview(formLabel!);
        } else {
            fieldXPosition = self.frame.midX;
        }
        
        formField.center = CGPoint(x: fieldXPosition, y: self.frame.midY);
        
        self.addSubview(formField);
    }
}
