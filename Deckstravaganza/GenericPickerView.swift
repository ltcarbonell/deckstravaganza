//
//  GenericPickerView.swift
//  Deckstravaganza
//
//  Created by Cory Armstrong on 11/18/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import UIKit

class GenericPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate, GenericFormElements {
    let data: [String];
    
    init(data: [String]) {
        self.data = data;
        
        super.init(frame: CGRect());
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getDefaultFrame() -> CGRect {
        return UIPickerView().frame;
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row];
    }
}
