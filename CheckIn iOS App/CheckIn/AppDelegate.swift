//
//  AppDelegate.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//





/* Finish geofences and check-in notifications
 CloudKit + other kits
 other peek & commit interaction

 How to save Date data to database? And images? **********

 login screen for admins with QR scanner
 hash the QR code for security.
 Use an identifier with each pass which is the hash of the pass info
 Create the time travel and complication update functionality for the watch
 multiple contacts
 allow for multiple check-in locations
 action menu on ipads
 QR code encryption via hashing and identifier?
 Scroll views?
 iPad optimization with action sheet so that it doesn't crash
 WATCH APP: Menu actions, settings updating, pass deletion, page becomeCurrentPage()
    Fix issue with signInController coming up twice when the user hasn't logged in before
    Perfect 3D Menu Items on each interface controller and add a refresh button to the Passes InterfaceController
 Keep track of all user defaults stored so that they can be deleted upon logout
 WIDGET (Today View Extension)
 Add 3D Touch menu actions to watch app. Work on communication and core data things
 Write extension for screen class that manages brightness
 Change editableBound on Login screen textFields to move with the animation
 Create Swift package thingy (like a Pod? for some of the IB designables and functions)
 Login screen!!
	- Create account, login with Facebook, login with Google, Create Check-in Location
	- Double screen part: first screen is how to log in
	- Animate in and out
	- Show True Pass icon but with an alpha < 1
 Add UserInfo keys to the 3D touch Quick Actions that represent their version / build number - DONE

Find out why I can't rename my CheckIn directories to something else lol
Create the CILocation class and maybe rename this to TRULocation
Override hashCode for each guest pass
Give each pass a unique identifier using its hashCode, and override hashCode for the Pass class - perhaps put the hashCode function into another class and make both the Core Data Pass class and the WatchKit app's Pass class subclass this new class that has the hash function?

Implement a HashMap in swift and use it to store the passes based on their identifiers 
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
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        C.appDelegate = self
        WCActivator.set(&C.session, for: self)
        
        tabBarController = window?.rootViewController as! UITabBarController
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
            as? UIApplicationShortcutItem {
            AppDelegate.QuickActionTrackers.launchedShortcutItem = shortcutItem
        }
        
        
        //load pins
        let hackGSU = Pin(name: "HackGSU",latitude: 33.7563920891773, longitude: -84.3890242522629)
        let iOSClub = Pin(name: "iOS Club",latitude: 33.776732102728, longitude: -84.3958815877988)
        C.truePassLocations = [iOSClub, hackGSU]
        
        
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        UIScreen.appLeftPrimaryView() //Update brightness
        print("APP RESIGNED ACTIVE")

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UIScreen.appLeftPrimaryView() //Update brightness
        print("APP ENTERED BACKGROUND")
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
       
        UIScreen.appCameIntoView()
        print("APP ENTERED FOREGROUND+")
    
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        guard let shortcutItem = AppDelegate.QuickActionTrackers.launchedShortcutItem else { return }
        //guard unwraps launchedShortcutItem and checks if it is not null
        
        let _ = handleQuickAction(for: shortcutItem)
        AppDelegate.QuickActionTrackers.launchedShortcutItem = nil
        AppDelegate.QuickActionTrackers.resetRoot = true
        
        UIScreen.appCameIntoView()
        print("APP BECAME ACTIVE+")
    
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
        let container = NSPersistentContainer(name: "True Pass")
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
