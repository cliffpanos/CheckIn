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
    
    static let enumerated: [TPLocationType] = [.Home, .Work, .Apartment, .School, .Event, .Organization, .Other]
    
    static let Details: [TPLocationType: String] = [
        Home : "Home",
        Work : "Work",
        Apartment : "Apartment",
        School : "School",
        Event : "Event",
        Organization : "Organization",
        Other : "Other",
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

extension TPPass {
    
   /* @nonobjc public class func fetchRequest() -> NSFetchRequest<TPPass> {
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
    */
    public var name: String {
        return (firstName ?? "") + " " + (lastName ?? "")
    }
    
}

//class TPVisit: FirebaseObject {
//}

//MARK: - Shared Models for TPLocation, TPUser, and Pass from CoreData ENTITIES

extension TPLocation: MKAnnotation {
    
//    @NSManaged public var affiliationCode: String!
//    @NSManaged public var geofenceRadius: NSNumber!
//    @NSManaged public var geoType: String!
//    @NSManaged public var hours: String?
////    @NSManaged public var
////    @NSManaged public var
////    @NSManaged public var
////    @NSManaged public var
////    @NSManaged public var
////    @NSManaged public var
////    @NSManaged public var
////    @NSManaged public var
//    var longitude: Double!
//    var latitude: Double!
//    var title: String?
//    var shortTitle: String?
//    var locationType: String?
//    var geofenceRadius: CLLocationDegrees?
    
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
    
    static func == (lhs: TPLocation, rhs: TPLocation) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}




