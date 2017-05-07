//
//  AppDelegate.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//





/* Finish geofences and CheckIn notifications
 CloudKit + other kits
 Fix 3D Touch quick actions
 other peek & commit interaction
 login screen for admins with QR scanner
 hash?
 multiple contacts
 allow for multiple checkin locations
 action menu on ipads
 QR code encryption via hashing?
 Make map zoom to checkin location, not user location
 Scroll views?
 iPad optimization with action sheet so that it doesn't crash
 WATCH APP!!
 WIDGET
 implement search bar functionality & FIX IT since it currently selects the wrong option
 Add 3D Touch menu actions to watch app. Work on communication and core data things
 Write extension for screen class that manages brightness
 Change editableBound on Login screen textFields to move with the animation
 Organize code into the Managers and file structure
 Create Swift package thingy (like a Pod? for some of the IB designables and functions)
 Login screen!!
	- Create account, login with Facebook, login with Google, Create CheckIn Location
	- Double screen part: first screen is how to log in
	- Animate in and out
	- Show checkin icon but with an alpha < 1
 */







import UIKit
import CoreData
import WatchConnectivity
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIPopoverPresentationControllerDelegate, WCSessionDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController!
    var session: WCSession? {
        return C.session
    }
    
    //3D-Touch Quick Action variables
    var resetRoot: Bool = false
    var launchedShortcutItem: UIApplicationShortcutItem?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        C.appDelegate = self
    
        
        if WCSession.isSupported() {
            C.session = WCSession.default()
            C.session?.delegate = self
            
            C.session?.activate()
            
            print("session \(String(describing: C.session)) activated on iPhone")
            
        }
        
        tabBarController = window?.rootViewController as! UITabBarController
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
            as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
        }
        
        
        //load pins
        let hackGSU = Pin(name: "HackGSU",latitude: 33.7563920891773, longitude: -84.3890242522629)
        let iOSClub = Pin(name: "iOS Club",latitude: 33.776732102728, longitude: -84.3958815877988)
        C.checkInLocations = [iOSClub, hackGSU]
        
        
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        CheckInPassViewController.targetBrightness = CheckInPassViewController.initialScreenBrightness
        CheckInPassViewController.updateScreenBrightness()

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        CheckInPassViewController.targetBrightness = CheckInPassViewController.initialScreenBrightness
        CheckInPassViewController.updateScreenBrightness()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
       
        if CheckInPassViewController.presented {
            CheckInPassViewController.targetBrightness = 1.0
            CheckInPassViewController.updateScreenBrightness()
        }
    
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        guard let shortcutItem = launchedShortcutItem else { return }
        //guard unwraps launchedShortcutItem and checks if it is not null
        
        let _ = handleQuickAction(for: shortcutItem)
        launchedShortcutItem = nil
        self.resetRoot = true
        
        if CheckInPassViewController.presented {
            CheckInPassViewController.targetBrightness = 1.0
            CheckInPassViewController.updateScreenBrightness()
        }
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        let _ = self.saveContext()
    }
    
    
    
    
    
    
    
       
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CheckIn")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                print("FATAL ERROR when loading PersistentStores from Core Data")
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support

    func saveContext() -> Bool {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                
            } catch {
                
                // Replace this implementation with code to handle the error appropriately.
                
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                
                return false //Save unsuccessful
            }
        }
        
        return true //Save was successful
    
    }

}
