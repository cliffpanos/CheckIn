//
//  NewAccountViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 6/19/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewAccountViewController: UITableViewController {

    @IBOutlet weak var fNameTextField: UITextField!
    @IBOutlet weak var lNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var contactView: ContactView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var textFieldManager: CPTextFieldManager!
    var imageData: Data?
    var tapRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        textFieldManager = CPTextFieldManager(textFields: [fNameTextField, lNameTextField, emailTextField, passwordTextField, confirmTextField], in: self)
        textFieldManager.setupTextFields(withAccessory: .done)
        textFieldManager.setFinalReturn(keyType: .go) {
            self.createAccount()
        }
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(editPhotoFromSelector))
        contactView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? LoginNavigationController)?.manualStatusBarStyle = UIStatusBarStyle.default
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.navigationController as? LoginNavigationController)?.manualStatusBarStyle = nil
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section,indexPath.row) {
        case (0,0): choosePersonalContact()
        case (2, 0): createAccount()
        default: break }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBOutlet weak var editContactImage: UIButton!
    
    @IBAction func passwordVisibilityTouchUp(_ sender: CDButton) {
        self.passwordTextField.isSecureTextEntry = true
        self.confirmTextField.isSecureTextEntry = true
    }
    @IBAction func passwordVisibilityTouchDown(_ sender: CDButton) {
        self.passwordTextField.isSecureTextEntry = false
        self.confirmTextField.isSecureTextEntry = false
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        showDestructiveAlert("Cancel Sign Up?", message: "Any entered information will be lost.", destructiveTitle: "Cancel Sign Up", popoverSetup: nil, withStyle: .alert, forDestruction: {_ in self.dismiss(animated: true)})
    }
    
    
    
    
    
    var contactManager: CPContactsManager! = nil
    func choosePersonalContact() {
        if contactManager == nil { contactManager = CPContactsManager(vc: self) }
        contactManager.contactSelectedAction = {
            [unowned self](contact) in
            self.fNameTextField.text = contact.givenName as String
            self.lNameTextField.text = contact.familyName + " " + contact.nameSuffix
            self.emailTextField.text = contact.emailAddresses.first?.value as String? ?? ""
            self.imageData = contact.thumbnailImageData
            self.contactView.setupContactView(forData: self.imageData, andName: ((self.fNameTextField.text ?? "") + " " + (self.lNameTextField.text ?? "")))
            
        }
        contactManager.requestContactConsideringAuth()
    }
    
    //Called by the tap gesture recognizer
    internal func editPhotoFromSelector() {
        chooseContactPhoto(editPhotoButton)
    }
    
    var photoPicker: CPPhotoPicker! = nil
    @IBAction func chooseContactPhoto(_ button: UIButton) {
        if photoPicker == nil { photoPicker = CPPhotoPicker(vc: self) }
        photoPicker.photoSelectedAction = { [unowned self](image) in
            guard let image = image else { return }
            let data = UIImagePNGRepresentation(image)
            self.imageData = data
            self.contactView.setupContactView(forData: data, andName: "")
            self.dismiss(animated: true)
        }
        photoPicker.photoPickerDismissedAction = { [unowned self] in
            self.dismiss(animated: true)
        }
        photoPicker.popoverPresentationSetup = { (popover) in
            popover.canOverlapSourceViewRect = false
            popover.sourceView = button
            popover.sourceRect = button.bounds
            popover.permittedArrowDirections = [.right, .up]
        }
        photoPicker.pickImageConsideringAuth()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        print("adaptive called")
        return .none
    }
    
    
    
    func createAccount() {
        
        textFieldManager.dismissKeyboard()
        
        guard let fN = fNameTextField.text, let lN = lNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            self.showSimpleAlert("Incomplete Fields", message: "Please enter all required fields")
            return
        }
        
        guard validateFields() else { return }
        
        let firstName = fN.trimmingCharacters(in: .whitespaces)
        let lastName = lN.trimmingCharacters(in: .whitespaces)
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        Accounts.shared.standardRegister(withEmail: email, password: password, completion: { success, error in
            
            self.activityIndicator.stopAnimating()
            
            self.activityIndicator.isHidden = true
            
            if success {    //success means error is nil
                
                //Create a TP User here
                let service = FirebaseService(entity: .FTPUser)
                let snapshot = DataSnapshot()
                let user = FTPUser(snapshot: snapshot)
                user.userIdentifier = Accounts.shared.current!.uid
                user.email = email
                user.firstName = firstName
                user.lastName = lastName
                service.enterData(forIdentifier: Accounts.shared.current!.uid, data: user)
                
                FirebaseStorage.shared.uploadProfilePicture(data: self.imageData!, for: user) {metadata, error in
                    if let error = error {
                        self.showSimpleAlert("Picture Saving Error", message: error.localizedDescription)
                    }
                }
                
                
                if let user = Accounts.shared.current {
                    user.sendEmailVerification { success in
                        print("User made and email sent!")
                    }
                }
                
                self.showSimpleAlert("Registration Successful", message: "Congratulations! You have created a True Pass Account. Head over to Mail and verify your email address.") { self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.showSimpleAlert("Registration Error", message: error!.localizedDescription)
            }
            
        })
    }
    
    func validateFields() -> Bool {
        
        guard let firstName = fNameTextField.text, let lastName = lNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmTextField.text else { return false }
        
        for text in [firstName, lastName, email, password, confirmPassword] {
            if text.isEmptyOrWhitespace() {          self.showSimpleAlert("Incomplete Fields", message: "Please enter all required fields")
                return false
            }
        }
        
        if !email.isValidEmail {
            self.showSimpleAlert("Invalid Email", message: "The email that you entered is not a valid email address")
            return false
        }
        if password != confirmPassword {
            self.showSimpleAlert("Password Mismatch", message: "The two passwords that you entered do not match")
            return false
        }
        if password.characters.count < 6 {
            self.showSimpleAlert("Password Too Short", message: "The password must be at least 6 characters long")
            return false
        }
        if imageData == nil {
            self.showSimpleAlert("Choose a Profile Picture", message: "True Pass requires every user to have a profile picture. This helps locations to know that you're you when you affiliate with them. Press the 'Edit' button to choose a photo")
            return false
        }

        return true
    }

}
