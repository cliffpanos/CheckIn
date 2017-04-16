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
 fix default contact image size
 allow for multiple checkin locations
 gesture recognizer speed
 action menu on ipads
 QR code encryption via hashing?
 Make map zoom to checkin location, not user location
 Grey font for tableView emails
 Scroll views?
 iPad optimization with action sheet
 WATCH APP
 WIDGET
 */








import UIKit
import CoreData
//import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIPopoverPresentationControllerDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController!
    var launchedShortcutItem: UIApplicationShortcutItem?
    var viewControllerStack: [UIViewController] = []


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        C.appDelegate = self
        
        tabBarController = window?.rootViewController as! UITabBarController
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
            as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
        }
        
        //FIRApp.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        //Handles the 3D Touch Quick Actions from the home screen
        let handledShortcutItem: Bool = handleQuickAction(for: shortcutItem)
        completionHandler(handledShortcutItem)
        
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        guard let shortcutItem = launchedShortcutItem else { return }
        //guard unwraps launchedShortcutItem and checks if it is not null
        
        let _ = handleQuickAction(for: shortcutItem)
        launchedShortcutItem = nil
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    // MARK: - Handle 3D-Touch Home Screen Quick Actions

    func handleQuickAction(for shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var handled: Bool = false;
        
        guard C.userIsLoggedIn else {
            return handled
        }
        
        /*let newRootViewController = C.storyboard.instantiateViewController(withIdentifier: "tabBarController")
        self.window?.rootViewController = newRootViewController
        self.tabBarController = newRootViewController as! UITabBarController*/
        
        var current = window?.visibleViewController
        
        print(current ?? "NO CURRENT VIEW CONTROLLER")
        //var cont: Bool = true
        
        print("Navigation: \(current is UINavigationController)")
        var identifier = current?.navigationController?.restorationIdentifier
        print(identifier == "primaryNavigationController" || identifier == "secondaryNavigationController")
        
        while (identifier != "primaryNavigationController" && identifier != "secondaryNavigationController") {
            
            print(current!)
                if let navController = current?.navigationController {
                    navController.popToRootViewController(animated: false)
                    current!.dismiss(animated: false, completion: nil)

                } else {
                    current!.dismiss(animated: false, completion: nil)
                }

            current = window?.visibleViewController
            identifier = current?.navigationController?.restorationIdentifier
            print(identifier ?? "NO IDENTIFIER")
        }
        
        
        handled = true
        
        switch (shortcutItem.type) {
        
        case "showUserPass" :
            C.appDelegate.tabBarController.selectedIndex = 1
            let controller = C.storyboard.instantiateViewController(withIdentifier: "checkInPassViewController")
            C.appDelegate.tabBarController.present(controller, animated: true, completion: nil)

        case "newGuestPass" :
            C.appDelegate.tabBarController.selectedIndex = 0
            let controller = C.storyboard.instantiateViewController(withIdentifier: "newPassViewController")
            C.appDelegate.tabBarController.present(controller, animated: true, completion: nil)

        
        case "checkInNow" :
            C.appDelegate.tabBarController.selectedIndex = 1
            let controller = C.storyboard.instantiateViewController(withIdentifier: "mapViewController")
            C.appDelegate.tabBarController.selectedViewController?.navigationController?.pushViewController(controller, animated: true)
        
        default: break //will never be executed
        }
        
        return handled
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

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}



public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
