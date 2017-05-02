//
//  ManagedUIViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class ManagedUIViewController: UIViewController {

    class Presented {
        static var presented: ManagedUIViewController?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View WILL APPEAR")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View DID APPEAR")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Presented View Controller did recieve memory warnings")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("View WILL DISAPPEAR")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("View DID DISAPPEAR")
    }


}
