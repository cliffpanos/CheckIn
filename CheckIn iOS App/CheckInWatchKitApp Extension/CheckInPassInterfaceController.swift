//
//  CheckInPassInterfaceController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/16/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation


class CheckInPassInterfaceController: WKInterfaceController {

    @IBOutlet var imageView: WKInterfaceImage!
    @IBOutlet var panGestureRecognizer: WKPanGestureRecognizer!
    
    @IBOutlet var retrievingPassLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Done")
        WC.getQRCodeImageUsingWC()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        WC.currentlyPresenting = self
        
        self.imageView.setImage(WC.checkInPassImage)
        print("IMAGE SET")
        
        if WC.checkInPassImage != nil { retrievingPassLabel.setHidden(true)
        }

    }
        
    
    @IBAction func pannedDown(_ sender: Any) {
        if panGestureRecognizer.velocityInObject().y > 450 {
            self.dismiss()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
