//
//  ViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 1/8/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.328562, longitude: 126.734141)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
        
        createAnnotation(title: "North Korea", sub: "Worker's paradise", loc: location)
    }
    
    
    func createAnnotation(title: String, sub: String, loc: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc
        annotation.title = title
        annotation.subtitle = sub
        map.addAnnotation(annotation)
        
    }


}

