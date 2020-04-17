//
//  PinAnnotation.swift
//  Pin It
//
//  Created by Joseph Jin on 4/16/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation
import UIKit
import MapKit

final class PinAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var e: Entry
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, e: Entry) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.e = e
        
        super.init()
    }
    
}
