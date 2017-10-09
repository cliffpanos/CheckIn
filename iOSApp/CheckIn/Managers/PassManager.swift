//
//  PassManager.swift
//  True Pass
//
//  Created by Cliff Panos on 8/6/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData

class PassManager {
    
    
    //MARK: - Handle Guest Pass Functionality with Core Data
    
    static func save(pass: TPPass?, firstName: String, lastName: String, andEmail email: String, andImage imageData: Data?, from startTime: Date, to endTime: Date, forLocation locationID: String) -> TPPass {
        
        let managedContext = C.appDelegate.persistentContainer.viewContext
        
        let pass = pass ?? TPPass(.TPPass)
        
        pass.firstName = firstName
        pass.lastName = lastName
        pass.email = email
        pass.startDate = startTime
        pass.endDate = endTime
        pass.accessCodeQR = "\(Date().addingTimeInterval(TimeInterval(arc4random())).timeIntervalSince1970)"
        pass.isActive = true
        pass.didCheckIn = false
        pass.locationIdentifier = locationID
        pass.phoneNumber = ""
        
        if let data = imageData, let image = UIImage(data: data) {
            print("OLD IMAGE SIZE: \(data.count)")
            let resizedImage = image.drawAspectFill(in: CGRect(x: 0, y: 0, width: 240, height: 240))
            let reducedData = UIImagePNGRepresentation(resizedImage)
            print("NEW IMAGE SIZE: \(reducedData!.count)")
            
            pass.imageData = data
        }
        
        let passService = FirebaseService(entity: .TPPass)
        let identifier = passService.newIdentifierKey
        passService.enterData(forIdentifier: identifier, data: pass)
        passService.addChildData(forIdentifier: identifier, key: "startDate", value: pass.startDate!.timeIntervalSince1970)
        passService.addChildData(forIdentifier: identifier, key: "endDate", value: pass.endDate!.timeIntervalSince1970)

        let passListService = FirebaseService(entity: .TPPassList)
        passListService.addChildData(forIdentifier: Accounts.userIdentifier, key: identifier, value: locationID)
        passListService.addChildData(forIdentifier: locationID, key: identifier, value: Accounts.userIdentifier)
        //passListService.reference.child(Accounts.userIdentifier).setValue(locationID)
        //passListService.reference.child(locationID).setValue(Accounts.userIdentifier)
        
        guard let data = pass.imageData as Data? else { return pass }
        FirebaseStorage.shared.uploadImage(data: data, for: .TPPass, withIdentifier: identifier) { metadata, error in
            if let error = error { print("Error uploading pass image!!") }
        }
        
        
        defer {
            let passData = PassManager.preparedData(forPass: pass)
            let newPassInfo = [WCD.KEY: WCD.singleNewPass, WCD.passPayload: passData] as [String : Any]
            C.session?.transferUserInfo(newPassInfo)
        }
        
        return pass
        
    }
    
    static func delete(pass: TPPass, andInformWatchKitApp sendMessage: Bool = true) -> Bool {
        
        //DELETE PASS FROM FIREBASE
        let passListService = FirebaseService(entity: .TPPassList)
        
        //Remove from TPPassList/locationIdentifier/passIdentifier
        passListService.reference.child(pass.locationIdentifier!).child(pass.identifier!).removeValue()
        //Remove from TPPassList/userIdentifier/passIdentifier
        passListService.reference.child(Accounts.userIdentifier).child(pass.identifier!).removeValue()
        
        let passService = FirebaseService(entity: .TPPass)
        passService.reference.child(pass.identifier!).removeValue()
        
        FirebaseStorage.shared.deleteImage(forEntity: .TPPass, withIdentifier: pass.identifier!)
        
        let data = PassManager.preparedData(forPass: pass, includingImage: false)   //Do NOT include image
        defer {
            if sendMessage {
                let deletePassInfo = [WCD.KEY: WCD.deletePass, WCD.passPayload: data] as [String : Any]
                C.session?.transferUserInfo(deletePassInfo)
            }
        }
        
        if let vc = UIWindow.presented.viewController as? PassDetailViewController {
            vc.navigationController?.popViewController(animated: true)
        }
        
        return true
        
    }
    
    static func preparedData(forPass pass: TPPass, includingImage: Bool = true) -> Data {
        
        var dictionary = pass.dictionaryWithValues(forKeys: ["name", "email", "startDate", "endDate", "didCheckIn"])
        
        if includingImage, let imageData = pass.imageData as Data?, let image = UIImage(data: imageData) {
            
            let res = 60.0
            let resizedImage = image.drawAspectFill(in: CGRect(x: 0, y: 0, width: res, height: res))
            let reducedData = UIImagePNGRepresentation(resizedImage)
            
            print("Contact Image Message Size: \(reducedData?.count ?? 0)")
            dictionary["image"] = reducedData
            
        } else {
            dictionary["image"] = nil
        }
        
        return NSKeyedArchiver.archivedData(withRootObject: dictionary)   //Binary data
        
    }
    
}
