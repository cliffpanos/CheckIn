//
//  FirebaseObjects.swift
//  True Pass
//
//  Created by Cliff Panos on 5/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreData

protocol TPIdentifiable {
    var identifier: String { get set }
}

extension TPUser {
    
    //public var email = String()
    //public var firstName = String()
    //public var lastName = String()
    //public var imageData = Data()
    //public var geoDevice = "none"
    //imageRef is userIdentifier
    
    //public var identifier: String = String()
    public var name: String {
        return (firstName ?? "") + " " + (lastName ?? "")
    }
    
    override var dictionaryForm: [String: Any] {
        return self.dictionaryWithValues(forKeys: ["email", "firstName", "lastName", "geoDevice"])
    }
}

extension TPLocation {
    override var dictionaryForm: [String: Any] {
        return self.dictionaryWithValues(forKeys: ["title", "shortTitle", "paid", "openType", "longitude", "latitude", "locationType", "hours", "geoType", "geofenceRadius", "affiliationCode"])
    }
}

extension TPPass {
    override var dictionaryForm: [String: Any] {
        return self.dictionaryWithValues(forKeys: ["firstName", "lastName", "email", "locationIdentifier", "phoneNumber", "isActive", "didCheckIn", "accessCodeQR"])
    }
    
    static func == (lhs: TPPass, rhs: TPPass) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension TPAffiliation {
    override var dictionaryForm: [String: Any] {
        return self.dictionaryWithValues(forKeys:["lastVisit", "isAdmin", "geoType", "canGrantPasses", "canGrantEntry", "canEnter", "accessCodeQR"])
    }
}

//class TPAffiliation: FirebaseObject {
//    
//    public var isAdministrator: Bool = false
//    public var userIdentifier = String()
//    public var locationIdentifier = String()
//    
//}
//
//class TPVisit: FirebaseObject {
//    
//}

extension TPUserList {
    //var list: [(userIdentifier: String, isAdmin: Bool)] = []
}

//class TPAffiliationList: FirebaseObject {
//    
//}
//
//class TPPassList: FirebaseObject {
//    
//}
//
//class TPVisitList: FirebaseObject {
//    
//}

extension TPLocationList {
    
}


/// A functionally abstract class to manage all Firebases-stored data objects (entities)
extension FirebaseObject {
    
    convenience init(snapshot: DataSnapshot? = nil, _ entity: FirebaseEntity, saveToCoreData: Bool = false) {

        if saveToCoreData {
            self.init(context: C.appDelegate.persistentContainer.viewContext)
        } else {
            self.init(entity: NSEntityDescription.entity(forEntityName: entity.rawValue, in: C.appDelegate.persistentContainer.viewContext)!, insertInto: nil)
        }
        
        guard let snapshot = snapshot else { return }
        for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
            let key = String(child.key.characters.filter { !" \n\t\r".characters.contains($0) })
            if responds(to: Selector(key)) {
                if key == "startDate" || key == "endDate" {
                    setValue(Date(timeIntervalSince1970: TimeInterval(child.value as! Double)), forKey: key)
                } else {
                    setValue(child.value, forKey: key)
                }

            }
        }
    }
    
    @objc var dictionaryForm: [String: Any] {
        return [String: Any]()
    }
}
