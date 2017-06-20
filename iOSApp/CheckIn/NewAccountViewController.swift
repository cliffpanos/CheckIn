//
//  NewAccountViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 6/19/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewAccountViewController: UITableViewController {

    @IBOutlet weak var fNameTextField: UITextField!
    @IBOutlet weak var lNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var contactView: ContactView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section,indexPath.row) {
        case (0,0): choosePersonalContact()
        case (2, 0): createAccount()
        default: break }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBOutlet weak var editContactImage: UIButton!
    
    @IBOutlet weak var passwordVisibilityButton: CDButton!
    @IBAction func togglePasswordVisibility(_ sender: Any) {
        let secure = self.passwordTextField.isSecureTextEntry
        self.passwordTextField.isSecureTextEntry = !secure
        passwordVisibilityButton.setTitle(!secure ? "SHOW" : "HIDE", for: .focused)
        passwordVisibilityButton.title
        
    }
    
    func choosePersonalContact() {
        
    }
    
    func createAccount() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard let firstName = fNameTextField.text, let lastName = lNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        UserAuthentication.shared.standardRegister(withEmail: email, password: password, completion: { success in
            
            self.activityIndicator.stopAnimating()
            
            self.activityIndicator.isHidden = true
            
            if success {
                
                //Create a TP User here
                
                let service = FirebaseService(entity: .FTPUser)
                let snapshot = DataSnapshot()
                let user = FTPUser(snapshot: snapshot)
                user.userIdentifier = "12345678"
                user.email = email
                user.firstName = firstName
                user.lastName = lastName
                
                
                service.enterData(forIdentifier: UserAuthentication.shared.current?.uid ?? "UID MANUAL", data: user)
                
                if let user = UserAuthentication.shared.current {
                    user.sendEmailVerification { success in
                        print("User made and email sent!")
                    }
                }
            }
            
        })
    }

}
