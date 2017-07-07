//
//  ContactView.swift
//  True Pass
//
//  Created by Cliff Panos on 5/24/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

@IBDesignable
class ContactView: CDInterfaceBuilderView {

    @IBOutlet weak var contactInitialsLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var outerCircularView: CircularView!
    @IBOutlet weak var innerCircularView: CircularView!

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
     - Parameter forData: The optional image data to use to create the contact image
    */
    func setupContactView(forData imageData: Data?, andName name: String) {
        contactImageView.image = nil
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

        let components = name.components(separatedBy: " ")
        if components.count > 1 && !components[1].isEmptyOrWhitespace() {
            contactInitialsLabel.text = "\(components[0][0])\(components[1][0])"
        } else {
            contactInitialsLabel.text = name[0]
        }
        
        contactImageView.isHidden = true
        outerCircularView.borderColor = UIColor.TrueColors.trueBlue

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contactInitialsLabel.font = contactInitialsLabel.font.withSize(self.layer.bounds.width / 2.5)
    }

}
