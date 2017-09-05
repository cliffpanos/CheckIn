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
    static var isConnected: Bool = false
    internal var connectedReference: DatabaseReference!
    
    init() {
        print("Monitoring for connection")
        connectedReference = Database.database().reference(withPath: ".info/connected")
        connectedReference.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected to Database!")
                DatabaseManager.isConnected = true
            } else {
                print("Not connected to Database!")
                DatabaseManager.isConnected = false
            }
        })
    }
    
    /*
    
    Add haptics to pin drop
     
    For enums: store the raw Int value in Firebase, not a string!!
     Create payment entity for security
     Add "visible" property to Locations (whether others can find the location and affiliate with it: Open, Only by Identifier, None)
     Add search by identifier to NewAffiliationList
     LocationChunkList:
        flooredLatSQUAREflooredLong
            identifier: Title
            identifier: Title
        <next chunk>
    
    LocationTitleList
        word
            identifier: type
     
    UserList:
        locationIdentifier
            userIdentifier: true or false for admin or not
     
    LocationList:
        userIdentifier
            locationIdentifier: true
            locationIdentifier: true
    
    
    */
    
    
}

