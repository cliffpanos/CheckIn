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
            //for pass in C.passes {
            let pass = C.passes[0]
                guard let imageData = pass.image as Data? else {
                    return
                }
                guard let image = UIImage(data: imageData) else {
                    return
                }
                
                /*UIGraphicsBeginImageContext(image.size)
                let rect = CGRect(x: 0, y: 0, width: image.size.width * 0.05, height: image.size.height * 0.05)
                image.draw(in: rect)
                let img = UIGraphicsGetImageFromCurrentImageContext()
                _ = UIImageJPEGRepresentation(img!, 0.2)
                UIGraphicsEndImageContext()*/
                
                let dictionary = pass.dictionaryWithValues(forKeys: ["name", "email", "timeEnd", "timeStart"]) //TODO add "image" key
                
                //dictionary["image"] = imgData
                
                print("Should be sending pass message")
                let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
                replyHandler(["Activity" : "PassesReply", "Payload" : data])
            
        //}
        default: print("no message handled with key: \(message["Activity"] ?? "NILL")")
        }
        print("iOS App did receive message")
        
    }
    

}
