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
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTypePicker: LocationTypePicker!
    
    var textFieldManager: CPTextFieldManager!
    var location: TPLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        textFieldManager = CPTextFieldManager(textFields: [fullLocationTitleTextField, shortLocationTitleTextField, locationTypeTextField, openTimeTextField, closeTimeTextField, accessCodeTextField], in: self)
        
        openTimeTextField.inputView = timePicker
        openTimeTextField.tintColor = UIColor.clear
        closeTimeTextField.inputView = timePicker
        closeTimeTextField.tintColor = UIColor.clear
        textFieldManager.setupTextFields(withAccessory: .done)
        textFieldManager.setFinalReturn(keyType: .go) { [unowned self] in self.createNewLocation()}
        accessCodeTextField.text! += "-\(arc4random())"
        
        locationTypeTextField.inputView = locationTypePicker
        locationTypePicker.changeCallback = { [unowned self](type: TPLocationType) in
            self.locationTypeValueChanged(to: type)
        }
        LocationManager.zoomToUserLocation(in: mapView)

    }
    
    @IBAction func timeValueChanged(_ picker: UIDatePicker) {
        let textField = openTimeTextField.isEditing ? openTimeTextField : closeTimeTextField
        let text = DateFormatter.localizedString(from: picker.date, dateStyle: .none, timeStyle: .short)
        textField?.text = text
    }
    
    func locationTypeValueChanged(to type: TPLocationType) {
        self.locationTypeTextField.text = type.rawValue
    }
    
    var circleGeofence: MKCircle?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let location = location {
            if let current = mapView.annotations.first {
                mapView.removeAnnotation(current)
            }
            mapView.addAnnotation(location)
            LocationManager.zoom(to: location.coordinate, in: mapView, sizeDelta: 0.0001)
            self.location = location
            circleGeofence = MKCircle(center: location.coordinate, radius: CLLocationDistance(radiusSlider.value))
            mapView.add(circleGeofence!)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let circle = circleGeofence {
            mapView.remove(circle)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AV")
        view.tintColor = UIColor.TrueColors.softRed
        return view
    }

    
    @IBAction func cancelPressed(_ sender: Any) {
        if (fullLocationTitleTextField.text ?? "").isEmptyOrWhitespace()
            && (shortLocationTitleTextField.text ?? "").isEmptyOrWhitespace()
            && location == nil {
            self.dismiss(animated: true)
            return
        }
        self.showDestructiveAlert("Exit Location Creation?", message: "Any entered information will be lost.", destructiveTitle: "Exit Location Creation", popoverSetup: nil, withStyle: .alert, forDestruction: {_ in self.dismiss(animated: true)})
    }

    @IBAction func geofenceRadiusChanged(_ sender: Any) {
        
        guard let slider = sender as? UISlider else { return }
        let section = tableView.footerView(forSection: 1)
        section?.textLabel?.text = "Users will automatically check into your location via geofence when they are within \(Int(slider.value)) meters."
        if let circle = circleGeofence, let location = location {
            mapView.remove(circle)
            circleGeofence = MKCircle(center: location.coordinate, radius: CLLocationDistance(slider.value))
            mapView.add(circleGeofence!)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.white
            circle.fillColor = UIColor.TrueColors.lightBlue.withAlphaComponent(0.35)
            circle.lineWidth = 1
            return circle
        } else {
            return MKPolylineRenderer()
        }
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
            tableView.deselectRow(at: indexPath, animated: true)
            createNewLocation()
        }
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath == IndexPath(row: 1, section: 0) {
            self.showSimpleAlert("Short Titles", message: "Short Titles should be up to 15 characters long. For example, 'Apple Inc. Headquarters' could choose 'Apple HQ' as its short title.")
        }
    }
    
    
    
    func createNewLocation() {
        
        guard DatabaseManager.isConnected else {
            showSimpleAlert("Connection Unavailable", message: "The location cannot be created at this time because True Pass is unable to connect to the internet.")
            return
        }
        
        guard let title = fullLocationTitleTextField.text?.trimmed, let shortTitle = shortLocationTitleTextField.text?.trimmed, let type = locationTypeTextField.text?.trimmed, let accessCode = accessCodeTextField.text?.trimmed else {
            self.showSimpleAlert("Incomplete Fields", message: "Ensure that you have completed all location details at the top and entered an access code.")
            return
        }
        
        guard let location = location else {
            showSimpleAlert("No Location Chosen", message: "You must explicitly chose the coordinates of your new location.")
            return
        }
        
        if title.characters.count < 3 {
            showSimpleAlert("Enter a title at least 3 characters long.", message: nil)
            return
        }
        if title.characters.count > 50 {
            showSimpleAlert("Title too long", message: "Please enter a location title that is fewer than 50 characters long.")
            return
        }
        if shortTitle.characters.count > 15 {
            showSimpleAlert("Short Title Too Long", message: "Short titles should be fewer than 16 characters.")
            return
        }
        guard let locationType = TPLocationType(rawValue: type) else {
            showSimpleAlert("Invalid Location Type", message: "The location type that you entered is invalid.")
            return
        }
        if accessCode.characters.count < 8 {
            showSimpleAlert("Create a more secure Access Code", message: "Make sure the access code you choose is at least 8 characters long.")
            return
        }
        if accessCode.characters.count > 100 {
            showSimpleAlert("Access code too long", message: "Please enter an access code that is fewer than 100 characters long.")
        }
        
        let openTime: String? = openTimeTextField.text?.trimmed
        let closeTime: String? = closeTimeTextField.text?.trimmed
        
        //Hours of operation are optional, but if some were entered, validate them.
        if let open = openTime, let close = closeTime {
            let dateFormat = DateFormatter()
            dateFormat.dateStyle = .none
            dateFormat.timeStyle = .short
            guard let _ = dateFormat.date(from: open), let _ = dateFormat.date(from: close) else {
                showSimpleAlert("Incorrect Time Format", message: "The open time and/or close time is incorrectly formatted.")
                return
            }
        }
        
        
        //Then the data is ready to be entered into Firebase
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let newLocationToEnter = TPLocation(.TPLocation)
        newLocationToEnter.title = title
        newLocationToEnter.shortTitle = shortTitle
        newLocationToEnter.locationType = locationType.rawValue
        newLocationToEnter.coordinate = location.coordinate
        newLocationToEnter.geofenceRadius = Double(radiusSlider.value)
        newLocationToEnter.hours = "\(openTime ?? "")-\(closeTime ?? "")"
        print("New Location hours: '\(openTime ?? "")-\(closeTime ?? "")'")
        newLocationToEnter.affiliationCode = accessCode
        
        LocationManager.createNewLocation(newLocationToEnter)
//        let identifier = LocationManager.createNewLocation(title: title, shortTitle: shortTitle, locationType: locationType, coordinate: location.coordinate, geofenceRadius: Double(radiusSlider.value), openTime: openTime, closeTime: closeTime, accessCode: accessCode)
        
        //NEEDS TO BE IN COMPLETION OF ABOVE
        let locationCheck = FirebaseService(entity: .TPLocation)
        locationCheck.retrieveData(forIdentifier: newLocationToEnter.identifier!, completion: {_ in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            print("retrieved new location successfully!!")
            self.showSimpleAlert("Location Creation Successful", message: "\(title) is ready for True Pass.", handler: {self.dismiss(animated: true)})
        })
        //let n = NSTimed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pvc = segue.destination as? PinSelectionViewController {
            pvc.location = location
        }
    }


    
}
