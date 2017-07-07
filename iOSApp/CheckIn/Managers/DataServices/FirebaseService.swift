//
//  FirebaseService.swift
//  True Pass
//
//  Created by Cliff Panos on 5/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import Firebase
import FirebaseDatabase

enum FirebaseEntity: String {
    case FAffiliation
    case FTPUser
    case FTPLocation
    case FPass
}

class FirebaseService : NSObject {
    var database: DatabaseReference!
    var entity: FirebaseEntity?
    
    override init() {
        super.init()
        database = Database.database().reference()
    }
    
    convenience init(entity: FirebaseEntity) {
        self.init()
        self.entity = entity
    }
    
    func enterData(forIdentifier identifier: String, data: FirebaseObject) {
        if let entity = entity {
            self.database.child(entity.rawValue).child(identifier).setValue(data.dictionaryForm)
        } else {
            print("Unable to enter data. Desired entity not set.")
        }
    }
    
    func deleteData(forIdentifier identifier: String) {
        if let entity = entity {
            self.database.child(entity.rawValue).child(identifier).removeValue()
        } else {
            print("Unable to remove data. Desired entity is not set.")
        }
    }
    
    func retrieveData(forIdentifier identifier: String, completion: @escaping ((FirebaseObject) -> Void)) {
        if let entity = entity {
            database.child(entity.rawValue).child(identifier).observeSingleEvent(of: .value, with: { (snapshot) in
                let data = self.createEntity(from: snapshot)
                completion(data)
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            print("Unable to retrieve data. Desired entity not set")
        }
        
    }
    
    func retrieveAll(completion: @escaping (([FirebaseObject]) -> Void)) {
        if let entity = entity {
            database.child(entity.rawValue).observeSingleEvent(of: .value, with: {
                (snapshot) in
                
                var result : [FirebaseObject] = [FirebaseObject]()
                for child in snapshot.children {
                    result.append(self.createEntity(from: child as! DataSnapshot))
                }
                completion(result)
            })
        }
    }
    
    var key: String {
        let key = database.child((entity?.rawValue)!).childByAutoId().key
        
        return key
    }
    
    private func createEntity(from snapshot: DataSnapshot) -> FirebaseObject {
        
        switch entity! {
        case .FTPUser:
            let user = FTPUser(snapshot: snapshot)
            user.userIdentifier = snapshot.key
            return user
            
        case .FAffiliation:
            let affiliation = FAffiliation(snapshot: snapshot)
            affiliation.userIdentifier = snapshot.key
            //TODO
            return affiliation
            
        case .FTPLocation:
            let location = FTPLocation(snapshot: snapshot)
            location.locationIdentifier = snapshot.key
            return location
            
        case .FPass:
            let pass = FPass(snapshot: snapshot)
            pass.passIdentifier = snapshot.key
            return pass
        }
    }
    
}
