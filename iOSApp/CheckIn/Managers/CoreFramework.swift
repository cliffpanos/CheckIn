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
    
    static var receiveCheckInNotifications: Bool {
        get {
            return getFromUserDefaults(withKey: Shared.RECEIEVE_CHECKIN_NOTIFICATIONS_SETTING) as? Bool ?? false
        }
        set {
            persistUsingUserDefaults(newValue, forKey: Shared.RECEIEVE_CHECKIN_NOTIFICATIONS_SETTING)
        }
    }
    
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
            locationsAndDistances[l1]! < locationsAndDistances[l2]!
        }
        return sortedLocations
    }

    static var passes: [TPPass] = [] /*{
        get {
            let managedContext = C.appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<TPPass> = TPPass.fetchRequest()
            
            if let passes = try? managedContext.fetch(fetchRequest) {
                return passes
            }

            return [TPPass]()
        }
    }*/
    
    
    
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
    
    static let stopNonKeywords = ["a", "about", "above", "above", "across", "after", "afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also","although","always","am","among", "amongst", "amoungst", "amount",  "an", "and", "another", "any","anyhow","anyone","anything","anyway", "anywhere", "are", "around", "as",  "at", "back","be","became", "because","become","becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom","but", "by", "call", "can", "cannot", "cant", "co", "con", "could", "couldnt", "cry", "de", "describe", "detail", "do", "done", "down", "due", "during", "each", "eg", "eight", "either", "eleven","else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except", "few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further", "get", "give", "go", "had", "has", "hasnt", "have", "he", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him", "himself", "his", "how", "however", "hundred", "ie", "if", "in", "inc", "indeed", "interest", "into", "is", "it", "its", "itself", "keep", "last", "latter", "latterly", "least", "less", "ltd", "made", "many", "may", "me", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much", "must", "my", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "no", "nobody", "none", "noone", "nor", "not", "nothing", "now", "nowhere", "of", "off", "often", "on", "once", "one", "only", "onto", "or", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own","part", "per", "perhaps", "please", "put", "rather", "re", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show", "side", "since", "sincere", "six", "sixty", "so", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system", "take", "ten", "than", "that", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon", "these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "to", "together", "too", "top", "toward", "towards", "twelve", "twenty", "two", "un", "under", "until", "up", "upon", "us", "very", "via", "was", "we", "well", "were", "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves", "the"]
    
}
