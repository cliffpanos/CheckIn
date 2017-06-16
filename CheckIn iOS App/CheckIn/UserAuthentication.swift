//
//  UserAuthentication.swift
//  True Pass
//
//  Created by Cliff Panos on 5/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
//import GoogleSignIn
//import FacebookCore
//import FacebookLogin

class UserAuthentication {
    
    static let shared = UserAuthentication()
    
    var current: User? {
        return Auth.auth().currentUser
    }
    
    func standardLogin(withEmail email: String, password: String, completion: @escaping ((_ loginSuccessful: Bool) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            completion(error == nil)
        }
    }
    
    func standardRegister(withEmail email: String, password: String, completion: @escaping ((_ registrationSuccessful: Bool) -> Void)) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            completion(error == nil)
        }
    }
    
    func updateEmail(to newEmail: String) {
        Auth.auth().currentUser?.updateEmail(to: newEmail) { error in
            if let error = error { print(error.localizedDescription) }
        }
    }
    
    func logout(completion: @escaping ((_ logoutSuccessful: Bool) -> Void)) {
        do {
//            if AccessToken.current != nil { // authenticated with Facebook
//                let loginManager = LoginManager()
//                loginManager.logOut()
//            }
            try Auth.auth().signOut()
            completion(true)
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    var hasStandardAuth: Bool {
        return userHasAuth(type: "password")
    }
    
    var hasFaceBookAuth: Bool {
        return userHasAuth(type: "facebook")
    }
    
    var hasGoogleAuth: Bool {
        return userHasAuth(type: "google")
    }
    
    private func userHasAuth(type: String) -> Bool {

        for provider in (current?.providerData)! {
            if provider.providerID.contains(type) {
                return true;
            }
        }
        return false
    }
    
    private func externalLogin(credential: AuthCredential, completion: @escaping ((_ loginSuccessful: Bool) -> Void)) {
        
        Auth.auth().signIn(with: credential) { (user, error) in
            completion(error == nil)
        }
    }
    
}
