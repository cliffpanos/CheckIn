//
//  CEViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 8/9/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showSimpleAlert(_ title: String, message: String?, handler: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in handler?() })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showOptionsAlert(_ title: String?, message: String?, left: String, right: String, handlerOne: ((UIAlertAction) -> Void)? = nil, handlerTwo: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let left = UIAlertAction(title: left, style: (left == "Cancel" ? .cancel : .default), handler: handlerOne)
        let right = UIAlertAction(title: right, style: (right == "Cancel" ? .cancel : .default), handler: handlerTwo)
        alert.addAction(left)
        alert.addAction(right)
        
        self.present(alert, animated: true)
        
    }
    
    func showDestructiveAlert(_ title: String, message: String?, destructiveTitle destructive: String, popoverSetup:((UIPopoverPresentationController) -> Void)?, withStyle style: UIAlertControllerStyle, forDestruction completionHandler: @escaping (UIAlertAction) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let destructiveAction = UIAlertAction(title: destructive, style: .destructive, handler:
            completionHandler)
        
        alert.addAction(cancelAction)
        alert.addAction(destructiveAction)
        
        self.setupPopoverPresentation(for: alert, popoverSetup: popoverSetup)
        
        self.present(alert, animated: true)
        
    }
    
    //MARK: - Popover helper methods
    
    func setupPopoverPresentation(for popup: UIViewController, popoverSetup: ((UIPopoverPresentationController) -> Void)?) {
        
        if let presenter = popup.popoverPresentationController, let setup = popoverSetup {
            print("PopoverPresentationController activated")
            setup(presenter)
        }
        
    }

}
