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
    
    var initialScreenBrightness: CGFloat!
    var targetBrightness: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialScreenBrightness = UIScreen.main.brightness

        let image = C.userQRCodePass(withSize: qrCodeImageView.frame.size)
        
        qrCodeImageView.image = image
        
        ownerLabel.text = "\(C.nameOfUser)'s Pass"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        targetBrightness = 1.0
        print("current: \(UIScreen.main.brightness)")
        updateScreenBrightness()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        targetBrightness = initialScreenBrightness
        updateScreenBrightness()
    }
    
    func updateScreenBrightness() {
        let currentBrightness = UIScreen.main.brightness
        if (currentBrightness > targetBrightness + 0.03 || currentBrightness < targetBrightness - 0.03) {
            UIScreen.main.brightness += (currentBrightness < targetBrightness ? 0.03 : -0.03)
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
