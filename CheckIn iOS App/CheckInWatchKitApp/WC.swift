//
//  WC.swift
//  CheckIn
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
    
    
    //MARK: - Handle the QR Code image logic
    static var checkInPassImage: UIImage?
    
    static func getQRCodeImageUsingWC() {
        
        guard WC.checkInPassImage == nil else {
            return
        }
        
        ExtensionDelegate.session?.sendMessage(["Activity" : "NeedCheckInPass"], replyHandler: { message in
        
            print("Did receive replyhandler for QRImage")
            guard let imageData = message["CheckInPass"] as? Data else {
                print("WATCH MESSAGE HANDLER for QR CODE FAIL")
                return
            }
            WC.checkInPassImage = UIImage(data: imageData)
            print("IMAGE SETTING SUCCESS")
        
        }, errorHandler: { error in print(error) })
    
    }

    
    
    
    //MARK: - Sign In Alert View Navigation
    
    static func switchToSignInScreen() {
        if !(WC.currentlyPresenting is InterfaceController) {
            WC.currentlyPresenting?.popToRootController()
            WC.initialViewController?.presentController(withName: "signInNecessaryController", context: nil)
        }
    }
    
    static func switchUserNowLoggedIn() {
        WC.currentlyPresenting?.popToRootController()
    }

}
