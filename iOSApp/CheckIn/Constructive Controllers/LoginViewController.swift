//
//  LoginViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import QRCodeReader

class LoginViewController: ManagedViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var primaryView: UIView!
    @IBOutlet weak var loginTitle: UILabel!
    
    var textFieldSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for textField in [emailTextField, passwordTextField] {
            let numberToolbar: UIToolbar = UIToolbar()
            numberToolbar.barStyle = UIBarStyle.default
            
            numberToolbar.items = [
                
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
            ]
            
            numberToolbar.sizeToFit()
            
            textField?.inputAccessoryView = numberToolbar
            
            textField?.isUserInteractionEnabled = true
        }
        let _: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = true
    }

    override func keyboardWillShow(notification: Notification) {
        
        guard !textFieldSelected else { return }
        
        print("moving up")
        
        UIView.animate(withDuration: 0.75, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
        
            self.primaryView.frame.origin.y -= 75
            
        })
        UIView.commitAnimations()
        self.textFieldSelected = true

        
    }
    
    override func keyboardWillHide(notification: Notification) {
        if !self.textFieldSelected {
            return
        }
        print("moving down")
        
        UIView.animate(withDuration: 0.75, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
            
            self.primaryView.frame.origin.y += 75

        }, completion: nil)
        UIView.commitAnimations()

        self.textFieldSelected = false
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch (textField) {
        case emailTextField: passwordTextField.becomeFirstResponder()
        default:
            dismissKeyboard()
            signInPressed(self)
        }
        return true
    }
    
    
    //------------------------------------------
    @IBAction func signInPressed(_ sender: Any) {
        
        if (passwordMatchesEmail()) {
            animateOff()
        } else if (isAdministratorLogin()){
            let reader = QRCodeReaderViewController()
            reader.resultCallback = {
                print($1)
            }
            
            reader.cancelCallback = {
                $0.dismiss(animated: true, completion: nil)
            }
            self.present(reader, animated: true, completion: nil)
        } else {
            //Let the user know that the entered information was incorrect
            shake()
        }
    }
    //------------------------------------------
    
    
    @IBAction func emailFieldPressed(_ sender: Any) {
        print("becoming")
        passwordTextField.resignFirstResponder()
        emailTextField.becomeFirstResponder()
    }
    
    
    func passwordMatchesEmail() -> Bool {
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        return email == "user" && password == "pass"

    }
    
    func isAdministratorLogin() -> Bool {
        return (emailTextField.text ?? "") == "admin" && (passwordTextField.text ?? "") == "pass"
    }
    
    
    @IBAction func newAccount(_ sender: Any) {
        let vc = C.storyboard.instantiateViewController(withIdentifier: "newAccountViewController")
        self.view.endEditing(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func forgotPassword(_ sender: Any) {
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
        self.emailTextField.layer.add(animation, forKey: "position")
    }
    
    func animateOff() {
        
        dismissKeyboard()
        UIView.animate(withDuration: 0.75, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.25, options: .curveEaseIn, animations: {
            
            let translationY = 0.5 * self.view.frame.height + 100
            self.primaryView.frame.origin.y += translationY
            self.loginTitle.text = "Login Successful!"

            
        }, completion: {_ in
            self.textFieldSelected = false
                
            C.userIsLoggedIn = true

            let tabBarController = C.storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
//            self.present(tabBarController, animated: true, completion: {
//
//            
//            })
            C.appDelegate.window!.rootViewController = tabBarController
            C.appDelegate.tabBarController = tabBarController
            
            C.appDelegate.tabBarController.selectedIndex = 0

            
        })
        
    }

}


class LoginNavigationController: UINavigationController {
    
    var manualStatusBarStyle: UIStatusBarStyle?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return manualStatusBarStyle ?? .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    
}
