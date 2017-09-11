//
//  NewPassViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import ContactsUI

class NewPassViewController: UITableViewController {

    var preselectedLocation: TPLocation?
    var textFieldManager: CPTextFieldManager!
    
    @IBOutlet weak var fNameTextField: UITextField!
    @IBOutlet weak var lNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var startDatePicker: UITextField!
    @IBOutlet weak var endDatePicker: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var contactView: ContactView!
    
    @IBOutlet weak var locationPicker: LocationPicker!
    var locationSelected = C.truePassLocations[0]
    
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

        textFieldManager = CPTextFieldManager(textFields: [fNameTextField, lNameTextField, emailTextField, startDatePicker, endDatePicker], in: self)
        textFieldManager.setupTextFields(withAccessory: .done)
        
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

        if let preSelected = preselectedLocation {
            self.locationSelected = preSelected
            locationTextField.text = locationSelected.shortTitle
        } else {
            locationTextField.text = C.truePassLocations[0].shortTitle
        }
        locationPicker.changeCallback = { [unowned self](location: TPLocation) in
            self.locationSelected = location
            self.locationTextField.text = location.shortTitle
        }
        locationTextField.inputView = locationPicker
    }
    
    func updateDate() {
        if startDatePicker.isEditing {
            startDate = datePicker.date
        } else {
            endDate = datePicker.date
        }
    }

    
    @IBAction func onCancelPressed(_ sender: UIBarButtonItem) {
        if fNameTextField.text != "" && emailTextField.text != "" {
            
            showDestructiveAlert("Cancel Pass Creation?", message: nil, destructiveTitle: "Discard Pass", popoverSetup: {ppc in
                    ppc.barButtonItem = self.navigationItem.leftBarButtonItem
                    ppc.permittedArrowDirections = [.up]
                }, withStyle: .actionSheet) { _ in
                self.dismiss(animated: true, completion: nil)
            }

        } else {
            
            //Dismiss only if there is not a ton of user data that would be lost
            self.dismiss(animated: true, completion: nil)
        
        }

    }
    
    func authorizePassPressed() {
        if fNameTextField.text?.isEmptyOrWhitespace() ?? false {
            let alert = UIAlertController(title: "Insufficient Information", message: "Please enter at minimum a name", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        
        } else if endDate <= startDate {
            let alert = UIAlertController(title: "Dates not in order", message: "The start date must precede the end date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        } else {
            createAndSavePass()
        }
        
    }
    
    func createAndSavePass() {
        
        let firstName = fNameTextField.text ?? "No Name"
        let lastName = lNameTextField.text ?? ""
        let email = emailTextField.text == "" ? "no email provided" : emailTextField.text ?? ""
        let start = self.startDate
        let end = self.endDate

        let pass = PassManager.save(pass: nil, firstName: firstName, lastName: lastName, andEmail: email, andImage: imageData, from: start, to: end, forLocation: locationSelected.identifier!)
        C.passes.append(pass)

        self.dismiss(animated: true) {
            print("success")
            if let guestInfoVC = UIWindow.presented.viewController as? GuestsInfoViewController {
                print("switching")
                guestInfoVC.switchToSplitVC()
            }
            if let vc = UIWindow.presented.viewController as? PassesViewController {
                vc.tableView.reloadData()
            }
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
            authorizePassPressed()
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        self.present(contactsVC, animated: true)
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        fNameTextField.text = contact.givenName as String
        lNameTextField.text = contact.familyName + " " + contact.nameSuffix
        if fNameTextField.text!.isEmptyOrWhitespace() { fNameTextField.text = "Contact Name Unknown" }

        emailTextField.text = (contact.emailAddresses.count > 0) ? contact.emailAddresses[0].value as String : ""
        imageData = contact.thumbnailImageData
        
        contactView.setupContactView(forData: imageData, andName: ((fNameTextField.text ?? "") + " " + (lNameTextField.text ?? "")) )
        

    }
    

}
