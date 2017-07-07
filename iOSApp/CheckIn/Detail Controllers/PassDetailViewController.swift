//
//  PassDetailViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class PassDetailViewController: UITableViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var passActivityState: UILabel!
    @IBOutlet weak var revokeButton: UIButton!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var locationTitleLabel: UILabel!
    
    @IBOutlet var imageView: CDImageView!
    var pass: Pass!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup information using Pass

        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareQRCode))
        navigationItem.rightBarButtonItem = shareButton
        
        
        /*Setup contact icon imageView in the titleView
        
        imageView = RoundedImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 17.5
        imageView.isOpaque = true
        */
        
        guard pass != nil else { return }
        if let imageData = pass.image {
            let image = UIImage(data: imageData as Data)
                imageView.image = image
        }

        //navigationItem.titleView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        //navigationItem.titleView?.addSubview(imageView)
        //self.navigationController?.view.addSubview(imageView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hairlineisHidden = true
        guard pass != nil else { return }

        nameLabel.text = pass.name
        startTimeLabel.text = pass.timeStart
        endTimeLabel.text = pass.timeEnd
        locationTypeLabel.text = "LOC TYPE" //TODO
        locationTitleLabel.text = "Location Title"
        
        passActivityState.text = C.passesActive ? "PASS ACTIVE BETWEEN:" : "PASS CURRENTLY INACTIVE"
            
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hairlineisHidden = false
    }
    
    func getQRCodeImage() -> UIImage {
        
        return C.generateQRCode(forMessage:
            "\(self.nameLabel.text!)|" +
                "\(self.pass.email!)|" +
                "\(self.startTimeLabel.text!)|" +
                "\(self.endTimeLabel.text!)|" +
            "\(C.locationName)|"
            
            , withSize: nil)
    }
    
    func shareQRCode() {
        let qrCodeImage = getQRCodeImage()
        C.share(image: qrCodeImage, in: self, popoverSetup: {
            ppc in ppc.barButtonItem = self.navigationItem.rightBarButtonItem
        })
    }
    
    
    @IBAction func shareViaMail(_ sender: Any) {

        guard let recipient = pass.email, MFMailComposeViewController.canSendMail() else { return }

        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients([recipient])
        mailController.setSubject("True Pass")
        mailController.setMessageBody("Hi \(pass.name!), here is your True Pass", isHTML: false)
        
        let qrCode = getQRCodeImage()
        if let imageData = UIImagePNGRepresentation(qrCode) {

            mailController.addAttachmentData(imageData, mimeType: "image/png", fileName: "True Pass.png")
            self.present(mailController, animated: true)
        }

    }
    
    @IBAction func shareViaMessages(_ sender: Any) {
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        
        //message.recipients
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
    }
    

    @IBAction func revokeAccessPressed(_ sender: Any) {
        
        C.showDestructiveAlert(withTitle: "Confirm Revocation", andMessage: "Permanently revoke this pass?", andDestructiveAction: "Revoke", inView: self, popoverSetup: { ppc in
                ppc.barButtonItem = self.navigationItem.rightBarButtonItem
            }, withStyle: .actionSheet) { _ in
            
            //All passes MUST have a name, so if the name is nil, then the pass no longer exists in CoreData
            guard self.pass.name != nil else { return }
            
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
