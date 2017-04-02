//
//  Pin.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/2/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import Foundation
import MapKit

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
