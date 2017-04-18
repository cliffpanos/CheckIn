//
//  MapViewInterfaceController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/16/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class MapViewInterfaceController: WKInterfaceController {

    @IBOutlet var mapView: WKInterfaceMap!
    var checkInLocations = [CLLocationCoordinate2D]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        ExtensionDelegate.session?.sendMessage(["Activity" : "MapRequest"], replyHandler: {
            message in
            guard let locations = message["MapReply"] else {
                return
            }
            self.checkInLocations = locations as! [CLLocationCoordinate2D]
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
        WC.currentlyPresenting = self
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
