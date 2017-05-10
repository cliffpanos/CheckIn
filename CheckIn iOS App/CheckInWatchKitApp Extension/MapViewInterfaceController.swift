//
//  MapViewInterfaceController.swift
//  TruePassWatchKitApp Extension
//
//  Created by Cliff Panos on 4/16/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class MapViewInterfaceController: ManagedInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var mapView: WKInterfaceMap!
    var checkInLocations = [CLLocationCoordinate2D]()
    var locationManager: CLLocationManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        getCoreLocations()
        locationManager.startUpdatingLocation()

    }
    
    func getCoreLocations() {
        ExtensionDelegate.session?.sendMessage(["Activity" : "MapRequest"], replyHandler: {
            message in
            guard message["Activity"] as? String == "MapReply", let latitude = message["latitude"], let longitude = message["longitude"] else {
                return
            }
            
            self.checkInLocations = [CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)]
            for location in self.checkInLocations {
                self.mapView.addAnnotation(location, with: .red)
            }
            
            let region = MKCoordinateRegion(center: self.checkInLocations[0], span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.mapView.setRegion(region)
            
        }, errorHandler: {error in print(error)})
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        if checkInLocations.count == 0 {
            getCoreLocations()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
