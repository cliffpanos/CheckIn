//
//  NewLocationTableViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 6/28/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MapKit

class LocationConstructionNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        self.delegate = self
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let show = viewController is PinSelectionViewController
        navigationController.setNavigationBarHidden(!show, animated: animated)
    }
}

class NewLocationTableViewController: UITableViewController, MKMapViewDelegate {
    
    @IBOutlet weak var fullLocationTitleTextField: UITextField!
    @IBOutlet weak var shortLocationTitleTextField: UITextField!
    @IBOutlet weak var locationTypeTextField: UITextField!
    @IBOutlet weak var accessCodeTextField: UITextField!
    @IBOutlet weak var openTimeTextField: UITextField!
    @IBOutlet weak var closeTimeTextField: UITextField!
    
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    var textFieldManager: CPTextFieldManager!
    var location: TPLocation?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        textFieldManager = CPTextFieldManager(textFields: [fullLocationTitleTextField, shortLocationTitleTextField, locationTypeTextField, openTimeTextField, closeTimeTextField, accessCodeTextField], in: self)
        textFieldManager.setupTextFields(withAccessory: .done)
        textFieldManager.setFinalReturn(keyType: .go) { [unowned self] in self.createNewLocation()}

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let location = location {
            if let current = mapView.annotations.first {
                mapView.removeAnnotation(current)
            }
            mapView.addAnnotation(location)
            LocationManager.zoomClose(to: location.coordinate, in: mapView)
            self.location = location
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AV")
        view.tintColor = UIColor.TrueColors.softRed
        return view
    }

    
    @IBAction func cancelPressed(_ sender: Any) {
        self.showDestructiveAlert("Exit Location Creation?", message: "Any entered information will be lost.", destructiveTitle: "Exit Location Creation", popoverSetup: nil, withStyle: .alert, forDestruction: {_ in self.dismiss(animated: true)})
    }

    @IBAction func geofenceRadiusChanged(_ sender: Any) {
        
        guard let slider = sender as? UISlider else { return }
        let section = tableView.footerView(forSection: 1)
        
        section?.textLabel?.text = "Users will automatically check into your location via geofence when they are \(Int(slider.value)) meters or closer."
    }
    @IBAction func chooseMapType(_ sender: UIButton) {
        LocationManager.chooseMapType(for: mapView, from: sender, arrow: [.right], in: self)
    }
    @IBAction func zoomToUserLocation(_ sender: Any) {
        LocationManager.zoomToUserLocation(in: mapView)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chooseIndex = IndexPath(row: 0, section: 1)
        let createIndex = IndexPath(row: 0, section: 4)
        if indexPath == chooseIndex {
            let pinSelectionVC = C.storyboard.instantiateViewController(withIdentifier: "pinSelectionViewController") as! PinSelectionViewController
            pinSelectionVC.location = location
            self.navigationController!.pushViewController(pinSelectionVC, animated: true)
        } else if indexPath == createIndex {
            createNewLocation()
        }
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath == IndexPath(row: 1, section: 0) {
            self.showSimpleAlert("Short Titles", message: "Short Titles should be up to 15 characters long. For example, 'Apple Inc. Headquarters' could choose 'Apple HQ' as its short title.")
        }
    }
    
    
    
    func createNewLocation() {
        
        
        
        
        
        
        
        
    }

    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
