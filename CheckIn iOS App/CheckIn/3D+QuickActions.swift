//
//  3D+QuickActions.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/29/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    
    // MARK: - Handle 3D-Touch Home Screen Quick Actions
    
    
    func handleQuickAction(for shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var handled: Bool = false;
        
        guard C.userIsLoggedIn else {
            return handled
        }
        
        if (changeRoot) {
            print("NEW ROOT")
            let newRootViewController = C.storyboard.instantiateInitialViewController()
            self.window?.rootViewController = newRootViewController
            self.tabBarController = newRootViewController as! UITabBarController
        }
        
        
        handled = true
        
        print("Switching on: \(shortcutItem.type)")
        switch (shortcutItem.type) {
            
            
        case "showUserPass" :
            C.appDelegate.tabBarController.selectedIndex = 1
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
    
    
    
    
    
}
