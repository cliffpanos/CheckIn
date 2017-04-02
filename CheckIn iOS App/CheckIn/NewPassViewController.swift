//
//  NewPassViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class NewPassViewController: UIViewController, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate {

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
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
        fillContactInformation()
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        if nameTextField.text != "" && emailTextField.text != "" {
            
            let alert = UIAlertController(title: "Cancel Pass Creation", message: "Do you want to cancel creating this pass?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Exit", style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            })
            
            let alertAction = UIAlertAction(title: "Stay Here", style: .default, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        
        } else {
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    @IBAction func sendPassPressed(_ sender: Any) {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        let success = C.save(pass: nil, withName: name, andEmail: email, from: startDate, to: endDate)
        
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
        
        let contactsVC = ABPeoplePickerNavigationController()
        contactsVC.peoplePickerDelegate = self
        self.present(contactsVC, animated: true, completion: nil)
        
        
    }
    
    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        let name = person
    }

}
