//
//  ForgotPasswordViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 8/7/17.
//
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: ManagedViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    var textFieldManager: CPTextFieldManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessage.text = ""
        textFieldManager = CPTextFieldManager(textFields: [emailTextField], in: self)!
        textFieldManager.setupTextFields(withAccessory: .done)
        textFieldManager.setFinalReturn(keyType: .send, action: {
            self.textFieldManager.dismissKeyboard()
            self.resetPasswordPressed(self.emailTextField)
        })
        scrollView.contentSize = contentView.frame.size
        setScrollViewForKeyboard(scrollView)
    }
    
    @IBAction func resetPasswordPressed(_ sender: Any) {
        
        if (emailTextField.text ?? "") != "" {
            errorMessage.text = ""
        } else {
            errorMessage.text = "Enter an email address"
            return
        }
        
        //Confirm that the user really wants to reset his or her password
        
        self.showDestructiveAlert("Confirm Reset", message: "Are you sure that you want to reset your password?", destructiveTitle: "Reset", popoverSetup: nil, withStyle: .alert, forDestruction: { _ in
            self.resetPassword()
            self.textFieldManager.dismissKeyboard()
        })
        
    }
    
    func resetPassword() -> Void {
        
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespaces)
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            
            if error == nil {
                let alert = UIAlertController(title: "Reset Successful", message: "Your password reset instructions have been sent to the specified email address.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.showSimpleAlert("Error", message: "An error occurred while trying to reset your password; the email entered may have been invalid.")
            }
        }
        
        errorMessage.text = ""
    
    }
    

    // MARK: - Navigation
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
