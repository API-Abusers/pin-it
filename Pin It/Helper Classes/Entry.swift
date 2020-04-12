//
//  Entry.swift
//  Pin It
//
//  Created by Joseph Jin on 1/10/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation

class Entry: CustomStringConvertible {
    
    var username: String
    var location: [Double] // [longitude, latitude]
    var title: String
    var desc: String
    var id: String
    var owner: String
    
    public var description: String {
        return "[username: \(username), location: \(location), title: \(title), description: \(desc), id: \(id), owner: \(owner)]";
    }
    
    // Initializer
    public init(username: String, location: [Double], title: String, desc: String, id: String, owner: String) {
        self.username = username
        self.location = location
        self.title = title
        self.desc = desc
        self.id = id
        self.owner = owner
    }
    
}
