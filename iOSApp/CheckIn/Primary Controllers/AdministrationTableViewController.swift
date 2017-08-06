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
        
        GeoLocationManager.address(for: location.clLocation) {
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


    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
