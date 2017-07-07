//
//  RootViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard C.userIsLoggedIn else {
            let controller = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
            self.present(controller, animated: false)
            
            return
        }
        
        //TODO
        let _ = UITabBarItem(tabBarSystemItem: .more, tag: 3)
        
        //self.tabBar.setTabBarItems
    }

}

