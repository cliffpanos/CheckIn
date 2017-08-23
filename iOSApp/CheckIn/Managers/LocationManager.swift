//
//  LocationManager.swift
//  True Pass
//
//  Created by Cliff Panos on 8/13/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseDatabase

class LocationManager {
    
    static var sharedLocationManager = CLLocationManager()
    
    static var userLocation: CLLocation? {
        return sharedLocationManager.location
    }
    
    static var nearestLocation: TPLocation? {
        if C.truePassLocations.isEmpty { return nil }
        
        return C.nearestTruePassLocations[0]
    }
    
    
    ///Database function
    static func createNewLocation(title: String, shortTitle: String, locationType: TPLocationType, coordinate: CLLocationCoordinate2D, geofenceRadius: CLLocationDistance, openTime: String?, closeTime: String?, accessCode: String) -> String {
        
        //let location = FTPLocation(snapshot: nil)
        let locationService = FirebaseService(entity: .TPLocation)
        let identifier = locationService.identifierKey
        //locationService.enterData(forIdentifier: identifier, data: )
        return identifier //the new identifier of the location
    }
    
    
    
    
    
    static func chooseMapType(for mapView: MKMapView, from button: UIButton, arrow direction: UIPopoverArrowDirection, in viewController: UIViewController) {
        func changeTo(mapType: MKMapType) {
            mapView.mapType = mapType
        }
        let alert = UIAlertController(title: "Map Type", message: nil, preferredStyle: .actionSheet)
        let standard = UIAlertAction(title: "Standard", style: .default) {_ in changeTo(mapType: .standard)}
        let satellite = UIAlertAction(title: "Satellite", style: .default) {_ in changeTo(mapType: .satellite)}
        let hybrid = UIAlertAction(title: "Hybrid", style: .default) {_ in changeTo(mapType: .hybrid)}
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in alert.dismiss(animated: true) })
        alert.addAction(standard); alert.addAction(satellite); alert.addAction(hybrid); alert.addAction(cancel)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = button
            popover.sourceRect = button.bounds
            popover.permittedArrowDirections = [direction]
        }
        viewController.present(alert, animated: true)
    }
    
    static func zoomClose(to location: CLLocationCoordinate2D, in mapView: MKMapView) {
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(newRegion, animated: true)
    }
    
    static func zoom(to location: CLLocationCoordinate2D, in mapView: MKMapView, sizeDelta: Double = 0.05) {
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: sizeDelta, longitudeDelta: sizeDelta))
        mapView.setRegion(newRegion, animated: true)
    }
    
    static func zoomToUserLocation(in mapView: MKMapView) {
        guard let location = userLocation else { return }
        let newRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(newRegion, animated: true)
    }
    
    
}



//MARK: - Utility functions
extension LocationManager {
    
    static func address(for location: CLLocation, completion: @escaping (_ address: [String: Any]?, _ error: Error?) -> ()) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            
            if let error = error {
                completion(nil, error)
            } else {
                
                let placeMark = placemarks?[0]
                
                guard var address = placeMark?.addressDictionary  as? [String: Any] else {
                    return
                }
                address["InlandWater"] = placeMark?.inlandWater
                address["Ocean"] = placeMark?.ocean
                
                completion(address, nil)
                
            }
            
        }
    }
}
