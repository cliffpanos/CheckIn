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
        
        switch (message["Activity"] as? String ?? "") {
        case "PassesReply":
            let data = message["Payload"] as! Data
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data)
            print("RECEIVED PASSES REPLY FROM REQUEST")
            WC.addPass(from: dictionary as! Dictionary<String, Any>)
        default: print("no message handled for key: \(message["Activity"] ?? "NILLL")")
        }
        print("Watch App did receive message")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        ExtensionDelegate.session?.sendMessage(["Activity" : "Session Activated"], replyHandler: nil, errorHandler: {
            error in print(error)
        })
        print("Activation complete")
        WC.getQRCodeImageUsingWC()
        WC.requestPassesFromiOS(forIndex: 0)
        
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Reachability state did change-----------")
        WC.getQRCodeImageUsingWC()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        for (key, value) in applicationContext {
            
            if key == "signInStatus" {
                print("DID RECEIVE APPLICATION CONTEXT ABOUT SIGN IN STATUS")
                WC.userIsLoggedIn = value as! Bool
                
            }
            
        }
    }
    
}
