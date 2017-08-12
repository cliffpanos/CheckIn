//
//  CommonPlatform.swift
//  True Pass
//
//  Created by Cliff Panos on 4/30/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import WatchConnectivity


//User Defaults to be used by the iOS App and WatchKit App

class Shared {
    
    ///The shared user defaults for all True Pass grouped apps (iOS & watchOS)
    static var defaults = UserDefaults(suiteName: "group.com.cliffpanos.TruePass")!
    
    ///The current version of the application
    static let VERSION_OF_APPLICATION: String = "1.0"
    
    ///The key for the user default value that returns which version the application has most recently had a first launch cycle for.
    ///Helps to present a new info controller when there are version updates
    static let VERSION_FIRST_LAUNCHED: String = "VersionMostRecentlyFirstLaunched"
    
    ///The key used to find using UserDefaults if the user has ever launched the app, a Bool
    static let FIRST_LAUNCH_OF_APP_EVER: String = "FirstLaunchOfAppEver"
}











///An enumeration of all possible WatchConnectivity primary message keys
///Ex: add the following statement to the transferred dictionary: message[WCD.KEY: WCD.type] where type is the specific descriptor for the action of the message, such as "passPayload"
enum WCD {
    
    static let KEY = "Activity"
    
    //Bidirectional
    static let sessionActivated = "sessionActivated"
    static let checkInPassRequest = "checkInPassRequest"
    static let mapLocationsRequest = "mapLocationsRequest"
    static let settingsUserDefault = "settingsUserDefault"
    
    static let correctNumberOfPasses = "correctNumberOfPasses"
    
    //From watchOS to iOS
    static let allPassesRequest = "allPassesRequest"
    
    //From iOS to watchOS
    static let signInStatus = "signInStatus"
    static let singleNewPass = "singleNewPass"
    static let deletePass = "deletePass"
    static let passDeletionSuccessStatus = "passDeletionSuccessStatus"
    
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

extension UIColor {
    
    static func color(fromHex hex: UInt32) ->UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16)/255.0
        let green = CGFloat((hex & 0xFF00) >> 8)/255.0
        let blue = CGFloat(hex & 0xFF)/255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    enum TrueColors {
        static let softRed = UIColor.color(fromHex: 0xFF0033)
        static let blue = UIColor.color(fromHex: 0x0066FF)
        static let lightBlue = UIColor.color(fromHex: 0x0191FF)
        static let green = UIColor.color(fromHex: 0x33CC33)
        static let medGray = UIColor.color(fromHex: 0x666666)
        static let trueBlue = UIColor.color(fromHex: 0x323742)
        static let lightBlueGray = UIColor.color(fromHex: 0xD1DCE6)
        static let lightestBlueGray = UIColor.color(fromHex: 0xF3F4F6)
        static let oceanic = UIColor.color(fromHex: 0xB3BCC5)
        static let sandy = UIColor.color(fromHex: 0xDDA943)
    }
}

extension String {
    
    subscript (i: Int) -> String {
        if self.isEmptyOrWhitespace() || i >= self.characters.count { return "" }
        return String(self[self.index(self.startIndex, offsetBy: String.IndexDistance(i))])
    }
    
    func isEmptyOrWhitespace() -> Bool {
        
        if(self.isEmpty) {
            return true
        }
        
        return (trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
    }
}
