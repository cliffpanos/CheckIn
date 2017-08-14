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
    case FTPAffiliation
    case FTPUser
    case FTPLocation
    case FTPPass
    case FTPVisit
    
    case FTPAffiliationList
    case FTPUserList
    case FTPPassList
    case FTPVisitList
    //case FTPLocationList does not exist because Users only ever have very few locations, so worrying about nesting would be unncessary as we are on the order of magnitude of 10^1
    
}

class FirebaseService : NSObject {
    var database: DatabaseReference!
    var entity: FirebaseEntity
    
    init(entity: FirebaseEntity) {
        self.entity = entity
        self.database = Database.database().reference()
        super.init()
    }
    
    func retrieveData(forIdentifier identifier: String, completion: @escaping ((FirebaseObject) -> Void)) {
        database.child(entity.rawValue).child(identifier).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = self.createFTPEntity(from: snapshot)
            completion(data)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func enterData(forIdentifier identifier: String, data: FirebaseObject) {
        self.database.child(entity.rawValue).child(identifier).setValue(data.dictionaryForm)
    }
    
    func deleteData(forIdentifier identifier: String) {
       self.database.child(entity.rawValue).child(identifier).removeValue()
    }
    
    func continuouslyObserveData(withIdentifier identifier: String, completion: @escaping ((FirebaseObject) -> Void)) {
        database.child(entity.rawValue).child(identifier).observe(.value, with: { snapshot in
            let data = self.createFTPEntity(from: snapshot)
            completion(data) }) { error in
                print(error.localizedDescription)
        }
    }
    
    
    func retrieveAll(completion: @escaping (([FirebaseObject]) -> Void)) {
        database.child(entity.rawValue).observeSingleEvent(of: .value, with: {
            (snapshot) in
                var result : [FirebaseObject] = [FirebaseObject]()
                for child in snapshot.children {
                    result.append(self.createFTPEntity(from: child as! DataSnapshot))
                }
                completion(result)
            })
    }
    
    var key: String {
        let key = database.child(entity.rawValue).childByAutoId().key
        
        return key
    }
    
    private func createFTPEntity(from snapshot: DataSnapshot) -> FirebaseObject {
        
        switch entity {
        case FirebaseEntity.FTPUser:
            let user = FTPUser(snapshot: snapshot)
            user.identifier = snapshot.key
            return user
            
        case .FTPAffiliation:
            let affiliation = FTPAffiliation(snapshot: snapshot)
            affiliation.userIdentifier = snapshot.key
            //TODO
            return affiliation
            
        case .FTPLocation:
            let location = FTPLocation(snapshot: snapshot)
            location.locationIdentifier = snapshot.key
            return location
            
        case .FTPPass:
            let pass = FTPPass(snapshot: snapshot)
            pass.passIdentifier = snapshot.key
            return pass
            
        case .FTPVisit:
            let visit = FTPVisit(snapshot: snapshot)
            return visit
        
        case .FTPAffiliationList:
            let affiliationList = FTPAffiliationList(snapshot: snapshot)
            return affiliationList

        case .FTPUserList:
            let userList = FTPUserList(snapshot: snapshot)
            return userList
        
        case .FTPVisitList:
            let visitList = FTPVisit(snapshot: snapshot)
            return visitList
        
        case .FTPPassList:
            let passList = FTPPassList(snapshot: snapshot)
            return passList
        }
    }
    
}
