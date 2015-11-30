//
//  GenericSliderView.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 11/23/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class GenericSliderView: UISlider, GenericFormElements {
    let stepSize: Float;
    
    init(data: [String]) {
        let min = Float(data[0]);
        let max = Float(data[1]);
        let tempStepSize = Float(data[2]);
        
        if(data.count != 3 || min == nil || max == nil || tempStepSize == nil) {
            fatalError("3 and only 3 float values must be passed to the GenericSliderView");
        }
        
        stepSize = tempStepSize!;
        
        super.init(frame: CGRect());
        
        super.minimumValue = 0;
        super.maximumValue = max! / stepSize;
        
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
        sender.value = sender.value * stepSize;
    }
    
    func getResults() -> String {
        return String(super.value);
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
