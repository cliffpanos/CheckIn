//
//  ExtensionDelegate.swift
//  CheckInWatchKitApp Extension
//
//  Created by Cliff Panos on 4/15/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    static var session: WCSession?
    
    func setSession() {
        if WCSession.isSupported() {
            ExtensionDelegate.session = WCSession.default()
            ExtensionDelegate.session?.delegate = self
            ExtensionDelegate.session?.activate()
            ExtensionDelegate.session = WC.session
        }
        print("WATCH Session is reachable: \(String(describing: WC.session?.isReachable))")
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    
        switch (message["Activity"] as? String ?? "") {
        case "PassesReply":
            let data = message["Payload"] as! Data
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data)
            print("RECEIVED PASSES REPLY FROM REQUEST")
            WC.addPass(from: dictionary as! Dictionary<String, Any>)
        default: print("no message handled")
        }
        print("Watch App did receive message")
    }
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        setSession()
        WC.ext = self
        
        for name in ["Clifford Panos", "Kate Allport", "Joe Torraca", "Madelyn Hightower"] {
            let pass = Pass()
            pass.name = name
            WC.passes.append(pass)
        }
    }
    
    func applicationDidEnterBackground() {
        print("Watch did enter background")
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        ExtensionDelegate.session?.sendMessage(["Activity" : "Session Activated"], replyHandler: nil, errorHandler: {
            error in print(error)
        })
        print("Activation complete")
        WC.getQRCodeImageUsingWC()
        WC.requestPassesFromiOS()

    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Reachability state did change-----------")
        WC.getQRCodeImageUsingWC()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        for (key, value) in applicationContext {
        
            if key == "signInStatus" {
                print("DID RECEIVE APPLICATION CONTEXT")
                let loggedIn = value as! Bool
                if loggedIn {
                    WC.switchToSignInScreen()
                } else {
                    WC.switchUserNowLoggedIn()
                }
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        
        if backgroundTasks.count != 0 {
            print("RECIEVED BACKGROUND TASK")
        }
        
        
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }

}
