//
//  CheckInPassViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class CheckInPassViewController: UIViewController {

    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    static var initialScreenBrightness: CGFloat!
    static var targetBrightness: CGFloat!
    static var presented: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CheckInPassViewController.initialScreenBrightness = UIScreen.main.brightness

        let image = C.userQRCodePass(withSize: qrCodeImageView.frame.size)
        
        qrCodeImageView.image = image
        
        ownerLabel.text = "\(C.nameOfUser)'s Pass"
        
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


    @IBAction func onDonePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewPanned(_ sender: Any) {
        if (panGestureRecognizer.velocity(in: self.view).y > 750) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
