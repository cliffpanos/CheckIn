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

class FTPUser: FirebaseObject {
    
    public var email = String()
    public var userIdentifier = String()
    
    override var dictionaryForm: [String: Any] {
        return self.dictionaryWithValues(forKeys: ["email"])
    }
}

class FTPLocation: FirebaseObject {

    public var locationIdentifier: String = ""

}

class FPass: FirebaseObject {

    public var passIdentifier: String = ""

}

class FAffiliation : FirebaseObject {
    
    public var isAdministrator: Bool = false
    public var userIdentifier = String()
    public var locationIdentifier = String()
    
}


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
