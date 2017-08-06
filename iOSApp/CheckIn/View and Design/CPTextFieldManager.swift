//
//  CPTextFieldManager.swift
//  True Pass
//
//  Created by Cliff Panos on 6/28/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class CPTextFieldManager {
    
    var textFields: [UITextField]!
    
    init() {
        //Once initialized, the CPTextFieldManager instance should be retained as a property in the UIViewController class that holds the UITextFields.
    }
    
    func setup(textFields: [UITextField], accessoryViewStyle style: CPTextFieldManagerAccessoryViewStyle, dismissor: Selector) {
        
        for textField in textFields {
            let numberToolbar: UIToolbar = UIToolbar()
            numberToolbar.barStyle = UIBarStyle.default
            
            let textInputAccessories = [ UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
                                         UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self,
//                                                         action: #selector(dismissKeyboard))
                                            action: dismissor)
            ]
            
            numberToolbar.items = textInputAccessories
            numberToolbar.sizeToFit()
            textField.inputAccessoryView = numberToolbar
            
        } //End for loop for setting up the "Done" toolbars
        
    }
    
    func goToFirst() {
        
    }
    
    func goToLast() {
        
    }
    
    func dismiss() {
        
    }

}

enum CPTextFieldManagerAccessoryViewStyle {

    case done
    case upDownArrows
    case doneAndArrows
    
}
