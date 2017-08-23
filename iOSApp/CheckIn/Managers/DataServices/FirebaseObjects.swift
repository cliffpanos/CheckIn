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

    //public var title = String()
    //public var shortTitle = String()
    //public var identifier: String = String()

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

class TPUserList: FirebaseObject {
    
}

class TPAffiliationList: FirebaseObject {
    
}

class TPPassList: FirebaseObject {
    
}

class TPVisitList: FirebaseObject {
    
}


/// A functionally abstract class to manage all Firebases-stored data objects (entities)
extension FirebaseObject {
    
    convenience init(snapshot: DataSnapshot) {
        
        self.init()
        //super.init()
        
        for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
            let key = String(child.key.characters.filter { !" \n\t\r".characters.contains($0) })
            if responds(to: Selector(key)) {
                setValue(child.value, forKey: key)
            }
        }
    }
    
    var dictionaryForm: [String: Any] {
        return [String: Any]()
    }
}
