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
    case Organization
    case Other
    
    static let Details: [TPLocationType: (iconName: String, colorA: UIColor, colorB: UIColor)] = [
        Home : ("Home", UIColor.TrueColors.blue, UIColor.TrueColors.lightBlue),
        Work : ("Work", UIColor.TrueColors.oceanic, UIColor.TrueColors.sandy),
        Other : ("truePassLaunch", UIColor.TrueColors.lightBlueGray, UIColor.TrueColors.lightestBlueGray),
        ]
}

enum TPLocationOpenType: Int {
    case allKnown
    case usersAndAdmins
    case adminsOnly
    case closed
}

enum TPLocationGeoType: Int {
    case entry
    case exit
    case bidirectional
    case none
}

enum TPVisitEntryType {
    case geofence
    case scannedByUser(String)
}

enum TPUserGeoDeviceType {
    case none
    case iPhone(String)
    case Android(String)
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

class TPPass: FirebaseObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TPPass> {
        return NSFetchRequest<TPPass>(entityName: "TPPass")
    }
        
    @NSManaged public var accessCodeQR: String?
    @NSManaged public var didCheckIn: Bool
    @NSManaged public var email: String?
    @NSManaged public var endDate: String?
    @NSManaged public var firstName: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var locationIdentifier: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var startDate: String?
    @NSManaged public var uid: String?
    @NSManaged public var imageData: NSData?
    
    public var name: String {
        return (firstName ?? "") + " " + (lastName ?? "")
    }
    
}

//MARK: - Shared Models for TPLocation, TPUser, and Pass from CoreData ENTITIES

class TPLocation: FirebaseObject, MKAnnotation {
    
    var longitude: Double!
    var latitude: Double!
    var title: String?
    var shortTitle: String?
    var locationType: String?
    var geofenceRadius: CLLocationDegrees?
    
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
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




