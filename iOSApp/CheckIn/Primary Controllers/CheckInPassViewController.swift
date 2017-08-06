//
//  CheckInPassViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class CheckInPassViewController: ManagedViewController {
    
    var locationForPass: TPLocation?
    var changedBottomConstraint: Int?

    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO if locationForPass is nil, present a view controller explaining that there are no passes or locations and whatnot
        
        CheckInPassViewController.initialScreenBrightness = UIScreen.main.brightness
        
        
        let name = Accounts.currentUser.firstName
        let sLetter = name[name.characters.count - 1] == "s" ? "" : "s"
        ownerLabel.text = "\(name)'\(sLetter) Pass"
        
        if let location = locationForPass {
            locationNameLabel.text = location.title
            locationTypeLabel.text = location.type.rawValue.uppercased()
            let image = C.userQRCodePass(forLocation: location, withSize: qrCodeImageView.frame.size)
            qrCodeImageView.image = image
        }
        
        if let newConstraint = changedBottomConstraint {
            bottomConstraint.constant = CGFloat(newConstraint)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CheckInPassViewController.targetBrightness = 1.0
        CheckInPassViewController.updateScreenBrightness()
        CheckInPassViewController.presented = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CheckInPassViewController.targetBrightness = CheckInPassViewController.initialScreenBrightness
        CheckInPassViewController.updateScreenBrightness()
        CheckInPassViewController.presented = false
    }
    
    static func updateScreenBrightness() {
        let currentBrightness = UIScreen.main.brightness
        if (currentBrightness > CheckInPassViewController.targetBrightness + 0.025 || currentBrightness < CheckInPassViewController.targetBrightness - 0.025) {
            UIScreen.main.brightness += (currentBrightness < targetBrightness ? 0.025 : -0.025)
            perform(#selector(updateScreenBrightness), with: nil, afterDelay: 0.01)
        }
    }
    
    static var initialScreenBrightness: CGFloat = UIScreen.main.brightness {
        didSet {
            print("Initial B changed to: \(CheckInPassViewController.initialScreenBrightness)")
        }
    }
    static var targetBrightness: CGFloat = CheckInPassViewController.initialScreenBrightness {
        didSet {
            print("TARGET B changed to: \(CheckInPassViewController.targetBrightness)")
        }
    }
    static var presented: Bool = false {
        didSet {
            print("Presented changed to: \(CheckInPassViewController.presented)")
        }
    }
    
    
    //SEE Extensions.swift FOR UIScreen extension
    

    @IBAction func pullDownPressed(_ sender: Any) {
        onDonePressed(sender)
    }

    @IBAction func onDonePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewPanned(_ sender: Any) {
        if (panGestureRecognizer.velocity(in: self.view).y > 750) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
