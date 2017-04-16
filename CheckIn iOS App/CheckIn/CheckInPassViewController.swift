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
    
    var screenBrightness: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenBrightness = UIScreen.main.brightness

        let image = C.generateQRCode(forMessage:
            "\(C.nameOfUser)|" +
            "\(C.emailOfUser)|" +
            "\(C.locationName)"
            , withSize: qrCodeImageView.frame.size)
        
        qrCodeImageView.image = image
        
        ownerLabel.text = "\(C.nameOfUser)'s Pass"
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.main.brightness = screenBrightness
    }

    @IBAction func onDonePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewPanned(_ sender: Any) {
        print(panGestureRecognizer.velocity(in: self.view).y)
        if (panGestureRecognizer.velocity(in: self.view).y > 750) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
