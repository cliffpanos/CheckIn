//
//  ManagedInterfaceController.swift
//  CheckIn
//
//  Created by Cliff Panos on 5/2/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation


class ManagedInterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        WC.currentlyPresenting = self

    }
    
    override func didAppear() {
        
        if let current = WC.currentlyPresenting, current is SignInController { return }
        
        if let loggedIn = Shared.defaults.value(forKey: "userIsLoggedIn") as? Bool, loggedIn {
            print("Logged in status considered")

            if let signInController = WC.currentlyPresenting as? SignInController {
                signInController.dismiss()
            }
        } else if !(WC.currentlyPresenting is SignInController) {
            self.presentController(withName: "signInRequiredController", context: nil)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}


class SignInController: ManagedInterfaceController {
    
    @IBOutlet var checkInIcon: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        checkInIcon.setImage(#imageLiteral(resourceName: "clearIcon"))
        checkInIcon.setTintColor(UIColor.white)
    }
}
