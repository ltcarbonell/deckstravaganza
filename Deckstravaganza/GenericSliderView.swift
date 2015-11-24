//
//  GenericSliderView.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 11/23/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class GenericSliderView: UISlider, GenericFormElements {
    init(data: [String]) {
        super.init(frame: CGRect());
        
        let min = Float(data[0]);
        let max = Float(data[1]);
        
        if(data.count != 2 || min == nil || max == nil) {
            fatalError("2 and only 2 values must be passed to the GenericSliderView");
        }
        
        super.minimumValue = min!;
        super.maximumValue = max!;
        
        super.continuous = true;
        super.addTarget(self, action: "updateSliderValue:", forControlEvents: UIControlEvents.ValueChanged);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getDefaultFrame() -> CGRect {
        return UISlider().frame;
    }
    
    func updateSliderValue(sender: UISlider) {
        sender.value = round(sender.value);
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
