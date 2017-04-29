//
//  ViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard C.userIsLoggedIn else {
            let controller = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
            self.present(controller, animated: false, completion: nil)
            
            return
        }
    
    }

}

