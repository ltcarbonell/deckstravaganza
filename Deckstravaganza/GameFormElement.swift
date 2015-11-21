//
//  GameFormElement.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 11/16/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
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
    
    private func setUpLayout() {
        let fieldXPosition: CGFloat;
        
        if(formLabel != nil) {
            formLabel!.center = CGPoint(x: 0, y: CGRectGetMidY(self.frame));
            formLabel!.frame = CGRect(x: 0, y: 0, width: self.frame.width / 2, height: self.frame.height);
            
            fieldXPosition = CGRectGetMaxX(self.frame) - (formField.frame.width / 2);
            
            self.addSubview(formLabel!);
        } else {
            fieldXPosition = CGRectGetMidX(self.frame);
        }
        
        formField.center = CGPoint(x: fieldXPosition, y: CGRectGetMidY(self.frame));
        formField.frame = CGRect(x: 0, y: 0, width: self.frame.width / 2, height: self.frame.height);
        
        self.addSubview(formField);
    }
}