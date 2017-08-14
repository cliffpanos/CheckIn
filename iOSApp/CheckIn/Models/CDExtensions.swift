//
//  CDExtensions.swift
//  True Pass
//
//  Created by Cliff Panos on 6/16/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    struct HairlineView {
        static var hairline: UIImageView? = nil
    }
    
    var hairlineImageView: UIImageView? {
        get {
            if let line = HairlineView.hairline {
                return line
            } else {
                HairlineView.hairline = findShadowImage(under: self)
                return HairlineView.hairline
            }
        }
        set {
            HairlineView.hairline = newValue
        }
    }
    
    var hairlineisHidden: Bool {
        get {
            return hairlineImageView?.isHidden ?? false
        }
        set {
            hairlineImageView?.isHidden = newValue
        }
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
}


extension UIView {
    
    func shadowed() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 7
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.8
    }
}
