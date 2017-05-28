//
//  Extensions.swift
//  True Pass
//
//  Created by Cliff Panos on 4/24/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

//An extension for the String class exists in CommonPlatform.swift

extension UIColor {
    
    static func color(fromHex hex: UInt32) ->UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16)/255.0
        let green = CGFloat((hex & 0xFF00) >> 8)/255.0
        let blue = CGFloat(hex & 0xFF)/255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    enum TrueColors {
        static let softRed = UIColor.color(fromHex: 0xFF0033)
        static let blue = UIColor.color(fromHex: 0x0066FF)
        static let lightBlue = UIColor.color(fromHex: 0x0191FF)
        static let green = UIColor.color(fromHex: 0x33CC33)
        static let medGray = UIColor.color(fromHex: 0x666666)
    }
}


extension UIScreen {
    
    class state {
        //The brightness whenever the app comes into the foreground
        static var launchBrightness: CGFloat!
        
        //The brightness of the screen BEFORE the brightness-changing ViewController is presented
        static var onPresentBrightness: CGFloat?
        
        //The computed target brightness to change to
        static var targetBrightness: CGFloat?
        
        //Whether or not the controller is currently presented
        static var controllerPresented: Bool = false
        
        //Whether or not the app is in the foreground / active to the user
        static var appIsActive: Bool = false
    }
    
    static func appLeftPrimaryView() {
        CheckInPassViewController.targetBrightness = CheckInPassViewController.initialScreenBrightness
        CheckInPassViewController.updateScreenBrightness()
    }
    
    static func appCameIntoView() {
        if CheckInPassViewController.presented {
            CheckInPassViewController.targetBrightness = 1.0
            CheckInPassViewController.updateScreenBrightness()
        }
    }
    
    

}


extension UIImage {
    
    func drawAspectFill(in rect: CGRect) -> UIImage {
        let targetSize = rect.size

        let widthRatio = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        let scalingFactor = max(widthRatio, heightRatio)
        let newSize = CGSize(width: self.size.width * scalingFactor, height: self.size.height * scalingFactor)
        
        print("Target: \(targetSize)")
        UIGraphicsBeginImageContext(targetSize)
        let origin = CGPoint(x: (targetSize.width  - newSize.width)  / 2, y: (targetSize.height - newSize.height) / 2)
        self.draw(in: CGRect(origin: origin, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        scaledImage?.draw(in: rect)
        
        return scaledImage!
    }

}




public extension UIWindow {
    
    public class presented {
        static var viewController: UIViewController!

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
