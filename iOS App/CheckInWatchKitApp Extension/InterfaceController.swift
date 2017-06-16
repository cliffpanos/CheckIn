//
//  InterfaceController.swift
//  TruePassWatchKitApp Extensionn
//
//  Created by Cliff Panos on 4/15/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: ManagedInterfaceController {
    
    @IBOutlet var interfaceTable: WKInterfaceTable!
    @IBOutlet var noPassesLabel: WKInterfaceLabel!
    
    static var staticTable: WKInterfaceTable?
    static var staticNoPassesLabel: WKInterfaceLabel?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        WC.initialViewController = self
        InterfaceController.staticTable = interfaceTable
        InterfaceController.staticNoPassesLabel = noPassesLabel
        
        self.addMenuItem(with: .resume, title: "Refresh", action: #selector(refreshAllPasses))
        
    }
    
    static func updatetable() {
        guard let table = InterfaceController.staticTable else { return }
        
        print("Actually updating table")
        table.setNumberOfRows(WC.passes.count, withRowType: "passCell")
        for index in 0..<WC.passes.count {
            let cell = table.rowController(at: index) as! PassCell
            cell.decorate(for: WC.passes[index])
        }
        staticNoPassesLabel?.setHidden(table.numberOfRows > 0)
        
    }
    
    //By default will add the item to the bottom of the table
    static func addTableItem(atIndex index: Int = staticTable?.numberOfRows ?? 0) {
        
        guard let table = InterfaceController.staticTable else { return }
        
        let indexSet = IndexSet(integer: index)
        table.insertRows(at: indexSet, withRowType: "passCell")
        let cell = table.rowController(at: index) as! PassCell
        cell.decorate(for: WC.passes[index])
        
        staticNoPassesLabel?.setHidden(table.numberOfRows > 0)

    }
    
    static func removeTableItem(atIndex index: Int) {
        guard let table = InterfaceController.staticTable else { return }
        let indexSet = IndexSet(integer: index)
        if table.rowController(at: index) != nil {
            table.removeRows(at: indexSet)
        } //else the index is not valid
        
        staticNoPassesLabel?.setHidden(table.numberOfRows > 0)

    }
    
    func refreshAllPasses() {
        WC.passes = []    //Necessary?
        WC.requestPassesFromiOS()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.presentController(withName: "passDetailController", context: WC.passes[rowIndex])
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        if WC.passes.count == 0 {
            print("Interface Controller awake is requesting passes")
            noPassesLabel.setHidden(false)
            WC.requestPassesFromiOS() //Begins the recursive pass request calls
        } else {
            noPassesLabel.setHidden(true)
        }

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
        if components.count > 1 && !components[1].isEmptyOrWhitespace() {
            guestName.setText("\(components[0]) \(components[1][0]).")
        } else {
            guestName.setText(pass.name)
        }
    }
    
}
