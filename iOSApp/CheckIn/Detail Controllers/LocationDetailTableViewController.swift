//
//  LocationDetailTableViewController.swift & LocationDetailEmbedderController.swift
//  True Pass
//
//  Created by Cliff Panos on 7/2/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MapKit

class LocationDetailEmbedderController: UIViewController {
    
    var location: TPLocation!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var locationTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTypeLabel.text = (location.locationType ?? "Location").localizedUppercase
        let typeDetails = TPLocationType.Details[location.type]!
        backgroundImage.image = UIImage(named: "\(typeDetails)Scene")
        setNeedsStatusBarAppearanceUpdate()
    }

    
    @IBAction func donePressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func unaffiliatePressed(_sender: UIBarButtonItem) {
        print("Unaffiliate Pressed")
        //handle disaffiliation; check to see if this user is a manager and the only manager
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailController = segue.destination as! LocationDetailTableViewController
        detailController.location = location
    }
    
}

class LocationDetailTableViewController: UITableViewController {

    var location: TPLocation!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var shortTitleLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = location.title
        shortTitleLabel.text = location.shortTitle

        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: false)
        
        let typeDetails = TPLocationType.Details[location.type]!
        locationIcon.image = UIImage(named: typeDetails)

        LocationManager.address(for: location.clLocation) {
            address, error in
            if let address = address, let city = address["City"] as? String, let state = address["State"] as? String {
                self.cityStateLabel.text = "\(city) • \(state)"
            } else {
                self.cityStateLabel.text = "Details Unavailable"
            }
        }
      
    }
    
    @IBAction func notificationsToggled(_ sender: UISwitch) {
//        let notificationsOn: Bool = sender.isOn
//        TODO handle this setting
    }



    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5//4
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPassViewController" {
            let passViewController = segue.destination as! CheckInPassViewController
            passViewController.locationForPass = location
        } else if segue.identifier == "toNewGuestPass" {
            let newPassViewController = segue.destination as! NewPassNavController
            newPassViewController.preselectedLocation = location
        } else if segue.identifier == "toAdminController" {
            let adminViewController = segue.destination as! AdministrationTableViewController
            adminViewController.location = location
        }
    }
    
    

}
