//
//  WCSessionManager.swift
//  True Pass
//
//  Created by Cliff Panos on 4/29/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import WatchConnectivity

extension AppDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //code
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //code
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        switch (message[WCD.KEY] as! String) {
        
        case WCD.checkInPassRequest :
            let image = C.userQRCodePass(withSize: nil)
            let imageData = UIImagePNGRepresentation(image)!
            replyHandler([WCD.KEY : WCD.checkInPassRequest, WCD.checkInPassRequest : imageData])
        
        case WCD.mapLocationsRequest :
            let coordinate = C.truePassLocations[0].coordinate
            replyHandler([WCD.KEY : WCD.mapLocationsRequest, "latitude" : coordinate.latitude, "longitude" :coordinate.longitude])
        
        case WCD.allPassesRequest :
            
            guard C.passes.count > 0 else {
                replyHandler([WCD.KEY : WCD.allPassesRequest, WCD.passPayload : 0])
                return
            }
            
            let passIndex = message[WCD.nextPassIndex] as! Int
            let pass = C.passes[passIndex]
            let data = C.preparedData(forPass: pass, includingImage: true)

            print("Should be sending pass message")
            let nextPassIndex = (passIndex + 1 < C.passes.count) ? passIndex + 1 : -1
            replyHandler([WCD.KEY : WCD.allPassesRequest, WCD.passPayload : data, WCD.nextPassIndex : nextPassIndex])
        
        case WCD.sessionActivated:
            print("watchOS WCSession did successfully activate")
        
        default: print("no message handled with key: \(message[WCD.KEY] ?? "NILL")")
        }
        print("iOS App did receive message")
        
    }
    

}
