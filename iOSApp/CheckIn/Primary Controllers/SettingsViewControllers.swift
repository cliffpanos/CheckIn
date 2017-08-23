//
//  SettingsViewControllers.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class SettingsViewController: ManagedViewController {

    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var userProfileImage: CDImageViewCircular!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO The values below should be replaced with CoreData values
        ownerLabel.text = Accounts.userName
        
        if let image = Accounts.userImage {
            userProfileImage.image = image
        } else {
            FirebaseStorage.shared.retrieveProfilePictureForCurrentUser() { data, error in
                if let error = error {
                    print("Error Retrieving profile picture!! --------- \(error.localizedDescription)")
                } else {
                    self.userProfileImage.image = UIImage(data: data!)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        self.showDestructiveAlert("Confirm Logout", message: nil, destructiveTitle: "Logout", popoverSetup: nil, withStyle: .alert) { action in
            Accounts.shared.logout(completion: { error in
                if let error = error {
                    self.showSimpleAlert("An error occurred while trying to log out of True Pass", message: error.localizedDescription)
                } else {
                    let controller = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
                    C.appDelegate.window!.rootViewController = controller
                    //            self.present(controller, animated: true, completion: nil)
                    Accounts.userImageData = nil
                    C.userIsLoggedIn = false
                }
            })

        }
    
    }
    

}


class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var ownerEmailLabel: UILabel!
    @IBOutlet weak var locationAffiliationsLabel: UILabel!
    @IBOutlet weak var administrationNumLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ownerEmailLabel.text = Accounts.userEmail

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case (3,0):
            let infoVC = C.storyboard.instantiateViewController(withIdentifier: "infoNavigationController")
            infoVC.modalPresentationStyle = .formSheet
            self.present(infoVC, animated: true)
        case (3,1):
            showSimpleAlert("Deletion not yet supported", message: "Account deletion will be available in the next version of True Pass.")
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    
    
    
}
