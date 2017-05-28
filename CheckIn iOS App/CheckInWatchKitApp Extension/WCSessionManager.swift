//
//  WCSessionManager.swift
//  TruePassWatchKitApp Extension
//
//  Created by Cliff Panos on 4/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import WatchConnectivity

extension ExtensionDelegate {
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        switch (message[WCD.KEY] as! String) {

        default: print("no message handled for key: \(message[WCD.KEY] ?? "NILLL")")
        }
        print("Watch App did receive message")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        switch (userInfo[WCD.KEY] as! String) {
        
        case WCD.singleNewPass:
            let passData = userInfo[WCD.passPayload] as! Data
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: passData)
            print("RECEIVED SINGLE NEW PASS FROM REQUEST")
            WC.addPass(fromMessage: dictionary as! [String : Any])
        
        case WCD.deletePass:
            let passData = userInfo[WCD.passPayload] as! Data
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: passData)
            if let pass = WC.constructPass(forDictionaryData: dictionary as! [String : Any]),
                let removalIndex = WC.passes.index(of: pass) {
                
                WC.passes.remove(at: removalIndex)
                print("DELETING A PASS")
                InterfaceController.removeTableItem(atIndex: removalIndex)
            }
            
        default: break
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        for (key, value) in applicationContext {
            
            if key == WCD.signInStatus {
                print("DID RECEIVE APPLICATION CONTEXT ABOUT SIGN IN STATUS")
                WC.userIsLoggedIn = value as! Bool
                
            }
            
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        guard activationState == .activated else {
            print("Watch Session Activation ERROR: \(error?.localizedDescription ?? "No error")")
            WC.session?.activate()
            return
        }
        WC.session?.sendMessage([WCD.KEY : WCD.sessionActivated], replyHandler: nil, errorHandler: {
            error in print(error)
        })
        print("Activation complete on watchOS")
        WC.getQRCodeImageUsingWC()
        WC.requestPassesFromiOS()
        
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Reachability state did change-----------")
        
        if WC.session?.activationState != WCSessionActivationState.activated {
            WC.session?.activate()
        }
        WC.getQRCodeImageUsingWC()
    }

}
