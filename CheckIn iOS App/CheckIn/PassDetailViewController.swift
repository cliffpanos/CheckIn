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
    
    var imageView: RoundedImageView!
    var pass: Pass!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup information using Pass

        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareQRCode))
        navigationItem.rightBarButtonItem = shareButton
        
        
        //Setup contact icon imageView in the titleView
        
        imageView = RoundedImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 17.5
        imageView.isOpaque = true
        
        if let imageData = pass.image {
            let image = UIImage(data: imageData as Data)
                imageView.image = image
        }

        navigationItem.titleView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        navigationItem.titleView?.addSubview(imageView)
        //self.navigationController?.view.addSubview(imageView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = pass.name
        emailLabel.text = pass.email
        startTimeLabel.text = pass.timeStart
        endTimeLabel.text = pass.timeEnd
        
        passActivityState.text = C.passesActive ? "Pass Active Between:" : "Pass Currently Inactive."
        
        if pass.image == nil {
            let imageName = C.passesActive ? "greenContactIcon" : "contactIcon"
            imageView.image = UIImage(named: imageName)
        }
    
    }
    
    func shareQRCode() {
        let qrCodeImage = C.generateQRCode(forMessage:
            "\(self.nameLabel.text!)|" +
            "\(self.emailLabel.text ?? "No email provided")|" +
            "\(self.startTimeLabel.text!)|" +
            "\(self.endTimeLabel.text!)|" +
            "\(C.locationName)|"

        , withSize: nil)
        C.share(image: qrCodeImage, in: self)
    }

    @IBAction func revokeAccessPressed(_ sender: Any) {
        
        C.showDestructiveAlert(withTitle: "Confirm Revocation", andMessage: "Permanently revoke this pass?", andDestructiveAction: "Revoke", inView: self, withStyle: .actionSheet) { _ in
            let success = C.delete(pass: self.pass)
            
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Failed to revoke Pass", message: "The pass could not be revoked at this time.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }


}
