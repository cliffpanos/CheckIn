//
//  GeofenceManager.swift
//  True Pass
//
//  Created by Cliff Panos on 5/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreLocation


class GeofenceManager {
    
    static var locationManager: CLLocationManager = LocationManager.sharedLocationManager
    static let thisDeviceUUID = UIDevice.current.identifierForVendor
    
    class var deviceIsAssignedToMonitor: Bool {
        get { return C.getFromUserDefaults(withKey: "deviceIsAssignedToMonitor") as? Bool ?? false}
        set { C.persistUsingUserDefaults(newValue, forKey: "deviceIsAssignedToMonitor")}
    }
    
    static func validateGeofenceMonitoring() {
        
        guard deviceIsAssignedToMonitor else {
            return
        }
        
        let regions = locationManager.monitoredRegions

        for location in C.truePassLocations {
            //ensure that the updated pass has been received
        }
    }
    
    static func createGeofence(for location: TPLocation) {
        let _ = LocationManager.sharedLocationManager.maximumRegionMonitoringDistance
    }


    //https://www.raywenderlich.com/136165/core-location-geofencing-tutorial
    







}
