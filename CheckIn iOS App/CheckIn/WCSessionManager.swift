//
//  WCSessionManager.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/29/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import WatchConnectivity

extension AppDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        print("Should be sending QR Image")
        let image = C.userQRCodePass(withSize: nil)
        let imageData = UIImagePNGRepresentation(image)!
        self.session!.sendMessage(["CheckInPass" : imageData], replyHandler: nil, errorHandler: nil)
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //code
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //code
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        switch (message["Activity"] as! String) {
        case "NeedCheckInPass" :
            let image = C.userQRCodePass(withSize: nil)
            let imageData = UIImagePNGRepresentation(image)!
            replyHandler(["Activity" : "CheckInPassReply", "CheckInPass" : imageData])
        case "MapRequest" :
            let coordinate = C.checkInLocations[0].coordinate
            replyHandler(["Activity" : "MapReply", "latitude" : coordinate.latitude, "longitude" :coordinate.longitude])
        case "PassesRequest" :
            
            guard C.passes.count > 0 else {
                replyHandler(["Activity" : "PassesReply", "Payload" : 0])
                return
            }
            
            var passIndex = message["PassIndex"] as! Int
            let pass = C.passes[passIndex]
                
            var dictionary = pass.dictionaryWithValues(forKeys: ["name", "email", "timeEnd", "timeStart"])
        
            if let imageData = pass.image as Data?, let image = UIImage(data: imageData) {
                
                UIGraphicsBeginImageContext(CGSize(width: 30.0, height: 30.0))
                image.draw(in: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let reducedData = UIImagePNGRepresentation(newImage!)
                print("Contact Image Message Size: \(reducedData?.count ?? 0)")
                
                dictionary["image"] = reducedData

            } else {
                
                let image = #imageLiteral(resourceName: "greenContactIcon")
                dictionary["image"] = UIImagePNGRepresentation(image)
            }
            
            print("Should be sending pass message")
            let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            let nextPassIndex = (passIndex + 1 < C.passes.count) ? passIndex + 1 : -1
            replyHandler(["Activity" : "PassesReply", "Payload" : data, "NextPassIndex" : nextPassIndex])
        
        //}
        default: print("no message handled with key: \(message["Activity"] ?? "NILL")")
        }
        print("iOS App did receive message")
        
    }
    

}
