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
    
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var ownerEmailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO The three values below should be replaced with CoreData values
        ownerLabel.text = C.nameOfUser
        ownerEmailLabel.text = C.emailOfUser
        locationLabel.text = C.locationName
    }

    @IBAction func passesSwitchChanged(_ sender: Any) {
        C.passesActive = passesActiveSwitch.isOn
    }
    @IBAction func automaticCheckInChanged(_ sender: Any) {
        C.automaticCheckIn = automaticCheckInSwitch.isOn
    }
    
    @IBAction func showPass(_ sender: Any) {
        let passController = C.storyboard.instantiateViewController(withIdentifier: "checkInPassViewController")
        self.present(passController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        C.showDestructiveAlert(withTitle: "Confirm Logout", andMessage: nil, andDestructiveAction: "Logout", inView: self, withStyle: .alert) { action in
            let controller = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
            self.present(controller, animated: true, completion: nil)
            C.userIsLoggedIn = false
        }
    
    }
    

}
