//
//  RootViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {
    
    static weak var instance: RootViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RootViewController.instance = self
        let passListService = FirebaseService(entity: .TPPassList)
        let passService = FirebaseService(entity: .TPPass)
        passListService.retrieveList(forIdentifier: Accounts.userIdentifier) { pairs in
            for (passIdentifier, _) in pairs {
                passService.retrieveData(forIdentifier: passIdentifier) { object in
                    let pass = object as! TPPass
                    var contains = false
                    for current in C.passes { if current == pass { contains = true } }
                    if !contains {
                        print("Adding pass to C.passes")
                        C.passes.append(pass)
                    }
                    guard let root = RootViewController.instance else { return }
                    
                    print("switching")
                    
                    if !root.showingPassesTableView {
                        root.switchToGuestRootController(withIdentifier: "splitViewController")
                    }
                    
                    FirebaseStorage.shared.retrieveImageData(for: passIdentifier, entity: .TPPass) { data, _ in
                        if let data = data {
                            pass.imageData =  data
                        }
                    }
                }

            }
        }
        
        

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO
//        let moreItem = UITabBarItem(tabBarSystemItem: .more, tag: 3)
//        let currentItems = self.tabBar.items!
//        self.tabBar.setItems(([moreItem] + currentItems), animated: true)
    }
    
    var showingPassesTableView = false
    
    func switchToGuestRootController(withIdentifier identifier: String) {
        print("CHANGING GUEST ROOT VIEW CONTROLLER")
        let newVC = C.storyboard.instantiateViewController(withIdentifier: identifier)
        var viewControllers = self.viewControllers!
        viewControllers[1] = newVC
        self.viewControllers = viewControllers
        
        showingPassesTableView = identifier != "passInfoViewController"
    }

}

