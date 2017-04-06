//
//  Designables.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/4/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        
        didSet {
            self.layer.borderWidth = borderWidth
            self.layer.masksToBounds = true
        }
    
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var cornerRadius: Double = 0 {
        
        didSet {
            self.layer.cornerRadius = CGFloat(self.cornerRadius)
            self.layer.masksToBounds = true
        }
    }
    
}


@IBDesignable
class RoundedImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
}
