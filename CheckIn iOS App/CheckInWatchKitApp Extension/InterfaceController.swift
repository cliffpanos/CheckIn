//
//  InterfaceController.swift
//  CheckInWatchKitApp Extension
//
//  Created by Cliff Panos on 4/15/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: ManagedInterfaceController {
    
    @IBOutlet var interfaceTable: WKInterfaceTable!
    static var staticTable: WKInterfaceTable?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        WC.initialViewController = self
        InterfaceController.staticTable = interfaceTable
        
    }
    
    static func updatetable() {
        guard let table = InterfaceController.staticTable else {
            return
        }
        
        print("Actually updating table")
        table.setNumberOfRows(WC.passes.count, withRowType: "passCell")
        for i in 0..<WC.passes.count {
            let cell = table.rowController(at: i) as! PassCell
            cell.decorate(for: WC.passes[i])
        }
        
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.presentController(withName: "passDetailController", context: WC.passes[rowIndex])
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        if WC.passes.count == 0 {
            print("Interface Controller awake is requesting passes")
            WC.requestPassesFromiOS(forIndex: 0) //Begins the recursive pass request calls
        }
        //InterfaceController.updatetable()

    }

    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}


//Mark: - Handle Notifications
extension InterfaceController {
    
    //override func handleAction
    
    
}

class PassCell: NSObject {
    
    @IBOutlet var imageView: WKInterfaceImage!
    @IBOutlet var guestName: WKInterfaceLabel!
    
    func decorate(for pass: Pass) {
        
        if let imageData = pass.image {
            let image = UIImage(data: imageData)
            self.imageView.setImage(image)
        } else {
            self.imageView.setImage(#imageLiteral(resourceName: "clearIcon"))
        }
        

        let components = pass.name.components(separatedBy: " ")
        if components.count > 0 {
            guestName.setText("\(components[0]) \(components[1][0]).")
        } else {
            guestName.setText(pass.name)
        }
    }
    
}
