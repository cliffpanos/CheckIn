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
    @IBOutlet var imageView: WKInterfaceImage!
    
    var pass: Pass?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let pass = context as? Pass else { return }
        self.pass = pass
        
        nameLabel.setText(pass.name)
        
        if let imageData = pass.image {
            let image = UIImage(data: imageData)
            self.imageView.setImage(image)
        } else {
            self.imageView.setImage(#imageLiteral(resourceName: "ModernContactEmpty"))
        }
        
        
        self.addMenuItem(with: .trash, title: "Revoke", action: #selector(requestDeletionOfPass))
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    func requestDeletionOfPass() {
        
        guard let pass = pass else { return }
        
        let dictionary: [String : Any] = ["name": pass.name, "email": pass.email, "timeStart": pass.timeStart, "timeEnd": pass.timeEnd]
        let passData = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        
        let deletePassRequest = [WCD.KEY: WCD.deletePass, WCD.passPayload: passData] as [String : Any]
        
        WC.session?.sendMessage(deletePassRequest, replyHandler: { message in
            
            guard message[WCD.passDeletionSuccessStatus] as? Bool == true else { return }
            
            if let removalIndex = WC.passes.index(of: self.pass!) {
                WC.passes.remove(at: removalIndex)
                print("DELETING A PASS")
                InterfaceController.removeTableItem(atIndex: removalIndex)
                self.dismiss()
            }
        }, errorHandler: {error in print(error)} )
    }

}
