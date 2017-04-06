//
//  C.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData
import QRCoder


class C {
    
    static var appDelegate: AppDelegate!
    static var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    static var passes: [Pass] {
        get {
            let managedContext = C.appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Pass> = Pass.fetchRequest()
            
            if let passes = try? managedContext.fetch(fetchRequest) {
                return passes
            }
            return [Pass]()
        }
        set (newPasses) {
            let managedContext = C.appDelegate.persistentContainer.viewContext
            if ((try? managedContext.save()) != nil) {
                self.passes = newPasses
            }
        }
    }
    
    
    
    
    
    static var nameOfUser: String = "Clifford Panos"
    static var emailOfUser: String = "cliffpanos@gmail.com"
    static var locationName: String = "HackGSU Spring 2017 Demo"
    
    
    static var passesActive: Bool = true
    
    static var automaticCheckIn: Bool = true

    
    
    

    
    
    
    static var user: LoggedIn!
    static var userIsLoggedIn: Bool { //TODO user NSUserDefaults.standard
        get {
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<LoggedIn> = LoggedIn.fetchRequest()
            
            let isLoggedIn = try? managedContext.fetch(fetchRequest)
            if let isLoggedIn = isLoggedIn {
                user = isLoggedIn[0]
                return user.isLoggedIn
            }
            return false
        
        }
        set {
            
            print("SETTING LOGGED IN: \(newValue ? "IN" : "OUT")\n")
            let managedContext = appDelegate.persistentContainer.viewContext
            user.isLoggedIn = newValue
            do {
                try managedContext.save()
            } catch _ as NSError {
                print("ERROR SAVING")
            }
        }
    
    }
    
    static func save(pass: Pass?, withName name: String, andEmail email: String, andImage imageData: Data?, from startTime: Date, to endTime: Date) -> Bool {
        
        let managedContext = C.appDelegate.persistentContainer.viewContext
        
        let pass = pass ?? Pass(context: managedContext)
        
        pass.name = name
        pass.email = email
        pass.timeStart = C.format(date: startTime)
        pass.timeEnd = C.format(date: endTime)
        
        if let data = imageData {
            pass.image = data as NSData
        }
        
        return (try? managedContext.save()) != nil
        
    }
    
    static func delete(pass: Pass) -> Bool {
        
        let managedContext = C.appDelegate.persistentContainer.viewContext
        managedContext.delete(pass)
        
        return (try? managedContext.save()) != nil
        
    }
    
    static func format(date: Date) -> String {
        
        let stringVersion = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
        
        return stringVersion
        
    }
    
    
    //MARK: - QR Code handling
    
    static func share(image: UIImage, in viewController: UIViewController) {
        
        let shareItems: [Any] = [image]
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        viewController.present(activityViewController, animated: true, completion: nil)
        
    }
    
    static func generateQRCode(forMessage message: String, withSize size: CGSize?) -> UIImage {
        
        let bounds = size ?? CGSize(width: 275, height: 275)
        let generator = QRCodeGenerator()
        let image: QRImage = generator.createImage(value: message, size: bounds)!
        return image as UIImage
    }
    
    
    
    //MARK: - AlertController helper methods
    
    static func showDestructiveAlert(withTitle title: String, andMessage message: String?, andDestructiveAction destructive: String, inView viewController: UIViewController, forCompletion completionHandler: @escaping (UIAlertAction) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            //C.result = false
        })
        let destructiveAction = UIAlertAction(title: destructive, style: .destructive, handler:
            completionHandler)
        
        alert.addAction(cancelAction)
        alert.addAction(destructiveAction)
        viewController.present(alert, animated: true, completion: nil)
    
    }
    
    
    static func persistUsingUserDefaults() {
        
        let defaults = UserDefaults.standard
        defaults.set("Saved value!", forKey: "keyString")
        defaults.synchronize()
    
    }
    
    static func getFromUserDefaults() -> String {
        
        let defaults = UserDefaults.standard
        if let string = defaults.object(forKey: "keyString") as? String {
            return string
        }
        
        return "failed"
    }
    
    
    
    
    
    
    
    
    
    
    
}
