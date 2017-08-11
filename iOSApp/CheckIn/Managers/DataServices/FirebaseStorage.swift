//
//  FirebaseStorage.swift
//  True Pass
//
//  Created by Cliff Panos on 6/14/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class FirebaseStorage {
    
    ///The shared FirebaseStorage object
    static let shared = FirebaseStorage()
    let storage: Storage
    let storageRef: StorageReference
    
    internal init() {
        storage = Storage.storage()
        storageRef = storage.reference()
    }
    
    var usersDirectoryReference: StorageReference {
        return storageRef.child("TPUsers")
    }
    var locationsDirectoryReference: StorageReference {
        return storageRef.child("TPLocations")
    }
    var passesDirectoryReference: StorageReference {
        return storageRef.child("TPPasses")
    }
    var pngMetadata: StorageMetadata {
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        return metadata
    }
    
    func uploadProfilePicture(data: Data, for user: FTPUser, _ handler: @escaping (StorageMetadata?, Error?) -> Void) {
        let childRef = usersDirectoryReference.child("\(user.userIdentifier).png")
        childRef.putData(data, metadata: pngMetadata) { metadata, error in
            handler(metadata, error) }
    }
    
    func uploadpassPicture(data: Data, for pass: FPass) {
        
    }
    
    func uploadLocationPicture(data: Data, for location: FTPLocation) {
        
    }
    
    func retrieveProfilePicture(for uid: String, _ handler: @escaping (Data?, Error?) -> Void) {
        let childRef = usersDirectoryReference.child("\(uid).png")
        childRef.getData(maxSize: 4*1024*1024, completion: {data, error in
            handler(data, error)
        })
    }
    
    func retrieveProfilePictureForCurrentUser(_ handler: @escaping (Data?, Error?) -> Void) {
        if let current = Accounts.shared.current?.uid {
            retrieveProfilePicture(for: current, handler)
        }
    }
    
    
    
    
}
