//
//  FirebaseService.swift
//  True Pass
//
//  Created by Cliff Panos on 5/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import Firebase
import FirebaseDatabase

typealias FirebaseObjectCompletion = ((FirebaseObject) -> Void)

enum FirebaseEntity: String {
    case TPAffiliation
    case TPUser
    case TPLocation
    case TPPass
    case TPVisit
    
    case TPAffiliationList
    case TPUserList
    case TPPassList
    case TPVisitList
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
            let data = self.createTPEntity(from: snapshot)
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
            let data = self.createTPEntity(from: snapshot)
            completion(data) }) { error in
                print(error.localizedDescription)
        }
    }
    
    
    func retrieveAll(completion: @escaping (([FirebaseObject]) -> Void)) {
        database.child(entity.rawValue).observeSingleEvent(of: .value, with: {
            (snapshot) in
                var result : [FirebaseObject] = [FirebaseObject]()
                for child in snapshot.children {
                    result.append(self.createTPEntity(from: child as! DataSnapshot))
                }
                completion(result)
            })
    }
    
    var identifierKey: String {
        let key = database.child(entity.rawValue).childByAutoId().key
        
        return key
    }
    
    private func createTPEntity(from snapshot: DataSnapshot) -> FirebaseObject {
        
        switch entity {
        case FirebaseEntity.TPUser:
            let user = TPUser(snapshot: snapshot)
            user.identifier = snapshot.key
            return user
            
        case .TPAffiliation:
            let affiliation = TPAffiliation(snapshot: snapshot)
            affiliation.identifier = snapshot.key
            //TODO
            return affiliation
            
        case .TPLocation:
            let location = TPLocation(snapshot: snapshot)
            location.identifier = snapshot.key
            return location
            
        case .TPPass:
            let pass = TPPass(snapshot: snapshot)
            pass.identifier = snapshot.key
            return pass
            
        case .TPVisit:
            let visit = TPVisit(snapshot: snapshot)
            return visit
        
        case .TPAffiliationList:
            let affiliationList = TPAffiliationList(snapshot: snapshot)
            return affiliationList

        case .TPUserList:
            let userList = TPUserList(snapshot: snapshot)
            return userList
        
        case .TPVisitList:
            let visitList = TPVisit(snapshot: snapshot)
            return visitList
        
        case .TPPassList:
            let passList = TPPassList(snapshot: snapshot)
            return passList
        }
    }
    
}
