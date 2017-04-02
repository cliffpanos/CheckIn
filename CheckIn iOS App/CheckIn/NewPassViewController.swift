//
//  NewPassViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class NewPassViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate {

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for textField in [nameTextField, emailTextField] {
            let numberToolbar: UIToolbar = UIToolbar()
            numberToolbar.barStyle = UIBarStyle.default
            
            numberToolbar.items = [
                
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
            ]
            
            numberToolbar.sizeToFit()
            
            textField?.inputAccessoryView = numberToolbar
        
        } //End for loop
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch (textField) {
        case nameTextField: emailTextField.becomeFirstResponder()
        default: dismissKeyboard()
        }
        return true
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    @IBAction func chooseContactPressed(_ sender: Any) {
        
        if CNContactStore.authorizationStatus(for: CNEntityType.contacts) != .authorized {
            let contacts = CNContactStore()
            
            contacts.requestAccess(for: CNEntityType.contacts, completionHandler: {success, error in
                if success {
                    self.fillContactInformation()
                }
            })
        } else {
            fillContactInformation()
        }
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        if nameTextField.text != "" && emailTextField.text != "" {
            
            let alert = UIAlertController(title: "Do you want to cancel creating this pass?", message: nil, preferredStyle: .actionSheet)
            let discardAction = UIAlertAction(title: "Discard Pass", style: .destructive, handler: { action in
                self.dismiss(animated: true, completion: nil)
            })
            
            let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            alert.addAction(discardAction)
            self.present(alert, animated: true, completion: nil)
        
        } else {
            
            //Dismiss only if there is not a ton of user data that would be lost
            self.dismiss(animated: true, completion: nil)
        
        }

    }
    
    @IBAction func sendPassPressed(_ sender: Any) {
        
        if nameTextField.text == "" {
            let alert = UIAlertController(title: "Insufficient Information", message: "Please enter more information", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        
        } else {
            createAndSavePass()
        }
        
    }
    
    func createAndSavePass() {
        
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? "No email provided"
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        let success = C.save(pass: nil, withName: name, andEmail: email, andImage: imageData, from: startDate, to: endDate)
        
        if success {
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Failed to save Pass", message: "The pass could not be saved at this time.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func handlePanDown(_ sender: Any) {
        if panGestureRecognizer.velocity(in: self.view).y > 0 {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func fillContactInformation() {
        
        let contactsVC = CNContactPickerViewController()
        contactsVC.delegate = self
        self.present(contactsVC, animated: true, completion: nil)
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        nameTextField.text = (contact.givenName as String) + " " + contact.familyName
        emailTextField.text = (contact.emailAddresses.count > 0) ? contact.emailAddresses[0].value as String : ""
        imageData = contact.imageDataAvailable ? contact.imageData : nil

    }
    

}
