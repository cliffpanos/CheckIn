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
    
    class var deviceIsAssignedToMonitor: Bool {
        get { return C.getFromUserDefaults(withKey: "deviceIsAssignedToMonitor") as? Bool ?? false}
        set { C.persistUsingUserDefaults(newValue, forKey: "deviceIsAssignedToMonitor")}
    }
    
    static func validateGeofenceMonitoring() {
        //TODO
    }
    














}
