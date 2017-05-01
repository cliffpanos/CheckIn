//
//  AppFramework.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity
import QRCoder


class C {
    
    static var appDelegate: AppDelegate!
    static var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    static var session: WCSession?
    
    
    static var nameOfUser: String = "Clifford Panos"
    static var emailOfUser: String = "cliffpanos@gmail.com"
    static var locationName: String = "iOS Club 2017 Demo Day"
    
    
    static var passesActive: Bool = true
    
    static var automaticCheckIn: Bool = true
    
    static var checkInLocations = [Pin]()

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
    
    
    
    static var userIsLoggedIn: Bool {
        get {
            if let loggedIn = UserDefaults.standard.value(forKey: "userIsLoggedIn") as? Bool {
                return loggedIn
            }
            return false
        }
        set {
            print("User is logging \(newValue ? "in" : "out")---------------")
            UserDefaults.standard.setValue(newValue, forKey: "userIsLoggedIn")
            try! C.session?.updateApplicationContext(["signInStatus" : newValue])
        }
    }

    
    
    //MARK: - Handle Guest Pass Functionality with Core Data
    
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
    
    static func userQRCodePass(withSize size: CGSize?) -> UIImage {
        return C.generateQRCode(forMessage:
            "\(C.nameOfUser)|" +
            "\(C.emailOfUser)|" +
            "\(C.locationName)"
            , withSize: size)
    }
    
    static func generateQRCode(forMessage message: String, withSize size: CGSize?) -> UIImage {
        
        let bounds = size ?? CGSize(width: 275, height: 275)
        let generator = QRCodeGenerator()
        let image: QRImage = generator.createImage(value: message, size: bounds)!
        return image as UIImage
    }
    
    
    
    //MARK: - AlertController helper methods
    
    static func showDestructiveAlert(withTitle title: String, andMessage message: String?, andDestructiveAction destructive: String, inView viewController: UIViewController, withStyle style: UIAlertControllerStyle, forDestruction completionHandler: @escaping (UIAlertAction) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let destructiveAction = UIAlertAction(title: destructive, style: .destructive, handler:
            completionHandler)
        
        alert.addAction(cancelAction)
        alert.addAction(destructiveAction)
        
        //TODO: Handle iPad presentation style
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = viewController.view
            presenter.sourceRect = viewController.view.bounds
        }
        viewController.present(alert, animated: true, completion: nil)
    
    }
    
    
    static func persistUsingUserDefaults(_ value: Any?, for keyString: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: keyString)
        defaults.synchronize()
    
    }
    
    static func getFromUserDefaults(withKey keyString: String) -> Any? {
        
        let defaults = UserDefaults.standard
        if let value = defaults.object(forKey: keyString) {
            return value
        }
        
        return nil
    }
    
    
    
    
    
    
    
    
    
    
    
}
