//
//  GenericSwitchView.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 11/23/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class GenericSwitchView: UISwitch, GenericFormElements {
    func getDefaultFrame() -> CGRect {
        return UISwitch().frame;
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
