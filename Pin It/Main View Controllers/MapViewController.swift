//
//  ViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 1/8/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MapViewPlus

class MapViewController: UIViewController {
    
    @IBOutlet weak var map: MapViewPlus!
    weak var currentCalloutView: UIView?
    let manager = CLLocationManager()
    let postPage = MakePostViewController()
    let calloutView = MiniEntryView()
    let annotationImage = UIImage(named: "loc-icon")!.resized(toHeight: 35)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.delegate = self
        map.anchorViewCustomizerDelegate = self
        
        // setting up the manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        // adding test annotation
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.328562, longitude: 155.734141)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
//        createAnnotation(title: "Idk", sub: "whoa", loc: location)
        
        updateEntriesOnMap()
        
    }
    
    // MARK: Update Entries On Map
    func updateEntriesOnMap() {
        let entries = EntriesManager.getEntriesFromServer()
        var annotations: [AnnotationPlus] = []
        for e in entries {
            let viewModel = MiniEntryViewModel(title: e.username, body: e.title)
            let annotation = AnnotationPlus(viewModel: viewModel,
                                            coordinate: CLLocationCoordinate2DMake(e.location[0], e.location[1]))
            annotations.append(annotation)
        }
        
        map.setup(withAnnotations: annotations)
    }
    
    // MARK: Create an annotation
    func createAnnotation(title: String, sub: String, loc: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc
        annotation.title = title
        annotation.subtitle = sub
        map.addAnnotation(annotation)
        
    }
    
    @IBAction func showPostView(_ sender: Any) {
        self.present(postPage, animated: true)
    }
    
}


extension MapViewController: CLLocationManagerDelegate {
    // Extracting Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations[0]
        
        print("loc")
        print(loc)
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10) // Zoom
        let currLoc: CLLocationCoordinate2D = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude) // Location
        let region: MKCoordinateRegion = MKCoordinateRegion(center: currLoc, span: span) // Set region
        map.setRegion(region, animated: true) // Update map
        
        self.map.showsUserLocation = true // Show blue dot
    }
}

extension MapViewController: MapViewPlusDelegate {
    func mapView(_ mapView: MapViewPlus, imageFor annotation: AnnotationPlus) -> UIImage {
        return annotationImage
    }

    func mapView(_ mapView: MapViewPlus, calloutViewFor annotationView: AnnotationViewPlus) -> CalloutViewPlus{
        let calloutView = Bundle.main.loadNibNamed("MiniEntryView", owner: nil, options: nil)!.first as! MiniEntryView
        currentCalloutView = calloutView
        return calloutView
    }

    func mapView(_ mapView: MapViewPlus, didAddAnnotations annotations: [AnnotationPlus]) {
        mapView.showAnnotations(annotations, animated: true)
    }
}

extension MapViewController: AnchorViewCustomizerDelegate {
    func mapView(_ mapView: MapViewPlus, fillColorForAnchorOf calloutView: CalloutViewPlus) -> UIColor {
        return currentCalloutView!.backgroundColor!
    }
}


