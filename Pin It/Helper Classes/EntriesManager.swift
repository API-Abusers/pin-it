//
//  EntriesManager.swift
//  Pin It
//
//  Created by Joseph Jin on 1/10/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation

class EntriesManager {
    
    static var entriesList = [Entry]()
    
    static func getEntriesFromServer() -> [Entry] {
        // queries the server and update the entriesList
        
        // add test entry
        entriesList.append(Entry(username: "joe mama", location: [40.328562, 126.734141], title: "Engaging in Forced Labor", description: "SOS, I need to get out of this North Korean camp."))
        return entriesList
    }
}
