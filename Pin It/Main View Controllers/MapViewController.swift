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
import Alamofire
import PromiseKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var map: MapViewPlus!
    
    let manager = CLLocationManager()
    
    static var postPage = MakePostViewController()
    var calloutView = Bundle.main.loadNibNamed("MiniEntryView", owner: nil, options: nil)!.first as! MiniEntryView
    var detailPage = DetailedEntryViewController()
    let profilePage = ProfileViewController()
    
    let annotationImage = UIImage(named: "loc-icon")!.resized(toWidth: 60)!
    var annotations = [AnnotationPlus]()
    
    @IBOutlet weak var findSelfButton: UIButton!
    @IBOutlet weak var loadMoreButton: UIButton!
    
    static var userLoc: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        map.delegate = self
        map.anchorViewCustomizerDelegate = self
        map.showsCompass = false
        
        findSelfButton.isEnabled = false
        loadMoreButton.isEnabled = false
        
        calloutView.rootController = self
        
        // setting up the manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        appendEntriesToMap()
        
        // zooom in on the current user location
        CLLocationManager.requestLocation().done { (loc) in
            self.moveTo(location: loc[0])
            self.findSelfButton.isEnabled = true
        }
        
    }
    
    // MARK: Move To Location on Map
    func moveTo (location loc: CLLocation) {
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30) // Zoom
        let currLoc: CLLocationCoordinate2D = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude) // Location
        let region: MKCoordinateRegion = MKCoordinateRegion(center: currLoc, span: span) // Set region
        map.setRegion(region, animated: true) // Update map
        
        self.map.showsUserLocation = true // Show blue dot
        
        MapViewController.userLoc = loc // update user location
    }
    
    // MARK: Update Entries On Map
    func appendEntriesToMap() {
        loadMoreButton.isEnabled = false
        EntriesManager.getEntriesFromServer().done { (entries) in
            guard let entries = entries else {
                self.loadMoreButton.isEnabled = true
                return
            }
            for e in entries {
                let viewModel = MiniEntryViewModel(entry: e)
                let annotation = AnnotationPlus(viewModel: viewModel,
                                                coordinate: CLLocationCoordinate2DMake(e.location[0], e.location[1]))
                self.annotations.append(annotation)
            }
            self.map.setup(withAnnotations: self.annotations)
            self.loadMoreButton.isEnabled = true
        }.catch { (err) in
            print("[MapViewController] Error while getting entries from server: \(err)")
            if !Connectivity.isConnectedToInternet {
                WarningPopup.issueWarningOnInternetConnection(vc: self)
                self.loadMoreButton.isEnabled = true
                return
            }
        }
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
        detailPage = DetailedEntryViewController()
        detailPage.useEntry(entry: entry)
        self.present(detailPage, animated: true)
    }
    
    // MARK: Show Post View
    @IBAction func showPostView(_ sender: Any) {
        self.present(MapViewController.postPage, animated: true)
    }
    
    // MARK: Zoom in on the User
    @IBAction func findSelf(_ sender: Any) {
        CLLocationManager.requestLocation().done { (loc) in
            self.moveTo(location: loc[0])
        }
    }
    
    // MARK: Show Profile
    @IBAction func showProfile(_ sender: Any) {
        self.present(profilePage, animated: true)
    }
    
    // MARK: Load More Posts
    @IBAction func loadMorePosts(_ sender: Any) {
        appendEntriesToMap()
    }
    
    deinit {
        print("Deinitializing MapViewController")
    }
}


extension MapViewController: CLLocationManagerDelegate {
    // Extracting Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
}

extension MapViewController: MapViewPlusDelegate {
    func mapView(_ mapView: MapViewPlus, imageFor annotation: AnnotationPlus) -> UIImage {
        return annotationImage
    }

    func mapView(_ mapView: MapViewPlus, calloutViewFor annotationView: AnnotationViewPlus) -> CalloutViewPlus{
        return calloutView
    }

    func mapView(_ mapView: MapViewPlus, didAddAnnotations annotations: [AnnotationPlus]) {
    }
}

extension MapViewController: AnchorViewCustomizerDelegate {
    func mapView(_ mapView: MapViewPlus, fillColorForAnchorOf calloutView: CalloutViewPlus) -> UIColor {
        return self.calloutView.backgroundColor!
    }
}
