//
//  GenericSliderView.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 11/23/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class GenericSliderView: UISlider, GenericFormElements {
    let textWidth: CGFloat = 50;
    let textHeight: CGFloat = 50;
    
    let max: Float;
    let min: Float;
    let stepSize: Float;
    
    var actualValue: Int;
    
    let valueLabel = UILabel();
    
    init(data: [String]) {
        let min = Float(data[0]);
        let max = Float(data[1]);
        let tempStepSize = Float(data[2]);
        
        if(data.count != 3 || min == nil || max == nil || tempStepSize == nil) {
            fatalError("3 and only 3 float values must be passed to the GenericSliderView");
        }
        
        self.stepSize = tempStepSize!;
        self.max = max!;
        self.min = min!;
        
        actualValue = Int(max!)/2;
        
        super.init(frame: CGRect());
        
        super.minimumValue = 0;
        super.maximumValue = (max!-min!)/stepSize;
        self.value = (max!-min!)/(2*stepSize)
        
        valueLabel.text = String(actualValue);
        valueLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50);
        
        let defaultFrame = UISlider().frame;
        valueLabel.center = CGPoint(x: defaultFrame.width + (textWidth / 2), y: 15);
        
        self.addSubview(valueLabel);
        
        super.isContinuous = true;
        super.addTarget(self, action: #selector(GenericSliderView.updateSliderValue(_:)), for: UIControlEvents.valueChanged);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getDefaultFrame() -> CGRect {
        return UISlider().frame;
    }
    
    func updateSliderValue(_ sender: UISlider) {
        actualValue = Int((super.value + min) * stepSize);
        valueLabel.text = String(actualValue);
    }
    
    func getResults() -> String {
        return String((super.value + min) * stepSize);
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
