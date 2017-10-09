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
    
    case TPPayment
    case TPLocationTileList
    case TPLocationKeywordList
    
    case TPAffiliationList
    case TPUserList
    case TPPassList //A list using the USER that created it as a key and ALSO the location that it has as a key
    case TPVisitList
    case TPLocationList //???does not exist because Users only ever have very few locations, so worrying about nesting would be unncessary as we are on the order of magnitude of 10^1
    
}

class FirebaseService : NSObject {
    var reference: DatabaseReference!
    var entity: FirebaseEntity
    
    init(entity: FirebaseEntity) {
        self.entity = entity
        self.reference = Database.database().reference().child(entity.rawValue)
        super.init()
    }
    
    func retrieveData(forIdentifier identifier: String, completion: @escaping ((FirebaseObject) -> Void)) {
        reference.child(identifier).observeSingleEvent(of: .value, with: { snapshot in
            let data = self.createTPEntity(from: snapshot)
            completion(data)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func retrieveList(forIdentifier identifier: String, completion: @escaping ([String: Any]) -> Void) {
        reference.child(identifier).observeSingleEvent(of: .value, with: { snapshot in
            var pairs = [String: Any]()
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                pairs[child.key] = child.value!
            }
            completion(pairs)
        })
    }
    
    func enterData(forIdentifier identifier: String, data: FirebaseObject) {
        reference.child(identifier).setValue(data.dictionaryForm)
    }
    
    func addChildData(forIdentifier identifier: String, key: String, value: Any) {
        reference.child(identifier).child(key).setValue(value)
    }
    
    func deleteData(forIdentifier identifier: String) {
       reference.child(identifier).removeValue()
    }
    
    func continuouslyObserveData(withIdentifier identifier: String, completion: @escaping ((FirebaseObject) -> Void)) {
        reference.child(identifier).observe(.value, with: { snapshot in
            let data = self.createTPEntity(from: snapshot)
            completion(data) }) { error in
                print(error.localizedDescription)
        }
    }
    
    
    func retrieveAll(completion: @escaping (([FirebaseObject]) -> Void)) {
        reference.observeSingleEvent(of: .value, with: {
            (snapshot) in
                var result : [FirebaseObject] = [FirebaseObject]()
                for child in snapshot.children {
                    result.append(self.createTPEntity(from: child as! DataSnapshot))
                }
                completion(result)
            })
    }
    
    var newIdentifierKey: String {
        let key = reference.childByAutoId().key
        
        return key
    }
    
    private func createTPEntity(from snapshot: DataSnapshot) -> FirebaseObject {
        
        switch entity {
        case FirebaseEntity.TPUser:
            let user = TPUser(snapshot: snapshot, entity)
            user.identifier = snapshot.key
            return user
            
        case .TPAffiliation:
            let affiliation = TPAffiliation(snapshot: snapshot, entity)
            affiliation.identifier = snapshot.key
            //TODO
            return affiliation
            
        case .TPLocation:
            let location = TPLocation(snapshot: snapshot, entity)
            location.identifier = snapshot.key
            return location
            
        case .TPPass:
            let pass = TPPass(snapshot: snapshot, entity)
            pass.identifier = snapshot.key
            return pass
            
        case .TPVisit:
            let visit = TPVisit(snapshot: snapshot, entity)
            return visit
        
        case .TPAffiliationList:
            let affiliationList = TPAffiliationList(snapshot: snapshot, entity)
            return affiliationList
            
        case .TPLocationList:
            let locationList = TPLocationList(snapshot: snapshot, entity)
            return locationList

        case .TPUserList:
            let userList = TPUserList(snapshot: snapshot, entity)
            return userList
        
        case .TPVisitList:
            let visitList = TPVisit(snapshot: snapshot, entity)
            return visitList
        
        case .TPPassList:
            let passList = TPPassList(snapshot: snapshot, entity)
            return passList
        
        case .TPPayment:
            let payment = TPPayment(snapshot: snapshot, entity)
            return payment
        
        default: break
        
        }
        return FirebaseObject(.TPAffiliation) //DUMMY CODE
    }

}
