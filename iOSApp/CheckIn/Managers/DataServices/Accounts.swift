//
//  Accounts.swift
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

class Accounts {
    
    static let shared = Accounts()
    
    var current: User? {
        return Auth.auth().currentUser
    }
    
    static var currentUser: FTPUser!
    
    func standardLogin(withEmail email: String, password: String, completion: @escaping ((_ loginSuccessful: Bool) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            completion(error == nil)
        }
    }
    
    func standardRegister(withEmail email: String, password: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            print(error ?? "")
            completion(error == nil, error)
        }
    }
    
    func sendConfirmationEmail(forUser user: User) {
        user.sendEmailVerification(completion: { success in
        })
    }
    
    func updateEmail(to newEmail: String) {
        Auth.auth().currentUser?.updateEmail(to: newEmail) { error in
            if let error = error { print(error.localizedDescription) }
        }
    }
    
    func logout(completion: @escaping ((_ failure: Error?) -> Void)) {
        do {
//            if AccessToken.current != nil { // authenticated with Facebook
//                let loginManager = LoginManager()
//                loginManager.logOut()
//            }
            try Auth.auth().signOut()
            completion(nil)
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
            completion(error)
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
        for provider in current?.providerData ?? [] {
            if provider.providerID.contains(type) {
                return true;
            }
        }
        return false
    }
    
    private func customLogin(credential: AuthCredential, completion: @escaping ((_ loginSuccessful: Bool) -> Void)) {
        
        Auth.auth().signIn(with: credential) { (user, error) in
            completion(error == nil)
        }
    }
    
}


//Handle the simple but incredibly important storage of user information
//Though ratchet, UserDefaults are used to provide a completely, 100% infallible way of preserving this data
extension Accounts {
    
    enum TPUDKeys: String {
        case TPUDkUserFirstName
        case TPUDkUserLastName
        case TPUDkUserIdenfitier
        case TPUDkUserImageData
        case TPUDkUserEmail
    }
    class func saveToUserDefaults(user: FTPUser, updateImage: Bool = false) {
        userFirstName = user.firstName
        userLastName = user.lastName
        userImageData = user.imageData
        userEmail = user.email
        userIdentifier = user.identifier
        guard updateImage else { return }
        FirebaseStorage.shared.retrieveProfilePicture(for: user.identifier) { data, error in
            if let data = data { userImageData = data }
        }
    }
    class var userFirstName: String {
        get {
            return C.getFromUserDefaults(withKey: TPUDKeys.TPUDkUserFirstName.rawValue) as! String
        }
        set {
            C.persistUsingUserDefaults(newValue, forKey: TPUDKeys.TPUDkUserFirstName.rawValue)
        }
    }
    class var userLastName: String {
        get {
            return C.getFromUserDefaults(withKey: TPUDKeys.TPUDkUserLastName.rawValue) as! String
        }
        set {
            C.persistUsingUserDefaults(newValue, forKey: TPUDKeys.TPUDkUserLastName.rawValue)
        }
    }
    class var userName: String {
        return userFirstName + " " + userLastName
    }
    class var userIdentifier: String {
        get {
            return C.getFromUserDefaults(withKey: TPUDKeys.TPUDkUserIdenfitier.rawValue) as! String
        }
        set {
            C.persistUsingUserDefaults(newValue, forKey: TPUDKeys.TPUDkUserIdenfitier.rawValue)
        }
    }
    class var userImageData: Data? {
        get {
            return C.getFromUserDefaults(withKey: TPUDKeys.TPUDkUserImageData.rawValue) as? Data
        }
        set {
            C.persistUsingUserDefaults(newValue, forKey: TPUDKeys.TPUDkUserImageData.rawValue)
        }
    }
    class var userImage: UIImage? {
        if let imageData = Accounts.userImageData { return UIImage(data: imageData) }
        return nil
    }
    class var userEmail: String {
        get {
            return C.getFromUserDefaults(withKey: TPUDKeys.TPUDkUserEmail.rawValue) as! String
        }
        set {
            C.persistUsingUserDefaults(newValue, forKey: TPUDKeys.TPUDkUserEmail.rawValue)
        }
    }
    
}
