//
//  Testing.swift
//  True Pass
//
//  Created by Cliff Panos on 6/7/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import Foundation
import CoreData

class Testing {
    
    static func setupForTesting() {
        
        //load pins
        let hackGSU = (longTitle: "Georgia Tech Delta Chi", title: "GT DX",latitude: 33.7563920891773, longitude: -84.3890242522629, type: TPLocationType.Home)
        let iOSClub = (longTitle: "Georgia Tech iOS Development Club", title: "iOS Club",latitude: 33.776732102728, longitude: -84.3958815877988, type: TPLocationType.Work)
        
        var locations = [TPLocation]()
        
        for testL in [hackGSU, iOSClub] {
            let newLocation = TPLocation(.TPLocation)
            newLocation.title = testL.longTitle
            newLocation.shortTitle = testL.title
            newLocation.latitude = testL.latitude
            newLocation.longitude = testL.longitude
            newLocation.locationType = testL.type.rawValue
            
            locations.append(newLocation)
        }
        //C.truePassLocations = locations
        
    }

}
