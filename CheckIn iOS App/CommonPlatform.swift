//
//  CommonPlatform.swift
//  True Pass
//
//  Created by Cliff Panos on 4/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import WatchConnectivity

class CommonPlatform {
    
    static var dictionary: Dictionary<String, Any?>!
    
}

class Shared {
    static var defaults = UserDefaults(suiteName: "group.com.cliffpanos.CheckIn")!
}

//Mark: - Enumerate all possible WatchConnectivity message key types
//Ex: add the statement message[CIMType.KEY: CIM.<type>] to the transferred dictionary
enum WCD {
    
    static let KEY = "Activity"
    
    //Bidirectional
    static let sessionActivated = "sessionActivated"
    static let checkInPassRequest = "checkInPassRequest"
    static let mapLocationsRequest = "mapLocationsRequest"
    static let settingsUserDefault = "settingsUserDefault"
    
    //From watchOS to iOS
    static let allPassesRequest = "allPassesRequest"
    
    //From iOS to watchOS
    static let signInStatus = "signInStatus"
    static let singleNewPass = "singleNewPass"
    static let deletePass = "deletePass"
    
    static let passPayload = "passPayload"
    static let nextPassIndex = "nextPassIndex"
    
    
}

class WCActivator {
    static func set(_ session: inout WCSession?, for delegate: WCSessionDelegate) {
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = delegate
            session?.activate()
            print("WCSession activated by WCActivator!")
        }
    }
}

extension String {
    subscript (i: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: String.IndexDistance(i))])
    }
}
