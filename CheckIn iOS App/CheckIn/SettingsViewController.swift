//
//  SettingsViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var passesActiveSwitch: UISwitch!
    @IBOutlet weak var automaticCheckInSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func passesSwitchChanged(_ sender: Any) {
        C.passesActive = passesActiveSwitch.isOn
    }
    @IBAction func automaticCheckInChanged(_ sender: Any) {
        C.automaticCheckIn = automaticCheckInSwitch.isOn
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
