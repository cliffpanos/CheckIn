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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = C.generateQRCode(forMessage:
            "\(C.nameOfUser)|" +
            "\(C.emailOfUser)|" +
            "\(C.locationName)"
            , withSize: qrCodeImageView.frame.size)
        
        qrCodeImageView.image = image
        
        ownerLabel.text = "\(C.nameOfUser)'s Pass"
        
    }

    @IBAction func onDonePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewPanned(_ sender: Any) {
    
        if (panGestureRecognizer.velocity(in: self.view).y > 100) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
