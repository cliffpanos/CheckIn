//
//  MapViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/2/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
        //load pins
        let hackGSU = Pin(name: "HackGSU",latitude: 33.7563920891773, longitude: -84.3890242522629)
        mapView.addAnnotation(hackGSU as MKAnnotation)
        
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "CurrentLocation"), style: .done, target: self, action: #selector(zoomToLocation))
        navigationItem.rightBarButtonItem = button
        
        //https://www.raywenderlich.com/136165/core-location-geofencing-tutorial

    }
    
    func zoomToLocation() {
        let userRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(userRegion, animated: true)
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }

}



class Pin: NSObject, MKAnnotation {
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var name: String = "Pin"
    
    init(name: String, latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    public var title: String? {
        return self.name
    }
    
}



