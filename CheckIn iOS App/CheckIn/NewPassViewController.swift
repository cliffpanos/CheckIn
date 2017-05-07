//
//  NewPassViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import ContactsUI

class NewPassViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    
    @IBOutlet weak var startPickerTextField: UITextField!
    
    let datePicker = UIDatePicker()
    
    
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for textField in [nameTextField, emailTextField, startPickerTextField] {
            let numberToolbar: UIToolbar = UIToolbar()
            numberToolbar.barStyle = UIBarStyle.default
            
            let textInputAccessories = [ UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
            ]
            
            numberToolbar.items = textInputAccessories
            
            numberToolbar.sizeToFit()
            
            textField?.inputAccessoryView = numberToolbar
            textField?.tintColor = UIColor.clear
        
        } //End for loop
        
        startPickerTextField.placeholder = C.format(date: Date())
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .dateAndTime
        startPickerTextField.inputView = datePicker
        datePicker.backgroundColor = UIColor.white
        datePicker.addTarget(self, action: #selector(fillDateField), for: .valueChanged)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //This class does not subclass ManagedViewController, so its functionality must be done here
        UIWindow.presented.viewController = self
    }
    
    
    func fillDateField() {
        let fieldToFill = startPickerTextField
        
        fieldToFill?.text = C.format(date: datePicker.date)
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


    
    @IBAction func onCancelPressed(_ sender: Any) {
        if nameTextField.text != "" && emailTextField.text != "" {
            
            C.showDestructiveAlert(withTitle: "Cancel Pass Creation?", andMessage: nil, andDestructiveAction: "Discard Pass", inView: self, withStyle: .actionSheet) { _ in
                self.dismiss(animated: true, completion: nil)
            }

        } else {
            
            //Dismiss only if there is not a ton of user data that would be lost
            self.dismiss(animated: true, completion: nil)
        
        }

    }
    
    @IBAction func sendPassPressed(_ sender: Any) {
        
        if nameTextField.text == "" {
            let alert = UIAlertController(title: "Insufficient Information", message: "Please enter at minimum a name", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        
        } else if endDatePicker.date <= startDatePicker.date {
            let alert = UIAlertController(title: "Inordered Dates", message: "The start date must precede the end date", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        
        } else {
            createAndSavePass()
        }
        
    }
    
    func createAndSavePass() {
        
        let name = nameTextField.text ?? ""
        let email = emailTextField.text == "" ? "No email provided" : emailTextField.text ?? ""
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellPosition = (indexPath.section, indexPath.row)

        switch (cellPosition) {
        case (0, 0):
            tryToChooseFromContacts()

        default: break
        }
    }
    
}




//MARK: - Handle the Selection of Contact(s) using ContactsUI

extension NewPassViewController: CNContactPickerDelegate {
    
    //The only link to the UI on this page
    @IBAction func chooseContactPressed(_ sender: Any) {
        tryToChooseFromContacts()
    }
    
    //Authorize CheckIn if not authorized
    func tryToChooseFromContacts() {
        
        if CNContactStore.authorizationStatus(for: CNEntityType.contacts) != .authorized {
            let contacts = CNContactStore()
            
            contacts.requestAccess(for: CNEntityType.contacts, completionHandler: {success, error in
                if success {
                    self.presentContactPicker()
                }
            })
        } else {
            presentContactPicker()
        }
    }
    
    //Present the ContactPicker
    func presentContactPicker() {
        
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
