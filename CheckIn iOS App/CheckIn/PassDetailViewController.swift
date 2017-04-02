//
//  PassDetailViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData

class PassDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var passActivityState: UILabel!
    
    var pass: Pass!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup information using Pass
        nameLabel.text = pass.name
        emailLabel.text = pass.email
        startTimeLabel.text = pass.timeStart
        endTimeLabel.text = pass.timeEnd
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        passActivityState.text = C.passesActive ? "Pass Active Between:" : "Pass Currently Inactive."
    
    }

    @IBAction func revokeAccessPressed(_ sender: Any) {
        
        let action = UIAlertAction(title: "Revoke Pass", style: .destructive, handler:{ _ in
            let success = C.delete(pass: self.pass)
            
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Failed to revoke Pass", message: "The pass could not be revoked at this time.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        })
        
        let alert = UIAlertController(title: "Confirm Revocation", message: "Are you sure you want to revoke this pass?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }


}
