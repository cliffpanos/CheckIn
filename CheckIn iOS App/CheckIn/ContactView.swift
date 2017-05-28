//
//  ContactView.swift
//  True Pass
//
//  Created by Cliff Panos on 5/24/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

@IBDesignable
class ContactView: UIView {

    @IBOutlet weak var contactInitialsLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var outerCircularView: CircularView!
    
    var contentView : UIView!
    
    @IBInspectable var contactImage: UIImage? {
        didSet {
            let imageData = contactImage != nil ? UIImagePNGRepresentation(contactImage!) : nil
            setupContactView(forData: imageData, andName: "C N")
            self.contactImageView.layer.masksToBounds = true
        }
    }
    
    /**
     Always call this function to setup the ContactView
     - Parameter name: A full first and last name separated by a space
    */
    func setupContactView(forData imageData: Data?, andName name: String) {
        if let imageData = imageData {
            let image = UIImage(data: imageData as Data)
            
            contactImageView.image = image
            contactImageView.isHidden = false
            outerCircularView.borderColor = UIColor.clear
            return
        }
        removeImageViewAndSetInitials(forName: name)
    }
    
    ///Call this function when there is no available contact image to be used so the initials of a contact name will be used instead
    func removeImageViewAndSetInitials(forName name: String) {
        print("NO IMAGE NEW NAME: \(name)")
        let components = name.components(separatedBy: " ")
        if components.count > 1 && !components[1].isEmptyOrWhitespace() {
            contactInitialsLabel.text = "\(components[0][0])\(components[1][0])"
        } else {
            contactInitialsLabel.text = name[0]
        }
        
        contactImageView.isHidden = true
        outerCircularView.borderColor = UIColor.TrueColors.lightBlue

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contactInitialsLabel.font = contactInitialsLabel.font.withSize(self.layer.bounds.width / 2.5)
    }
    
    
    
    //MARK: - XIB IMPLEMENTATION STACK -------------- :
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // Make the view stretch with containing view
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView)
        self.layer.setNeedsDisplay()
        self.layer.displayIfNeeded()
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    //Overridden because prepareForInterfaceBuilder requires that all subviews be layed out already
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }

}
