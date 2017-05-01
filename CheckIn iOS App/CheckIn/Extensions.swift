//
//  Extensions.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/24/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func color(fromHex rgbValue: UInt32) ->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
        let blue = CGFloat(rgbValue & 0xFF)/255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}


extension UIScreen {
    
    //TODO deal with brightness

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
