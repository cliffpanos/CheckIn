//
//  LocationTypePicker.swift
//  True Pass
//
//  Created by Cliff Panos on 8/15/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class LocationTypePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var changeCallback: ((TPLocationType) -> Void)? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.dataSource = self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TPLocationType.enumerated.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TPLocationType.enumerated[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let locationType = TPLocationType.enumerated[row]
        if let callback = changeCallback {
            callback(locationType)
        }
    }

}
