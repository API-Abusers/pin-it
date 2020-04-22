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
import Alamofire
import PromiseKit
import SPStorkController

class MapViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    let manager = CLLocationManager()
    let entryManager = EntriesManager()

    var calloutView = Bundle.main.loadNibNamed("MiniEntryView", owner: nil, options: nil)!.first as! MiniEntryView?
    var detailPage: DetailedEntryViewController!
    var profilePage = ProfileViewController()
    
    let annotationImage = UIImage(named: "loc-icon")!.resized(toHeight: 40)!
    var activeAnnotations = Dictionary<String, MKAnnotation>()
    
    @IBOutlet weak var findSelfButton: UIButton!
    @IBOutlet weak var loadMoreButton: UIButton!
    
    static var userLoc: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        
        // configurations for map
        map.delegate = self
        map.showsCompass = false
        
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        map.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        // config buttons
        findSelfButton.isEnabled = false
        loadMoreButton.isEnabled = false
        loadMoreButton.isHidden = true
        
        // configure callout view
        calloutView!.onTap { e in
            self.showDetail(entry: e)
        }
        
        // setting up the manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        // configuring and calling EntriesManager
        entryManager.onDataChange() { (e, type) in
            switch type {
            case .added:
                if let _ = self.activeAnnotations[e.id] { return }
                self.writeAnnotation(from: e)
                break
            case .modified: // TODO: Handle modified and removed posts
                self.writeAnnotation(from: e)
                break
            case .removed:
                guard let annotation = self.activeAnnotations[e.id] else { return }
                self.map.removeAnnotation(annotation)
                break
            default:
                break
            }
        }
//        queryEntriesToMap()
        
        // zooom in on the current user location
        CLLocationManager.requestLocation().done { (loc) in
            self.moveTo(location: loc[0])
            self.findSelfButton.isEnabled = true
        }.catch { err in
            print(err)
        }
        
        
    }
    
    // MARK: Move To Location on Map
    func moveTo (location loc: CLLocation) {
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // Zoom
        let currLoc: CLLocationCoordinate2D = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude) // Location
        let region: MKCoordinateRegion = MKCoordinateRegion(center: currLoc, span: span) // Set region
        map.setRegion(region, animated: true) // Update map
        
        self.map.showsUserLocation = true // Show blue dot
        
        MapViewController.userLoc = loc // update user location
    }
    
    // MARK: Update Entries On Map
    func queryEntriesToMap() {
        loadMoreButton.isEnabled = false
        entryManager.getEntriesFromServer().done { (entries) in
            guard let entries = entries else {
                self.loadMoreButton.isEnabled = true
                return
            }
            for e in entries {
                self.writeAnnotation(from: e)
            }
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
    
    // MARK: Returns an AnnotationPlus Object from an Entry
    func getAnnotationFromEntry(_ e: Entry) -> MKAnnotation {
//        let viewModel = MiniEntryViewModel(entry: e)
        let annotation = PinAnnotation(coordinate: CLLocationCoordinate2DMake(e.location[0],
                                                                              e.location[1]),
                                       title: e.title,
                                       subtitle: e.username,
                                       e: e)
        return annotation
    }
    
    // MARK: Adds Annotation to HashSet and Map View
    func writeAnnotation(from entry: Entry) {
        let annotation = self.getAnnotationFromEntry(entry)
        if let a = self.activeAnnotations[entry.id] { self.map.removeAnnotation(a) }
        self.activeAnnotations[entry.id] = annotation
        self.map.addAnnotation(annotation)
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
        detailPage.modalPresentationStyle = .pageSheet
        detailPage.modalTransitionStyle = .coverVertical
        self.present(detailPage, animated: true)
    }
    
    // MARK: Show Pins in Cluster
    func showClusteOptions(for annotations: [MKAnnotation]) {
        let popupPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupvc") as! PopupViewController
        popupPage.useAnnotations(annotations: annotations)
        popupPage.onSelection { e in
            self.showDetail(entry: e)
        }
        self.addChild(popupPage)
        popupPage.view.frame = self.view.frame
        self.view.addSubview(popupPage.view)
        popupPage.didMove(toParent: self)
    }
    
    // MARK: Show Post View
    @IBAction func showPostView(_ sender: Any) {
        let postPage = MakePostViewController()
        self.present(postPage, animated: true, completion: nil)
    }
    
    // MARK: Zoom in on the User
    @IBAction func findSelf(_ sender: Any) {
        CLLocationManager.requestLocation().done { (loc) in
            self.moveTo(location: loc[0])
        }.catch { err in
            print(err)
        }
    }
    
    // MARK: Show Profile
    @IBAction func showProfile(_ sender: Any) {
        self.profilePage = ProfileViewController()
        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.storkDelegate = self
        transitionDelegate.customHeight = 200
        transitionDelegate.showCloseButton = false
        transitionDelegate.translateForDismiss = 20
        profilePage.renderView { arrangment in
            transitionDelegate.customHeight = arrangment.frame.height + 30
        }
        
        profilePage.transitioningDelegate = transitionDelegate
        profilePage.modalPresentationStyle = .custom
        self.present(profilePage, animated: true, completion: nil)
    }
    
    // MARK: Load More Posts
    @IBAction func loadMorePosts(_ sender: Any) {
        queryEntriesToMap()
    }
    
    // MARK: Prepare Deinit
    func prepareDeinit() {
        calloutView!.onTap = nil
        calloutView = nil
    }
    
    deinit {
        print("Deinitializing MapViewController")
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) { return nil } // do not modify user pin
        
        if let annotation = annotation as? PinAnnotation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            annotationView.image = annotationImage
            annotationView.centerOffset = CGPoint(x: 0, y: -annotationImage.size.height / 2)
            
            annotationView.canShowCallout = true
            
            let button = UIButton(type: .detailDisclosure)
            button.addTapGestureRecognizer { self.showDetail(entry: annotation.e) }
            annotationView.rightCalloutAccessoryView = button
            
            annotationView.clusteringIdentifier = "regular-pin"
            
            return annotationView
        } else if let annotation = annotation as? MKClusterAnnotation {
            guard let annotationView = map.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier) else { return nil }
            annotationView.canShowCallout = true
            
            let button = UIButton(type: .detailDisclosure)
            button.addTapGestureRecognizer { self.showClusteOptions(for: annotation.memberAnnotations) }
            annotationView.rightCalloutAccessoryView = button
            
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        // disable callout view for user location
        for v in views {
            if let annotation = v.annotation {
                if annotation.isEqual(mapView.userLocation) {
                    v.canShowCallout = false
                    return
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? PinAnnotation { // handle regular annotations
            self.showDetail(entry: annotation.e)
        } else if let view = view as? ClusterAnnotationView { // handle cluster views
            guard let cluster = view.annotation as? MKClusterAnnotation else { return }
            self.showClusteOptions(for: cluster.memberAnnotations)
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    // Extracting Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
}

extension MapViewController: SPStorkControllerDelegate {
    
    func didDismissStorkByTap() {
        print("SPStorkControllerDelegate - didDismissStorkByTap")
    }
    
    func didDismissStorkBySwipe() {
        print("SPStorkControllerDelegate - didDismissStorkBySwipe")
    }
}
