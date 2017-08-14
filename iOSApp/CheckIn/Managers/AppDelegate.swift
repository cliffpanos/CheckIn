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

 How to save Date data to database? CHANGE XCDATAMODEL to DATE!
    And images? **********

 extra screen for admins with QR scanner
 hash the QR code for security.
 Create the time travel and complication update functionality for the watch
 multiple contacts
 action menu on ipads
 QR code encryption via hashing and identifier and current date?
 Scroll views?
 iPad optimization with action sheet so that it doesn't crash
 WATCH APP: Menu actions, settings updating, pass deletion, page becomeCurrentPage()
    Fix issue with signInController coming up twice when the user hasn't logged in before
    Perfect 3D Menu Items on each interface controller and add a refresh button to the Passes InterfaceController
 Implement handoff functionality between watch and iPhone
 Keep track of all user defaults stored so that they can be deleted upon logout
 WIDGET (Today View Extension)
 Watch app. Work on communication and core data things
 Write extension for screen class that manages brightness
 Create Swift package thingy (like a Pod? for some of the IB designables and functions)
 Login screen!!
	- Create account, login with Facebook, login with Google, Create Check-in Location
	- Double screen part: first screen is how to log in
	- Animate in and out
	- Show True Pass icon but with an alpha < 1

Find out why I can't rename my CheckIn directories to something else lol
Override hashCode for each guest pass

Implement some kind of subclass to UITableViewController that automatically manages the proportions of static table view cells
 
 Add system haptics for feedback
 
 Change tabBarController tabbar items when the device is in landscape orientation
 
 Handle SplitViewController things like when there are no passes and when the user deletes the pass of the current detail controller, auto-selecting the first row if it exists, etc.
 */







import UIKit
import CoreData
import WatchConnectivity
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        C.appDelegate = self
        WCActivator.set(&C.session, for: self)
        
        if let currentUser = Accounts.shared.current {
            FirebaseService(entity: .FTPUser).retrieveData(forIdentifier: currentUser.uid, completion: { user in
                Accounts.currentUser = (user as! FTPUser)
            })
        }
        Testing.setupForTesting()
        
        //LoginViewController
        if !C.userIsLoggedIn {
            self.window!.rootViewController = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
        } else {
            //Else go straight to the homescreen
            tabBarController = window?.rootViewController as! UITabBarController
            
            //Ensure that the user's geofence monitoring is correctly on or off for their locations according to the locations' preference
            GeofenceManager.validateGeofenceMonitoring()
        }
        
        
        //Set the Home Screen Quick Actions for when the app is first launched ever
        if UIApplication.shared.shortcutItems == nil { AppDelegate.setShortcutItems(loggedIn: false) }
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
            as? UIApplicationShortcutItem {
            AppDelegate.QuickActionTrackers.launchedShortcutItem = shortcutItem
        }
        
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
        
        if let shortcutItem = AppDelegate.QuickActionTrackers.launchedShortcutItem {
            let _ = handleQuickAction(for: shortcutItem)
        }
        
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
