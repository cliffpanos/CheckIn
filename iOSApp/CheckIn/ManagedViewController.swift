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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
