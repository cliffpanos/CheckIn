//
//  SettingsViewControllers.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: ManagedViewController {

    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var userProfileImage: CDImageViewCircular!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO The values below should be replaced with CoreData values
        ownerLabel.text = Accounts.userName
        
        if let image = Accounts.userImage {
            userProfileImage.image = image
        } //else {
            FirebaseStorage.shared.retrieveProfilePictureForCurrentUser() { data, error in
                if let error = error {
                    print("Error Retrieving profile picture!! --------- \(error.localizedDescription)")
                } else {
                    self.userProfileImage.image = UIImage(data: data!)
                    Accounts.userImageData = data
                }
            }
        //}
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
    
    @IBAction func editImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Edit Profile Picture", message: nil, preferredStyle: .actionSheet)
        let photosAction = UIAlertAction(title: "Choose from Photos", style: .default) {_ in
            self.changeProfileImage(sender: sender)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {_ in self.dismiss(animated: true)}
        alert.addAction(photosAction); alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        alert.popoverPresentationController?.permittedArrowDirections = [.up, .right]
        self.present(alert, animated: true)
    }
    
    var photoPicker: CPPhotoPicker!
    internal func changeProfileImage(sender: UIButton) {
        if photoPicker == nil {
            photoPicker = CPPhotoPicker(vc: self)
        }
        photoPicker.photoPickerDismissedAction = { [unowned self] in
            self.dismiss(animated: true)
        }
        photoPicker.popoverPresentationSetup = { popover in
            popover.canOverlapSourceViewRect = false
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = [.up, .right]
        }
        photoPicker.photoSelectedAction = { [unowned self](image) in
            guard let image = image else { return }
            guard let data = UIImagePNGRepresentation(image) else { return }
            FirebaseStorage.shared.uploadImage(data: data, for: .TPUser, withIdentifier: Accounts.userIdentifier) {metadata, error in
                if let error = error {
                    self.showSimpleAlert("Profile Picture Saving Error", message: error.localizedDescription)
                } else {
                    self.showSimpleAlert("Profile Picture Sucessfully Updated", message: nil)
                    self.userProfileImage.image = image
                    Accounts.userImageData = data
                }
            }
            
            self.dismiss(animated: true)
        }
        photoPicker.pickImageConsideringAuth()
    }

}


class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    let TPEmailCellID = "emailCell"
    let TPLocationCountCellID = "locationCountCell"
    let TPLocationNameCellID = "locationNameCell"
    let TPNotificationsCellID = "notificationsCell"
    let TPAboutCellID = "aboutCell"
    let TPDeleteAccountCellID = "deleteCell"
    
    var didLoad = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        if !didLoad {
            tableView.reloadData()
            didLoad = true
        }
    }
    
    func emailAdmin(named name: String, withAddress emailAddress: String) {
        
        guard MFMailComposeViewController.canSendMail() else {
            self.showSimpleAlert("Unable to send Mail", message: nil); return
        }
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients([emailAddress])
        mailController.setSubject("True Pass Location Inquiry")
        mailController.setMessageBody("Hi \(name), ", isHTML: false)
        self.present(mailController, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if let error = error {
                self.showSimpleAlert("The email failed to send", message: error.localizedDescription)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let nums = [2, C.truePassLocations.count, 1, 2]
        return nums[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TPLocationNameCellID) as! LocationNameCell
            cell.decorate(for: C.truePassLocations[indexPath.row])
            cell.accessoryType = .detailButton
            return cell
        }
        
        let identifiersBySection = [[0: TPEmailCellID, 1: TPLocationCountCellID], [0: "DummyPlaceholder"], [0: TPNotificationsCellID], [0: TPAboutCellID, 1: TPDeleteAccountCellID]]
        let cell = tableView.dequeueReusableCell(withIdentifier: identifiersBySection[indexPath.section][indexPath.row]!) as! DecorableCell
        cell.decorate()
        if let cell = cell as? EmailCell { cell.viewController = self }
        return cell as! UITableViewCell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let location = C.truePassLocations[indexPath.row]
        let listService = FirebaseService(entity: .TPLocationList)
        listService.retrieveList(forIdentifier: "\(location.identifier!)/TPAdminList") { pairs in
            var emails = [String]()
            var names = [String]()
            let userIdentifiers = pairs.keys
            for (index, uid) in userIdentifiers.enumerated() {
                let userService = FirebaseService(entity: .TPUser)
                userService.retrieveData(forIdentifier: uid, completion: { object in
                    let user = object as! TPUser
                    emails.append(user.email!); names.append(user.name)
                    if index == pairs.keys.count - 1 {
                        let alert = UIAlertController(title: "Email Administrators", message: nil, preferredStyle: .actionSheet)
                        for (index, email) in emails.enumerated() {
                            let action = UIAlertAction(title: names[index], style: UIAlertActionStyle.default, handler: {_ in
                                    self.emailAdmin(named: names[index], withAddress: email)
                                    //UIPasteboard.general.string = email
                                    //self.showSimpleAlert("Email Copied to Clipboard.", message: nil)
                                })
                            alert.addAction(action)
                        }
                        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in alert.dismiss(animated: true) })
                        alert.addAction(cancel)
                        alert.modalPresentationStyle = .popover
                        alert.popoverPresentationController?.permittedArrowDirections = [.right]
                        let cell = tableView.cellForRow(at: indexPath)!
                        var accessoryView: UIView!
                        for view in cell.subviews {
                            if view is UIButton { accessoryView = view }
                        }
                        alert.popoverPresentationController?.sourceRect = accessoryView!.bounds
                        alert.popoverPresentationController?.sourceView = accessoryView
                        self.present(alert, animated: true)
                    }
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ((indexPath.section, indexPath.row) == (0, 1)) ? 65 : 50 //50 is default
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = [
            "My Account",
            "Locations",
            "Geofence Notifications",
            ""
        ]
        return titles[section]
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let footers = ["",
            "Contact & manage your True Pass Locations",
            "Instantly turn geofence notifications for all locations on or off.",
        ""]
        return footers[section]
    }
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            for subview in tableView.cellForRow(at: indexPath)!.subviews {
                if String(describing: subview.classForCoder) == "UITableViewCellSelectedBackground" {
                    print("made it")
                    subview.layer.cornerRadius = 5; subview.layer.masksToBounds = true
                }
            }
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
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        let cornerRadius: CGFloat = 5
        cell.backgroundColor = .clear
        
        let layer = CAShapeLayer()
        let pathRef = CGMutablePath()
        let bounds = cell.bounds.insetBy(dx: 0, dy: 0)
        var addLine = false
        
        if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        } else if indexPath.row == 0 {
            pathRef.move(to: .init(x: bounds.minX, y: bounds.maxY))
            pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.minY), tangent2End: .init(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
            pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.minY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
            pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.maxY))
            addLine = true
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            pathRef.move(to: .init(x: bounds.minX, y: bounds.minY))
            pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.maxY), tangent2End: .init(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
            pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.maxY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
            pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.minY))
        } else {
            pathRef.addRect(bounds)
            addLine = true
        }
        layer.path = pathRef
        layer.fillColor = UIColor(white: 1, alpha: 0.8).cgColor
        if (addLine == true) {
            let lineLayer = CALayer()
            let lineHeight = 1.0 / UIScreen.main.scale
            lineLayer.frame = CGRect(x: bounds.minX + 10, y: bounds.size.height - lineHeight, width: bounds.size.width - 10, height: lineHeight)
            lineLayer.backgroundColor = tableView.separatorColor?.cgColor
            layer.addSublayer(lineLayer)
            //if indexPath.row == 0 || indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 { lineLayer.backgroundColor = UIColor.clear.cgColor }
        }
        
        for subview in cell.subviews {
            if String(describing: subview.classForCoder) == "_UITableViewCellSeparatorView" {
                subview.removeFromSuperview()
            }
        }
        
        let testView = UIView(frame: bounds)
        testView.layer.insertSublayer(layer, at: 0)
        testView.backgroundColor = .clear
        cell.backgroundView = testView
        //cell.mask = UIView(frame: bounds)
        cell.mask?.backgroundColor = .white
        cell.mask?.layer.insertSublayer(layer, at: 0)
        cell.mask?.clipsToBounds = true
        cell.clipsToBounds = true
        //cell.selectedBackgroundView?.backgroundColor = UIColor.
        
    }
}

