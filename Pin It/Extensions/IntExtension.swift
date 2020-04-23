//
//  IntExtension.swift
//  Pin It
//
//  Created by Joseph Jin on 4/22/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation

extension Int {
    var shortenedDescription: String {
        let digits = self.description.count
        if digits <= 3 { return self.description }
        else if self <= 99000 {
            let res = String(self / 1000) + "K"
            return res
        }
        return "99K+"
    }
}
