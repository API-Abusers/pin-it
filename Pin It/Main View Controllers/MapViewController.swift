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
    
    let manager = CLLocationManager()
    
    let postPage = MakePostViewController()
    var currentCalloutView = MiniEntryView()
    let detailPage = DetailedEntryViewController()
    
    let annotationImage = UIImage(named: "loc-icon")!.resized(toHeight: 35)!
    var located = false
    var location : [CLLocation]?
    
    @IBOutlet weak var findSelfButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        map.delegate = self
        map.anchorViewCustomizerDelegate = self
        map.showsCompass = false
        
        findSelfButton.isEnabled = false
        
        // setting up the manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        // adding test annotation
//        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
//        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.328562, longitude: 155.734141)
//        let region = MKCoordinateRegion(center: location, span: span)
//        map.setRegion(region, animated: true)
//        createAnnotation(title: "Idk", sub: "whoa", loc: location)
        
        updateEntriesOnMap()
    }
    
    // MARK: Move To Location on Map
    func moveTo (location loc: CLLocation) {
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10) // Zoom
        let currLoc: CLLocationCoordinate2D = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude) // Location
        let region: MKCoordinateRegion = MKCoordinateRegion(center: currLoc, span: span) // Set region
        map.setRegion(region, animated: true) // Update map
        
        self.map.showsUserLocation = true // Show blue dot
    }
    
    // MARK: Update Entries On Map
    func updateEntriesOnMap() {
        let entries = EntriesManager.getEntriesFromServer()
        var annotations: [AnnotationPlus] = []
        for e in entries {
            let viewModel = MiniEntryViewModel(entry: e)
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
    
    // MARK: Show Detail of an Entry View
    func showDetail(entry: Entry) {
        detailPage.entry = entry
        self.present(detailPage, animated: true)
    }
    
    // MARK: Show Post View
    @IBAction func showPostView(_ sender: Any) {
        self.present(postPage, animated: true)
    }
    
    // MARK: Zoom in on the User
    @IBAction func findSelf(_ sender: Any) {
        moveTo(location: location![0])
    }
}


extension MapViewController: CLLocationManagerDelegate {
    // Extracting Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations
        
        if(self.located) { return }
        findSelfButton.isEnabled = true
        moveTo(location: self.location![0])
        self.located = true
    }
}

extension MapViewController: MapViewPlusDelegate {
    func mapView(_ mapView: MapViewPlus, imageFor annotation: AnnotationPlus) -> UIImage {
        return annotationImage
    }

    func mapView(_ mapView: MapViewPlus, calloutViewFor annotationView: AnnotationViewPlus) -> CalloutViewPlus{
        let calloutView = Bundle.main.loadNibNamed("MiniEntryView", owner: nil, options: nil)!.first as! MiniEntryView
        currentCalloutView = calloutView
        currentCalloutView.rootController = self
        return calloutView
    }

    func mapView(_ mapView: MapViewPlus, didAddAnnotations annotations: [AnnotationPlus]) {
        mapView.showAnnotations(annotations, animated: true)
    }
}

extension MapViewController: AnchorViewCustomizerDelegate {
    func mapView(_ mapView: MapViewPlus, fillColorForAnchorOf calloutView: CalloutViewPlus) -> UIColor {
        return currentCalloutView.backgroundColor!
    }
}
