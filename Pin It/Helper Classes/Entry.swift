//
//  Entry.swift
//  Pin It
//
//  Created by Joseph Jin on 1/10/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation

class Entry {
    
    var username: String
    var location: [Double] // [longitude, latitude]
    var title: String
    var description: String
    
    // Initializer
    public init(username: String, location: [Double], title: String, description: String) {
        self.username = username
        self.location = location
        self.title = title
        self.description = description
    }
    
}