protocol DecorableCell {
    func decorate()
}

class EmailCell: UITableViewCell, DecorableCell {
    @IBOutlet weak var ownerEmailLabel: UILabel!
    @IBOutlet weak var wrapperView: UIView!
    weak var viewController: UIViewController?
    
    func decorate() {
        ownerEmailLabel.text = Accounts.userEmail
        let bottom = NSLayoutConstraint(item: wrapperView, attribute: .bottom, relatedBy: .equal, toItem: wrapperView.superview!, attribute: .bottom, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: wrapperView, attribute: .top, relatedBy: .equal, toItem: wrapperView.superview!, attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: wrapperView, attribute: .right, relatedBy: .equal, toItem: wrapperView.superview!, attribute: .right, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: wrapperView, attribute: .left, relatedBy: .equal, toItem: wrapperView.superview!, attribute: .left, multiplier: 1, constant: 0)
        bottom.isActive = true; top.isActive = true; right.isActive = true; left.isActive = true
        
    }
    @IBAction func editPressed(_ sender: Any) {
        self.viewController?.showSimpleAlert("Account Editing Unavailable", message: nil)
    }
}

class LocationCountCell: UITableViewCell, DecorableCell {
    @IBOutlet weak var locationAffiliationsLabel: UILabel!
    @IBOutlet weak var administrationNumLabel: UILabel!
    func decorate() {
        let locationCount = C.truePassLocations.count
        locationAffiliationsLabel.text = "You are affiliated with \(locationCount) location\(locationCount != 1 ? "s" : "")."
        //var adminCount = 0
        //        for location in C.truePassLocations {
        //            //if location.
        //        }
        //Use affiliations to set administrationNumLabel
    }
}

class LocationNameCell: UITableViewCell, DecorableCell {
    
    @IBOutlet weak var imageIcon: CDImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var identifier: String!
    func decorate() {}
    func decorate(for location: TPLocation) {
        if let type = TPLocationType(rawValue: location.locationType ?? "") {
            let details = TPLocationType.Details[type]
            imageIcon.image = UIImage(named: details!)
        } else {
            imageIcon.image = #imageLiteral(resourceName: "marker")
        }
        titleLabel.text = location.title
        identifier = location.identifier!
    }
}

class NotificationsCell: UITableViewCell, DecorableCell {
    @IBOutlet weak var onSwitch: UISwitch!
    func decorate() {
        onSwitch.isOn = C.receiveCheckInNotifications
    }
    @IBAction func receiveNotifications(_ onSwitch: UISwitch) {
        C.receiveCheckInNotifications = onSwitch.isOn
    }
}

class AboutCell: UITableViewCell, DecorableCell { func decorate() {} }
class DeleteCell: UITableViewCell, DecorableCell { func decorate() {} }
