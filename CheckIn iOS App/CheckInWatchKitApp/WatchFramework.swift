//
//  WatchFramework.swift
//  TruePassWatchKitApp Extension
//
//  Created by Cliff Panos on 4/16/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import WatchConnectivity

class WC: NSObject {
    
    static var initialViewController: InterfaceController?
    static var currentlyPresenting: WKInterfaceController?
    static var ext: WKExtensionDelegate?
    
    static var session: WCSession? {
        return ExtensionDelegate.session
    }
    
    static var iPhoneIsAvailable: Bool {
        guard let theSession = WC.session else {
            return false
        }
        return theSession.isReachable && theSession.activationState == .activated
    }
    
    
    static var userIsLoggedIn: Bool {
        get {
            if let loggedIn = Shared.defaults.value(forKey: "userIsLoggedIn") as? Bool {
                return loggedIn
            }
            return false
        }
        set {
            print("WatchOS User is logging \(newValue ? "in" : "out")---------------")
            Shared.defaults.setValue(newValue, forKey: "userIsLoggedIn")
            Shared.defaults.synchronize()
            
            if !newValue { //If not logged in
                WC.currentlyPresenting?.presentController(withName: "signInRequiredController", context: nil)

            } else {
                debugPrint(WC.currentlyPresenting ?? "No currently presenting")
                WC.currentlyPresenting?.dismiss()

            }
        }

    }

    
    
    //MARK: - Handle the QR Code image logic
    static var checkInPassImage: UIImage? {
        
        didSet {
            if let presented = WC.currentlyPresenting as? CheckInPassInterfaceController {
                print("Currently presenting the CheckInPassVC")
                presented.imageView.setImage(checkInPassImage)
                presented.retrievingPassLabel.setHidden(true)
            }
        }
    }
    
    static func getQRCodeImageUsingWC() {
        
        guard WC.checkInPassImage == nil else {
            return
        }
        
        ExtensionDelegate.session?.sendMessage(["Activity" : "NeedCheckInPass"], replyHandler: {
            
            message in
        
            print("Did receive replyhandler for QRImage")
            guard let imageData = message["CheckInPass"] as? Data else {
                print("WATCH MESSAGE HANDLER for QR CODE FAIL")
                return
            }
            WC.checkInPassImage = UIImage(data: imageData)
            print("IMAGE SETTING SUCCESS")
        
        }, errorHandler: { error in print(error) })
    
    }
    
    
    //MARK: - Handle pass retrieval and storage
    static var passes = [Pass]()
    static func requestPassesFromiOS(forIndex index: Int) {
        ExtensionDelegate.session?.sendMessage(["Activity" : "PassesRequest", "PassIndex" : index], replyHandler: { message in
            guard let data = message["Payload"] as? Data else {
                return //Meaning no passes were receieved
            }
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data)
            print("RECEIVED PASS REPLY FROM REQUEST from WC.swift")
            WC.addPass(from: dictionary as! Dictionary<String, Any>)
            
            let nextPassIndex = message["NextPassIndex"] as! Int
            if (nextPassIndex) != -1 {
                WC.requestPassesFromiOS(forIndex: nextPassIndex)
            }
            InterfaceController.updatetable()


        }, errorHandler: {error in print(error); print("Pass request failed")})
    }
    static func addPass(from message: Dictionary<String, Any>) {
        let pass = Pass()
        pass.name = message["name"] as! String
        pass.email = message["email"] as! String?
        pass.image = message["image"] as? Data
        pass.timeStart = message["timeStart"] as! String
        pass.timeEnd = message["timeEnd"] as! String
        if !WC.passes.contains(pass) {
            WC.passes.append(pass)
            print("Pass added to Passes!")
        }
    }
    

}


class Pass: Equatable {
    var name: String!
    var email: String?
    var image: Data!
    var timeEnd: String!
    var timeStart: String!
    
    static func == (o1: Pass, o2: Pass) -> Bool {
        
        //TODO account for same times
        let condition = o1.name == o2.name && o1.email == o2.email && o1.image == o2.image
        return condition
    }
    
}
