//
//  UIAlert.swift
//  True Pass
//
//  Created by Cliff Panos on 8/6/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class UIAlert {
    
    static func showAlert(title: String, message: String?, inView viewController: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    
    static func showDestructiveAlert(withTitle title: String, andMessage message: String?, andDestructiveAction destructive: String, inView viewController: UIViewController, popoverSetup:((UIPopoverPresentationController) -> Void)?, withStyle style: UIAlertControllerStyle, forDestruction completionHandler: @escaping (UIAlertAction) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let destructiveAction = UIAlertAction(title: destructive, style: .destructive, handler:
            completionHandler)
        
        alert.addAction(cancelAction)
        alert.addAction(destructiveAction)
        
        UIAlert.setupPopoverPresentation(for: alert, popoverSetup: popoverSetup)
        
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Popover helper methods
    
    static func setupPopoverPresentation(for popup: UIViewController, popoverSetup: ((UIPopoverPresentationController) -> Void)?) {
        
        if let presenter = popup.popoverPresentationController, let setup = popoverSetup {
            print("PopoverPresentationController activated")
            setup(presenter)
        }
        
    }
    
}
