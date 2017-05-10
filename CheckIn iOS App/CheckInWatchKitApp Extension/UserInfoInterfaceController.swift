//
//  UserInfoInterfaceController.swift
//  TruePassWatchKitApp Extension
//
//  Created by Cliff Panos on 5/4/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation


class UserInfoInterfaceController: ManagedInterfaceController {

    @IBOutlet var userProfileImage: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        userProfileImage.setImage(#imageLiteral(resourceName: "clearIcon"))
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
