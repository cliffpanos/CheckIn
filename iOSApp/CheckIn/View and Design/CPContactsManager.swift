//
//  CPContactsManager.swift
//  True Pass
//
//  Created by Cliff Panos on 8/10/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class CPContactsManager: NSObject,CNContactPickerDelegate {
    
    public var goToSettingsMessage = "Access to Contacts is not currently allowed for True Pass. You can change this in Settings"
    var authStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    unowned internal var viewController: UIViewController
    public var contactSelectedAction: ((CNContact) -> Void)?
    
    public init(vc: UIViewController) {
        self.viewController = vc
    }
    
    public func requestContactConsideringAuth() {
        if authStatus == .authorized {
            presentContactPicker()
        } else if authStatus == .notDetermined {
            viewController.showOptionsAlert("Access Contacts?", message: "Would you like to allow True Pass to access your contacts?", left: "No", right: "Yes", handlerOne: nil, handlerTwo: { _ in
                
                let contactsStore = CNContactStore()
                contactsStore.requestAccess(for: .contacts) {
                    granted, error in
                    
                    if granted {
                        self.presentContactPicker()
                    } else if (error != nil) {
                        self.viewController.showAlert("Error", message: "There was an issue trying to process your contacts request")
                    }
                }
                
            })
        } else {
            viewController.showOptionsAlert("True Pass Not Authorized", message: goToSettingsMessage, left: "OK", right: "Settings", handlerOne: nil) { _ in
                if let settingsAppURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(settingsAppURL)
                }
            }
        }
    }
    
    internal func presentContactPicker() {
        let contactPickerVC = CNContactPickerViewController()
        contactPickerVC.delegate = self
        viewController.present(contactPickerVC, animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        contactSelectedAction?(contact)
    }
    
}
