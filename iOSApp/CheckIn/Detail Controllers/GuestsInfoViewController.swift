//
//  GuestsInfoViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 8/14/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class GuestsInfoViewController: ManagedViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switchToSplitVC() {
        (self.tabBarController! as! RootViewController).switchToGuestRootController(withIdentifier: "splitViewController")
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
