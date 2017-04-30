//
//  Extensions.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/24/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func color(fromHex rgbValue: UInt32) ->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
        let blue = CGFloat(rgbValue & 0xFF)/255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}


extension UIScreen {
    
    //TODO deal with brightness

}
