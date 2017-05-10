//
//  MapViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/2/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeController: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        
        for pin in C.truePassLocations {
            mapView.addAnnotation(pin as MKAnnotation)
            let circle = MKCircle(center: pin.coordinate, radius: 0.05 as CLLocationDistance)
            self.mapView.add(circle)
        }
        
        let userbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "CurrentLocation"), style: .done, target: self, action: #selector(zoomToUserLocation))
        let checkInButton = UIBarButtonItem(image: #imageLiteral(resourceName: "checkInMapIcon"), style: .plain, target: self, action: #selector(zoomToCheckInLocation))
        navigationItem.rightBarButtonItems = [
            checkInButton, userbutton
        ]
        
        zoomToCheckInLocation()
        //https://www.raywenderlich.com/136165/core-location-geofencing-tutorial

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func mapTypeSelected(_ sender: Any) {
        let mapTypes: [MKMapType] = [.standard, .satellite, .hybrid]
        mapView.mapType = mapTypes[mapTypeController.selectedSegmentIndex]
    }
    
    func zoomToCheckInLocation() {
        let checkInLocation = C.truePassLocations[0].coordinate
        zoom(to: checkInLocation, withViewSize: 0.005)
    }
    
    func zoomToUserLocation() {
        zoom(to: mapView.userLocation.coordinate, withViewSize: 0.05)
    }
    
    func zoom(to location: CLLocationCoordinate2D, withViewSize sizeDelta: CLLocationDegrees) {
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: sizeDelta, longitudeDelta: sizeDelta))
        mapView.setRegion(newRegion, animated: true)
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.white
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

}

