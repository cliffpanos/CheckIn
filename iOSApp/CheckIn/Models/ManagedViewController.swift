//
//  ManagedViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class ManagedViewController: UIViewController {
    
    //See Extensions.swift for UIWindow's static variable 'presentedViewController'
    var managedScrollViewForKeyboard: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setScrollViewForKeyboard(_ scrollView: UIScrollView) {
        self.managedScrollViewForKeyboard = scrollView
    }
    
    func keyboardWillShow(notification: Notification) {
        adjustInsetForKeyboardShowing(true, notification: notification)
    }
    
    func keyboardWillHide(notification: Notification) {
        adjustInsetForKeyboardShowing(false, notification: notification)
    }
    
    func adjustInsetForKeyboardShowing(_ showing: Bool, notification: Notification) {
        guard let scrollView = managedScrollViewForKeyboard else { return }
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (showing ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("View WILL APPEAR")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View DID APPEAR and is Presented")
        
        UIWindow.presented.viewController = self
        //Core purpose of this custom class
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //print("Presented View Controller did recieve memory warnings!")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //print("View WILL DISAPPEAR")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //print("View DID DISAPPEAR")
    }


}
