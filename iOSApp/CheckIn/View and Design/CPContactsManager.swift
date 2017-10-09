//
//  CPContactsManager.swift
//  True Pass
//
//  Created by Cliff Panos on 8/10/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import ContactsUI

class CPContactsManager: NSObject,CNContactPickerDelegate {
    
    ///The message to be displayed when the user has chosen to not give the application access to Contacts
    public var goToSettingsMessage = "Access to Contacts is not currently allowed for True Pass. You can change this in Settings"
    
    ///The CNContactStore authorization status for the application
    var authStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    unowned internal var viewController: UIViewController
    
    /**
        Use this variable to set what action will be triggered when the user selects a  CNContact.
        # Capturing self:
        - Most often, it will be necessary to capture `self` in order to update a label or field. Example:
            - `self.nameTextField.text = contact.givenName`
        - Make sure to capture `self` as unowned in an explicit capture list:
            - `[unowned self](contact) in ...`
     */
    public var contactSelectedAction: ((CNContact) -> Void)?
    
    public init(vc: UIViewController) {
        self.viewController = vc
    }
    
    ///Present the Contact Picker if authorized and otherwise display alerts to tell the user how to authorize the application
    public func requestContactConsideringAuth() {
        if authStatus == .authorized {
            presentContactPicker()
        } else if authStatus == .notDetermined {
            viewController.showOptionsAlert("Access Contacts?", message: "Would you like to allow True Pass to access your contacts?", left: "No", right: "Yes", handlerOne: nil, handlerTwo: {
                
                let contactsStore = CNContactStore()
                contactsStore.requestAccess(for: .contacts) {
                    granted, error in
                    
                    if granted {
                        self.presentContactPicker()
                    } else if (error != nil) {
                        self.viewController.showSimpleAlert("Error", message: "There was an issue trying to process your contacts request")
                    }
                }
                
            })
        } else {
            viewController.showOptionsAlert("True Pass Not Authorized", message: goToSettingsMessage, left: "OK", right: "Settings", handlerOne: nil) {
                if let settingsAppURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(settingsAppURL)
                }
            }
        }
    }
    
    internal func presentContactPicker() {
        let contactPickerVC = CNContactPickerViewController()
        contactPickerVC.delegate = self
        contactPickerVC.modalPresentationStyle = .overCurrentContext
        viewController.present(contactPickerVC, animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        contactSelectedAction?(contact)
    }
    
}
