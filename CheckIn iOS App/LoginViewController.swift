//
//  LoginViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var primaryView: UIView!
    @IBOutlet weak var loginTitle: UILabel!
    
    var textFieldSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    func keyboardWillShow(notification: NSNotification) {
        if textFieldSelected {
            return
        }
        UIView.animate(withDuration: 1.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
            
            self.primaryView.frame.origin.y -= 40
            self.loginTitle.frame.origin.y -= 40
            
        }, completion: { _ in
            self.textFieldSelected = false
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if !textFieldSelected {
            return
        }
        UIView.animate(withDuration: 1.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
            
            self.primaryView.frame.origin.y += 40
            self.loginTitle.frame.origin.y += 40
            
        }, completion: { _ in
            self.textFieldSelected = true
        })
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        
        if (passwordMatchesEmail()) {
            self.dismiss(animated: true, completion: {
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            })
        }
    }

    @IBAction func newAccountPressed(_ sender: Any) {
        
    }
    
    func passwordMatchesEmail() -> Bool {
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email == "user" && password == "pass" {
            return true
        } else {
            shake()
            passwordTextField.text = ""
        }
        
        return false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self)
    }
    
    
    //MARK: - Animations:
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = 3
        animation.duration = 0.07
        animation.autoreverses = true
        animation.byValue = 7 //how much it moves
        self.passwordTextField.layer.add(animation, forKey: "position")
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
