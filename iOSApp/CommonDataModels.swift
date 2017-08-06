//
//  CommonDataModels.swift
//  True Pass
//
//  Created by Cliff Panos on 6/13/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit


/** The Types of True Pass Locations */
enum TPLocationType: String {
    case Home
    case Work
    case Apartment
    case School
    case Event
    case Other
    
    static let Details: [TPLocationType: (iconName: String, colorA: UIColor, colorB: UIColor)] = [
        Home : ("Home", UIColor.TrueColors.blue, UIColor.TrueColors.lightBlue),
        Work : ("Work", UIColor.TrueColors.oceanic, UIColor.TrueColors.sandy),
        Other : ("truePassLaunch", UIColor.TrueColors.lightBlueGray, UIColor.TrueColors.lightestBlueGray),
        ]
}

/*class TPLocation: NSManagedObject {

 @nonobjc public class func fetchRequest() -> NSFetchRequest<TPLocation> {
 return NSFetchRequest<TPLocation>(entityName: "TPLocation")
 }
 
 @NSManaged public var adminIdentifiers: String?
 @NSManaged public var latitude: Double
 @NSManaged public var locationIdentifier: String?
 @NSManaged public var locationType: String?
 @NSManaged public var longitude: Double
 @NSManaged public var shortTitle: String?
 @NSManaged public var title: String?
}*/

//MARK: - Shared Models for TPLocation, TPUser, and Pass from CoreData ENTITIES

class TPLocation: NSObject, MKAnnotation {
    
    var longitude: Double!
    var latitude: Double!
    var title: String?
    var shortTitle: String?
    var locationType: String?
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    public var clLocation: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    var type: TPLocationType {
        if let theType = TPLocationType(rawValue: self.locationType ?? "") {
            return theType
        }
        return TPLocationType.Other
    }
    
}




