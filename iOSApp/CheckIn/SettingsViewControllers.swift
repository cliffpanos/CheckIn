//
//  SettingsViewControllers.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var ownerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO The values below should be replaced with CoreData values
        ownerLabel.text = C.nameOfUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        C.showDestructiveAlert(withTitle: "Confirm Logout", andMessage: nil, andDestructiveAction: "Logout", inView: self, popoverSetup: nil, withStyle: .alert) { action in
            let controller = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
            self.present(controller, animated: true, completion: nil)
            C.userIsLoggedIn = false
        }
    
    }
    

}


class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var ownerEmailLabel: UILabel!
    @IBOutlet weak var locationAffiliationsLabel: UILabel!
    @IBOutlet weak var administrationNumLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO The three values below should be replaced with CoreData values
        ownerEmailLabel.text = C.emailOfUser

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let locationCount = C.truePassLocations.count
        locationAffiliationsLabel.text = "You are affiliated with \(locationCount) location\(locationCount != 1 ? "s" : "")."
        
        let administrationCount = (Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 2) == 0 ? 0 : 1) //TODO: this is just random
        administrationNumLabel.text = "You administer \(administrationCount) location\(administrationCount != 1 ? "s" : "")."
        
    }
    


    @IBAction func automaticCheckInChanged(_ sender: Any) {
        if let switchButton = sender as? UISwitch {
            C.automaticCheckIn = switchButton.isOn
        }
    }
    
    @IBAction func passesSwitchChanged(_ sender: Any) {
        if let activeSwitch = sender as? UISwitch {
            C.passesActive = activeSwitch.isOn
        }
    }
    
    
    
    
}
