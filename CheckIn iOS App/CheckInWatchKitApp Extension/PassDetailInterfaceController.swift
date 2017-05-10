//
//  PassDetailInterfaceController.swift
//  TruePassWatchKitApp Extension
//
//  Created by Cliff Panos on 4/18/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation


class PassDetailInterfaceController: ManagedInterfaceController {

    @IBOutlet var nameLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let pass = context as? Pass else { return }
        
        nameLabel.setText(pass.name)
        
        
        
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
