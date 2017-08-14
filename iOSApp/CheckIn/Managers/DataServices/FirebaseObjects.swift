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

protocol TPIdentifiable {
    var identifier: String { get set }
}

class FTPUser: FirebaseObject, TPIdentifiable {
    
    public var email = String()
    public var firstName = String()
    public var lastName = String()
    public var imageData = Data()
    public var geoDevice = "none"
    //imageRef is userIdentifier
    
    public var identifier: String = String()
    public var name: String {
        return firstName + " " + lastName
    }
    
    override var dictionaryForm: [String: Any] {
        return self.dictionaryWithValues(forKeys: ["email", "firstName", "lastName", "geoDevice"])
    }
}

class FTPLocation: FirebaseObject, TPIdentifiable {

    public var title = String()
    public var shortTitle = String()
    public var identifier: String = String()

}

class FTPPass: FirebaseObject, TPIdentifiable {

    public var identifier: String = String()

}

class FTPAffiliation: FirebaseObject {
    
    public var isAdministrator: Bool = false
    public var userIdentifier = String()
    public var locationIdentifier = String()
    
}

class FTPVisit: FirebaseObject {
    
}

class FTPUserList: FirebaseObject {
    
}

class FTPAffiliationList: FirebaseObject {
    
}

class FTPPassList: FirebaseObject {
    
}

class FTPVisitList: FirebaseObject {
    
}


/// A functionally abstract class to manage all Firebases-stored data objects (entities)
class FirebaseObject: NSObject {
    
    override init() {
        super.init()
    }
    
    required init(snapshot: DataSnapshot) {
        
        super.init()
        
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
