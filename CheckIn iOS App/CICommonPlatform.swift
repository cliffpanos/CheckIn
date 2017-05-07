//
//  CISharedPlatform.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class CICommonPlatform {
    
    static var dictionary: Dictionary<String, Any?>!
    
}

//Mark: - Enumerate all possible WatchConnectivity message key types
//Ex: add the statement message[CIMType.KEY: CIM.<type>] to the transferred dictionary
enum CIM: String {
    
    case KEY = "Activity"
    
    case signInStatus = "signInStatus"
    case allPassesRequest = "allPassesRequest"
    case singlePassRequest = "singlePassRequest"
    
}

class Shared {
    static var defaults = UserDefaults(suiteName: "group.com.cliffpanos.CheckIn")!
}


extension String {
    subscript (i: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: String.IndexDistance(i))])
    }
}
