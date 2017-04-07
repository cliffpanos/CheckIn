//
//  ViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !C.userIsLoggedIn {
            let controller = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
            self.present(controller, animated: false, completion: nil)
        }
    
    }

}

