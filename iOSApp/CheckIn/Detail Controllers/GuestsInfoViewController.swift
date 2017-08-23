//
//  GuestsInfoViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 8/14/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class GuestsInfoViewController: ManagedViewController {

    @IBOutlet weak var infoMessage: UILabel!
    @IBOutlet weak var createButton: CDButton!

    let canCreateMessage = "Guest passes temporarily allow family, friends, and clients to quickly enter your location using a QR code."
    let needsAffiliationMessage = "Before creating guest passes for a location, you must first affiliate with a location or create one of your own. See the Locations tab."
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let canCreate = !C.truePassLocations.isEmpty
        createButton.isEnabled = canCreate
        infoMessage.text = canCreate ? canCreateMessage : needsAffiliationMessage
    
    }

    
    func switchToSplitVC() {
        (self.tabBarController! as! RootViewController).switchToGuestRootController(withIdentifier: "splitViewController")
    }

}
