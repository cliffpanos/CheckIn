//
//  Extensions.swift
//  True Pass
//
//  Created by Cliff Panos on 4/24/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

//An extension for the String class exists in CommonPlatform.swift

//An extension for the UIColor class exists in CommonPlatform.swift



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


extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            print("toBool function called")
            return true
        case "False", "false", "no", "0":
            print("toBool function called")
            return false
        default:
            return nil
        }
    }
}

extension UIDevice {
    public var isVertical: Bool {
        return self.orientation.isPortrait || (self.orientation.isFlat && UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width)
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
