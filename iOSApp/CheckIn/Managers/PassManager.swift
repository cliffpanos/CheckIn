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
    
    static func save(pass: TPPass?, firstName: String, lastName: String, andEmail email: String, andImage imageData: Data?, from startTime: Date, to endTime: Date) -> Bool {
        
        let managedContext = C.appDelegate.persistentContainer.viewContext
        
        let pass = pass ?? TPPass(context: managedContext)
        
        pass.firstName = firstName
        pass.lastName = lastName
        pass.email = email
        pass.startDate = C.format(date: startTime)
        pass.endDate = C.format(date: endTime)
        
        if let data = imageData, let image = UIImage(data: data) {
            print("OLD IMAGE SIZE: \(data.count)")
            let resizedImage = image.drawAspectFill(in: CGRect(x: 0, y: 0, width: 240, height: 240))
            let reducedData = UIImagePNGRepresentation(resizedImage)
            print("NEW IMAGE SIZE: \(reducedData!.count)")
            
            pass.imageData = data as NSData
        }
        
        defer {
            let passData = PassManager.preparedData(forPass: pass)
            let newPassInfo = [WCD.KEY: WCD.singleNewPass, WCD.passPayload: passData] as [String : Any]
            C.session?.transferUserInfo(newPassInfo)
        }
        
        return C.appDelegate.saveContext()
        
    }
    
    static func delete(pass: TPPass, andInformWatchKitApp sendMessage: Bool = true) -> Bool {
        
        let data = PassManager.preparedData(forPass: pass, includingImage: false)   //Do NOT include image
        
        let managedContext = C.appDelegate.persistentContainer.viewContext
        managedContext.delete(pass)
        
        defer {
            if sendMessage {
                let deletePassInfo = [WCD.KEY: WCD.deletePass, WCD.passPayload: data] as [String : Any]
                C.session?.transferUserInfo(deletePassInfo)
            }
        }
        
        if let vc = UIWindow.presented.viewController as? PassDetailViewController {
            vc.navigationController?.popViewController(animated: true)
        }
        
        return C.appDelegate.saveContext()
        
    }
    
    static func preparedData(forPass pass: TPPass, includingImage: Bool = true) -> Data {
        
        var dictionary = pass.dictionaryWithValues(forKeys: ["name", "email", "startDate", "endDate"])
        
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
