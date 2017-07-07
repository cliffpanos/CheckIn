//
//  GeoLocationManager.swift
//  True Pass
//
//  Created by Cliff Panos on 5/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreLocation


class GeoLocationManager {
    
    static var nearestLocation: TPLocation? {
        if C.truePassLocations.isEmpty { return nil }
        
        return C.truePassLocations[0] //TODO create nearest algorithm
    }
    
    
    
}
