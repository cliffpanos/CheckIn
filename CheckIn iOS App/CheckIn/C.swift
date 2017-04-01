//
//  C.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData

class C {
    
    static var appDelegate: AppDelegate!
    static var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    static var passes: [Pass] {
        get {
            let managedContext = C.appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Pass> = Pass.fetchRequest()
            
            if let passes = try? managedContext.fetch(fetchRequest) {
                return passes
            }
            return [Pass]()
        }
        set (newPasses) {
            let managedContext = C.appDelegate.persistentContainer.viewContext
            if ((try? managedContext.save()) != nil) {
                self.passes = newPasses
            }
        }
    }
    
    static var passesActive: Bool = true
    static var automaticCheckIn: Bool = true
    
    static var user: LoggedIn!
    static var userIsLoggedIn: Bool {
        get {
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<LoggedIn> = LoggedIn.fetchRequest()
            
            let isLoggedIn = try? managedContext.fetch(fetchRequest)
            if let isLoggedIn = isLoggedIn {
                user = isLoggedIn[0]
                return user.isLoggedIn
            }
            return false
        
        }
        set {
            let managedContext = appDelegate.persistentContainer.viewContext
            user.isLoggedIn = newValue
            do {
                try managedContext.save()
            } catch _ as NSError {
                print("ERROR SAVING")
            }
        }
    
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
