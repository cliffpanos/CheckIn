//
//  DatabaseManager.swift
//  True Pass
//
//  Created by Cliff Panos on 5/12/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import FirebaseDatabase
import Foundation

///Contains high-level methods for retrieving & modifying data from the FirebaseDatabase as well as interacting with Core Data
class DatabaseManager {
    
    static let shared = DatabaseManager()
    var connectedReference: DatabaseReference!
    
    init() {
        connectedReference = Database.database().reference(withPath: ".info/connected")
        connectedReference.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected to Database!")
            } else {
                print("Not connected to Database!")
            }
        })
    }
    
    
    
    
    
    
    
    
    
    
}

