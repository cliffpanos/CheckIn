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

class PassDetailNavigationController: UINavigationController {
    
}

class PassDetailEmbedderController: UIViewController {
    var pass: TPPass!
    override func viewDidLoad() {
        super.viewDidLoad()
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareQRCode))
        navigationItem.rightBarButtonItem = shareButton
    }
    func getQRCodeImage() -> UIImage {
        return C.generateQRCode(forMessage:
            "\(self.pass.name)|" +
                "\(self.pass.email!)|" +
                "\(self.pass.startDate!)|" +
                "\(self.pass.endDate!)|" +
            "\(pass.locationIdentifier ?? "Location Identifier Unknown")|"
            
            , withSize: nil)
    }
    func shareQRCode() {
        let qrCodeImage = getQRCodeImage()
        C.share(image: qrCodeImage, in: self, popoverSetup: {
            ppc in ppc.barButtonItem = self.navigationItem.rightBarButtonItem
            ppc.permittedArrowDirections = [.up]
        })
    }
    @IBAction func revokeAccessPressed(_ sender: UIButton) {
        
        showDestructiveAlert("Confirm Revocation", message: "Permanently revoke this pass?", destructiveTitle: "Revoke", popoverSetup: { ppc in
            ppc.sourceView = sender
            ppc.sourceRect = sender.bounds
            ppc.permittedArrowDirections = [.down]
        }, withStyle: .actionSheet) { _ in
            
            //Must have a managedObjectContext or the pass no longer exists in CoreData
            guard self.pass.managedObjectContext != nil else { return }
            
            let success = PassManager.delete(pass: self.pass)
            
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
    @IBAction func inactivatePassPressed(_ sender: UIButton) {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailController = segue.destination as! PassDetailViewController
        detailController.pass = pass
    }

}



class PassDetailViewController: UITableViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var passActivityState: UILabel!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var locationTitleLabel: UILabel!
    
    @IBOutlet var imageView: CDImageView!
    var pass: TPPass!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /*Setup contact icon imageView in the titleView
        
        imageView = RoundedImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 17.5
        imageView.isOpaque = true
        */
        
        guard pass != nil else { return }
        if let imageData = pass.imageData {
            let image = UIImage(data: imageData as Data)
                imageView.image = image
        }

        //navigationItem.titleView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        //navigationItem.titleView?.addSubview(imageView)
        //self.navigationController?.view.addSubview(imageView)
        
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return 150
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.navigationBar.hairlineisHidden = true
        guard pass != nil else { return }

        nameLabel.text = pass.name
        startTimeLabel.text = pass.startDate
        endTimeLabel.text = pass.endDate
        locationTypeLabel.text = "LOC TYPE" //TODO
        locationTitleLabel.text = "Location Title"
        
        passActivityState.text = C.passesActive ? "PASS ACTIVE BETWEEN:" : "PASS CURRENTLY INACTIVE"
            
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBar.hairlineisHidden = false
    }
    
    func getQRCodeImage() -> UIImage {
        
        return C.generateQRCode(forMessage:
            "\(self.pass.name)|" +
                "\(self.pass.email!)|" +
                "\(self.pass.startDate!)|" +
                "\(self.pass.endDate!)|" +
            "\(pass.locationIdentifier ?? "Location Identifier Unknown")|"
            
            , withSize: nil)
    }
    
    
    @IBAction func shareViaMail(_ sender: Any) {

        guard MFMailComposeViewController.canSendMail() else {
            self.showSimpleAlert("Unable to send Mail", message: nil); return
        }

        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients([pass.email ?? ""])
        mailController.setSubject("True Pass")
        mailController.setMessageBody("Hi \(pass.name), attached is your True Pass", isHTML: false)
        
        let qrCode = getQRCodeImage()
        if let imageData = UIImagePNGRepresentation(qrCode) {

            mailController.addAttachmentData(imageData, mimeType: "image/png", fileName: "True Pass.png")
            self.present(mailController, animated: true)
        }

    }
    
    @IBAction func shareViaMessages(_ sender: Any) {
        guard MFMessageComposeViewController.canSendText() && MFMessageComposeViewController.canSendAttachments() else {
            self.showSimpleAlert("Unable to send Message or Attachments", message: nil); return
        }
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.recipients = [pass.phoneNumber ?? ""]
        messageController.body = "Hi \(pass.name), attached is your True Pass"
        
        let qrCode = getQRCodeImage()
        if let imageData = UIImagePNGRepresentation(qrCode) {
            messageController.addAttachmentData(imageData, typeIdentifier: "image/png", filename: "True Pass.png")
            self.present(messageController, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if let error = error {
                self.showSimpleAlert("The email failed to send", message: error.localizedDescription)
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }


}
