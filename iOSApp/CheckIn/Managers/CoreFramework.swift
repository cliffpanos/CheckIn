//
//  CoreFramework.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import WatchConnectivity
import QRCoder


class C: WCActivator {
    
    static var appDelegate: AppDelegate!
    static var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    static var session: WCSession?
    
    static var passesActive: Bool = true
    
    static var automaticCheckIn: Bool = true
    
    static var truePassLocations: [TPLocation] = [] /*{
        get {
            let managedContext = C.appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<TPLocation> = TPLocation.fetchRequest()
            
            if let locations = try? managedContext.fetch(fetchRequest) {
                return locations
            }
            return [TPLocation]()
        }
    }*/
    
    static var nearestTruePassLocations: [TPLocation] {
        
        guard (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) && CLLocationManager.locationServicesEnabled() else { return truePassLocations }
        
        guard let userLocation = LocationManager.sharedLocationManager.location else { return truePassLocations }
        
        var locationsAndDistances = [TPLocation: Double]()
        for location in truePassLocations {
            let distance = userLocation.distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
            locationsAndDistances[location] = distance
        }
        
        let sortedLocations = truePassLocations.sorted { l1, l2 in
            locationsAndDistances[l1]! > locationsAndDistances[l2]!
        }
        return sortedLocations
    }

    static var passes: [Pass] {
        get {
            let managedContext = C.appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Pass> = Pass.fetchRequest()
            
            if let passes = try? managedContext.fetch(fetchRequest) {
                return passes
            }

            return [Pass]()
        }
    }
    
    
    
    static var userIsLoggedIn: Bool {
        get {
            if let loggedIn = Shared.defaults.value(forKey: "userIsLoggedIn") as? Bool {
                return loggedIn
            }
            return false
        }
        set {
            print("User is logging \(newValue ? "in" : "out")---------------")
            Shared.defaults.setValue(newValue, forKey: "userIsLoggedIn")
            Shared.defaults.synchronize()
            AppDelegate.setShortcutItems(loggedIn: newValue)
            try? C.session?.updateApplicationContext([WCD.signInStatus : newValue])
        }
    }

    
    static func format(date: Date) -> String {
        
        let stringVersion = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
        
        return stringVersion
        
    }
    
    
    //MARK: - QR Code handling
    
    static func share(image: UIImage, in viewController: UIViewController, popoverSetup: @escaping (UIPopoverPresentationController) -> Void) {
        
        let shareItems: [Any] = [image]
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        activityViewController.setValue("True Pass", forKey: "Subject")
        
        viewController.setupPopoverPresentation(for: activityViewController, popoverSetup: popoverSetup)
        
        viewController.present(activityViewController, animated: true, completion: nil)
        
    }
    
    static func userQRCodePass(forLocation location: TPLocation, withSize size: CGSize?) -> UIImage {
        return C.generateQRCode(forMessage:
            "\(Accounts.userName)|" +
            "\(Accounts.userEmail)|" +
            "\(location.title ?? "Location?")|"
            //Add in things specific to the location
            , withSize: size)
    }
    
    internal static func generateQRCode(forMessage message: String, withSize size: CGSize?) -> UIImage {
        
        let bounds = size ?? CGSize(width: 275, height: 275)
        let generator = QRCodeGenerator()
        let image: QRImage = generator.createImage(value: message, size: bounds)!
        return image as UIImage
    }
    
    
    
    static func persistUsingUserDefaults(_ value: Any?, forKey keyString: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: keyString)
        defaults.synchronize()
    }
    
    static func getFromUserDefaults(withKey keyString: String) -> Any? {
        return UserDefaults.standard.object(forKey: keyString)
    }
    
    static func removeValueFromUserDefaults(withKey keyString: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: keyString)
        defaults.synchronize()
    }
    
}
