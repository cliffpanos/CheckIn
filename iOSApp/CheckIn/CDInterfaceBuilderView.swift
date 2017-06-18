//
//  CDInterfaceBuilderView.swift
//  Generic
//
//  Created by Cliff Panos on 6/7/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class CDInterfaceBuilderView: UIView {

    var contentView: UIView!

    //MARK: - XIB IMPLEMENTATION STACK -------------- :
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        XIBSetup()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        XIBSetup()
    }
    
    fileprivate func XIBSetup() {
        contentView = loadViewFromNib()
        
        // Use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // Make the view stretch with containing view
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView)
        self.layer.setNeedsDisplay()
        self.layer.displayIfNeeded()
    }
    
    fileprivate func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    //Overridden because prepareForInterfaceBuilder requires that all subviews be layed out already
    internal override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        XIBSetup()
        contentView?.prepareForInterfaceBuilder()
    }

}
