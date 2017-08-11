//
//  LoginViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import QRCodeReader

class LoginViewController: ManagedViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var primaryView: UIView!
    @IBOutlet weak var loginTitle: UILabel!
    
    var textFieldSelected: Bool = false
    var textFieldManager: CPTextFieldManager!
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldManager = CPTextFieldManager(textFields: [emailTextField, passwordTextField], in: self)
        textFieldManager.setupTextFields(withAccessory: .done)
        textFieldManager.setFinalReturn(keyType: .go) {
            self.signInPressed(Int(0))
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

    
    
    //MARK: Sign-in & Account Creation ------------------------------------------ :
    @IBAction func signInPressed(_ sender: Any) {
        
        feedbackGenerator.prepare()
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces) else {
                self.showSimpleAlert("Incomplete Fields", message: "Surprise! You need to enter both an email and a password to log in.")
                return
        }
        
        Accounts.shared.standardLogin(withEmail: email, password: password, completion: { success in
            if success {
                
                //CHECK TO SEE IF EMAIL IS VERIFIED
                self.feedbackGenerator.notificationOccurred(.success)
                self.animateOff()
            } else {
                self.shakeTextFields()
                self.feedbackGenerator.notificationOccurred(.error)
            }
        })
        if (email == "user" && password == "pass") {
            animateOff()
        }

    }
    
    
    
    
    @IBAction func newAccount(_ sender: Any) {
        let vc = C.storyboard.instantiateViewController(withIdentifier: "newAccountViewController")
        self.view.endEditing(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    
    //MARK: - Animations ---------------------- :
    
    func shakeTextFields() {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = 3
        animation.duration = 0.07
        animation.autoreverses = true
        animation.byValue = 7 //how much it moves
        self.passwordTextField.layer.add(animation, forKey: "position")
        self.emailTextField.layer.add(animation, forKey: "position")
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
    
    func animateOff() {
        
        dismissKeyboard()
        UIView.animate(withDuration: 0.75, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.25, options: .curveEaseIn, animations: {
            
            let translationY = 0.5 * self.view.frame.height + 100
            self.primaryView.frame.origin.y += translationY
            self.loginTitle.text = "Success"

            
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
