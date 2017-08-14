//
//  AdministrationTableViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 8/3/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MapKit

class AdministrationTableViewController: UITableViewController {
    
    var location: TPLocation!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var shortTitleLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = location.title
        shortTitleLabel.text = location.shortTitle?.localizedUppercase
        
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: false)
        
        let typeDetails = TPLocationType.Details[location.type]!
        locationIcon.image = UIImage(named: typeDetails.iconName)
        
        LocationManager.address(for: location.clLocation) {
            address, error in
            if let address = address, let city = address["City"] as? String, let state = address["State"] as? String {
                self.cityStateLabel.text = "\(city) • \(state)"
            } else {
                self.cityStateLabel.text = "Details Unavailable"
            }
        }
        
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    

}
