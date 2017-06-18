//
//  Designables.swift
//  True Pass
//
//  Created by Cliff Panos on 4/4/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MapKit

class GradientView: UIView {
    
    var topColor: UIColor = UIColor.white {
        didSet {
            layoutGradient()
        }
    }
    //var midColor: UIColor = UIColor.gray
    var bottomColor: UIColor = UIColor.black {
        didSet {
            layoutGradient()
        }
    }
    
    override open class var layerClass: AnyClass {
        get{
            return CAGradientLayer.classForCoder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutGradient()
    }
    
    internal func layoutGradient() {
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
    
}

@IBDesignable
class CDButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        
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
    
}


@IBDesignable
class CDLabel: UILabel {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
}

@IBDesignable
class RoundedStackView: UIStackView {
    
}


@IBDesignable
class CDImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }

}


@IBDesignable
extension UIView {
    
    /*@IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
        }
    }*/
}


@IBDesignable
class RoundedView: UIView {
    
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
        
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        
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
    
}

@IBDesignable
class CircularView: RoundedView {
    
    override func layoutSubviews() { //Maintain circular roundness
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.cornerRadius = radius
    }
}

@IBDesignable
class RoundedMapView: MKMapView {
    
}

@IBDesignable
class ShadowView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //let radius: CGFloat = self.frame.width / 2.0 //change it to .height if you need spread for height
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        //Change 2.1 to amount of spread you need and for height replace the code for height
        
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)  //Here you control x and y
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5.0 //Here your control your blur
        self.layer.masksToBounds =  false
        self.layer.shadowPath = shadowPath.cgPath
    }
}
