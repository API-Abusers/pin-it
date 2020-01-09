//
//  ViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 1/8/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // setting up the manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        // adding test annotation
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.328562, longitude: 126.734141)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
        createAnnotation(title: "North Korea", sub: "Worker's paradise", loc: location)
        
        
        
    }
    
    // Create an annotation
    func createAnnotation(title: String, sub: String, loc: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc
        annotation.title = title
        annotation.subtitle = sub
        map.addAnnotation(annotation)
        
    }
}


extension MapViewController: CLLocationManagerDelegate {
    // Extracting Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10) // Zoom
        let currLoc: CLLocationCoordinate2D = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude) // Location
        let region: MKCoordinateRegion = MKCoordinateRegion(center: currLoc, span: span) // Set region
        map.setRegion(region, animated: true) // Update map
        
        self.map.showsUserLocation = true // Show blue dot
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




