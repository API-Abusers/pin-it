//
//  AppConfigs.swift
//  
//
//  Created by Joseph Jin on 4/27/20.
//

import Foundation

final class AppConfigs {
    
    static func getConfig(forKey key: String) -> Any? {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                return dict[key]
            }
        }
        return nil
    }
}
