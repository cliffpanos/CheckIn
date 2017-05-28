//
//  NewPassViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import ContactsUI

class NewPassViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var startDatePicker: UITextField!
    @IBOutlet weak var endDatePicker: UITextField!
    
    var startDate: Date = Date() {
        didSet {
            startDatePicker.text = C.format(date: startDate)
        }
    }
    var endDate: Date = Date(timeInterval: (24 * 60 * 60), since: Date()) {
        didSet {
            endDatePicker.text = C.format(date: endDate)
        }
    }
    
    let datePicker = UIDatePicker() //Shared DatePicker object used by both TextFields
    
    var imageData: Data?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for textField in [nameTextField, emailTextField, startDatePicker, endDatePicker] {
            let numberToolbar: UIToolbar = UIToolbar()
            numberToolbar.barStyle = UIBarStyle.default
            
            let textInputAccessories = [ UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
            ]
            
            numberToolbar.items = textInputAccessories
            numberToolbar.sizeToFit()
            textField?.inputAccessoryView = numberToolbar
        
        } //End for loop for setting up the "Done" toolbars
        
        startDatePicker.tintColor = UIColor.clear
        endDatePicker.tintColor = UIColor.clear
        
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .dateAndTime
        datePicker.backgroundColor = UIColor.white
        datePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        
        //The start & end TextFields are really just conduits for the date picker
        startDatePicker.inputView = datePicker
        endDatePicker.inputView = datePicker
        startDatePicker.text = C.format(date: startDate)
        endDatePicker.placeholder = C.format(date: endDate)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //This class does not subclass ManagedViewController, so its functionality must be done here
        UIWindow.presented.viewController = self
    }
    
    
    func updateDate() {
        if startDatePicker.isEditing {
            startDate = datePicker.date
        } else {
            endDate = datePicker.date
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch (textField) {
        case nameTextField: emailTextField.becomeFirstResponder()
        case emailTextField: startDatePicker.becomeFirstResponder()
            let indexPath = IndexPath(row: 0, section: 2)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        default: dismissKeyboard()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard textField == startDatePicker || textField == endDatePicker else { return }
        
        textField.textColor = UIColor.TrueColors.blue
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == startDatePicker || textField == endDatePicker else { return }
        textField.textColor = UIColor.black
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
    
    func authorizePassPressed() {
        if nameTextField.text == "" || nameTextField.text == " " {
            let alert = UIAlertController(title: "Insufficient Information", message: "Please enter at minimum a name", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        
        } else if endDate <= startDate {
            let alert = UIAlertController(title: "Dates not in order", message: "The start date must precede the end date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        } else {
            createAndSavePass()
        }
        
    }
    
    func createAndSavePass() {
        
        let name = nameTextField.text ?? "No Name"
        let email = emailTextField.text == "" ? "no email provided" : emailTextField.text ?? ""
        let start = self.startDate
        let end = self.endDate
        
        let success = C.save(pass: nil, withName: name, andEmail: email, andImage: imageData, from: start, to: end)
        
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
            tryToChooseFromContacts() //See CNContactPickerDelegate extension below
        case (2, 0):
            startDatePicker.becomeFirstResponder()
        case (2, 1):
            endDatePicker.becomeFirstResponder()
        case (3, 0): //The authorize button
            tableView.deselectRow(at: indexPath, animated: true)
            authorizePassPressed()
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}




//MARK: - Handle the Selection of Contact(s) using ContactsUI

extension NewPassViewController: CNContactPickerDelegate {
    
    
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
        
        nameTextField.text = contact.givenName as String + " " + contact.familyName + " " + contact.nameSuffix
        if nameTextField.text!.isEmptyOrWhitespace() { nameTextField.text = "Contact Name Unknown" }

        emailTextField.text = (contact.emailAddresses.count > 0) ? contact.emailAddresses[0].value as String : ""
        imageData = contact.thumbnailImageData

    }
    

}
