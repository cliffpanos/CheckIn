//
//  CheckInPassViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import QRCoder

class CheckInPassViewController: UIViewController {

    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let generator = QRCodeGenerator()
        let image: QRImage = generator.createImage(value:
            "\(C.nameOfUser)|" +
            "\(C.emailOfUser)|" +
            "\(C.locationName)"
            , size: qrCodeImageView.frame.size)!
        
        qrCodeImageView.image = image as UIImage
        
        ownerLabel.text = "\(C.nameOfUser)'s Pass"
        
    }

    @IBAction func onDonePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewPanned(_ sender: Any) {
    
        if (panGestureRecognizer.velocity(in: self.view).y > 1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
