//
//  MiniEntryView.swift
//  Pin It
//
//  Created by Joseph Jin on 1/10/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation
import UIKit
import MapViewPlus

class MiniEntryViewModel: CalloutViewModel {
    var entry: Entry
    
    init(entry: Entry) {
        self.entry = entry
    }
}
