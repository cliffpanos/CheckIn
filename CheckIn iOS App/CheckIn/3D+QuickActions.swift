//
//  3D+QuickActions.swift
//  True Pass
//
//  Created by Cliff Panos on 4/29/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    
    // MARK: - Handle 3D-Touch Home Screen Quick Actions
    struct QuickActionTrackers {
        static var resetRoot: Bool = false
        static var launchedShortcutItem: UIApplicationShortcutItem?
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        //Handles the 3D Touch Quick Actions from the home screen
        
        completionHandler(handleQuickAction(for: shortcutItem))
        
    }
    
    func handleQuickAction(for shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var handled: Bool = false;
        
        guard C.userIsLoggedIn else {
            return handled
        }
        
        if (AppDelegate.QuickActionTrackers.resetRoot) {
            print("NEW ROOT")
            let newRootViewController = C.storyboard.instantiateInitialViewController()
            self.window?.rootViewController = newRootViewController
            self.tabBarController = newRootViewController as! UITabBarController
        }
        
        
        handled = true
        print("Dynamic Actions: \(String(describing: UIApplication.shared.shortcutItems))")
        print("Switching on: \(shortcutItem.type)")
        switch (shortcutItem.type) {
            
            
        case "showUserPass" :
            C.appDelegate.tabBarController.selectedIndex = 1
            CheckInPassViewController.initialScreenBrightness = UIScreen.main.brightness
            let controller = C.storyboard.instantiateViewController(withIdentifier: "checkInPassViewController")
            C.appDelegate.tabBarController.selectedViewController?.present(controller, animated: true, completion: nil)
            
        case "newGuestPass" :
            C.appDelegate.tabBarController.selectedIndex = 0
            let controller = C.storyboard.instantiateViewController(withIdentifier: "newPassViewController")
            C.appDelegate.tabBarController.selectedViewController?.present(controller, animated: true, completion: nil)
            
            
        case "checkInNow" :
            C.appDelegate.tabBarController.selectedIndex = 1
            
            let controller = C.storyboard.instantiateViewController(withIdentifier: "mapViewController")
            let nav = C.appDelegate.tabBarController.selectedViewController as! UINavigationController
            nav.pushViewController(controller, animated: false)
            
        default: break //should never be executed
        }
        
        return handled
    }
    
    
    //ADDITIONAL NECESSARY CODE IN MAIN APPDELEGATE CLASS:
    /*
     application(:didFinishLaunchingWithOptions:)
        //...
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
        as? UIApplicationShortcutItem {
        AppDelegate.QuickActionTrackers.launchedShortcutItem = shortcutItem
        //...
     }
     */
    /*
     applicationDidBecomeActive(:)
        //...
        guard let shortcutItem = AppDelegate.QuickActionTrackers.launchedShortcutItem else { return }
        //guard unwraps launchedShortcutItem and checks if it is not null
         
        let _ = handleQuickAction(for: shortcutItem)
        AppDelegate.QuickActionTrackers.launchedShortcutItem = nil
        AppDelegate.QuickActionTrackers.resetRoot = true
        //...
     */
    
    
}
