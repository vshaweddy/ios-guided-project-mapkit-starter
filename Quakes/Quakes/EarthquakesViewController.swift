//
//  EarthquakesViewController.swift
//  Quakes
//
//  Created by Paul Solt on 10/3/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class EarthquakesViewController: UIViewController, CLLocationManagerDelegate {
		
	// NOTE: You need to import MapKit to link to MKMapView
	@IBOutlet var mapView: MKMapView!
    
    private let quakeFetcher = QuakeFetcher()
    private let locationManager = CLLocationManager()
    private var userTrackingButton: MKUserTrackingButton!
    private let annotationReuseIdentifier = "QuakeAnnotationView"
    
    var quakes: [Quake] = [] {
        didSet {
            let oldQuakes = Set(oldValue)
            let newQuakes = Set(quakes)
            let addedQuakes = Array(newQuakes.subtracting(oldQuakes))
            let removedQuakes = Array(oldQuakes.subtracting(newQuakes))
            mapView.removeAnnotations(removedQuakes)
            mapView.addAnnotations(addedQuakes)
        }
    }
    
    // one request at a time
    var isCurrentlyFetchingQuakes = false
    var shouldRequestQuakeAgain = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTrackingButton)
        
        userTrackingButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20.0).isActive = true
        userTrackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20.0).isActive = true
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationReuseIdentifier)
        
        fetchQuakes()
        
        self.mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
	}
    
    func fetchQuakes() {
        // If we were already requesting quakes
        guard !isCurrentlyFetchingQuakes else {
            // ... then we want to "remember to refresh once we finish
            shouldRequestQuakeAgain = false
            
            return
        }
        
        isCurrentlyFetchingQuakes = true
        let visibleRegion = mapView.visibleMapRect
        
        quakeFetcher.fetchQuakes(in: visibleRegion) { (quakes, error) in
            self.isCurrentlyFetchingQuakes = false
            
            if let error = error {
                NSLog("Error fetching quakes: \(error)")
            }
            
            // so it won't hide the quakes, when we're getting back empty quakes
            if let quakes = quakes {
                self.quakes = quakes
            }
            
            if self.shouldRequestQuakeAgain {
                self.shouldRequestQuakeAgain = false
                self.fetchQuakes()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
    }
}

extension EarthquakesViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.fetchQuakes()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let quake = annotation as? Quake else { return nil }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationReuseIdentifier, for: quake) as? MKMarkerAnnotationView else {
            fatalError("Missing registered map annotation view")
        }
        
        annotationView.glyphImage = #imageLiteral(resourceName: "QuakeIcon") // UIImage(named: "QuakeIcon")
        
        if quake.magnitude >= 7 {
            annotationView.markerTintColor = .systemPurple
        } else if quake.magnitude >= 5 {
            annotationView.markerTintColor = #colorLiteral(red: 0.9409348369, green: 0.238632679, blue: 0.2713032067, alpha: 1)
        } else if quake.magnitude >= 3 {
            annotationView.markerTintColor = .systemOrange
        } else {
            annotationView.markerTintColor = .systemYellow
        }
        
        // Popup
        annotationView.canShowCallout = true
        let detailView = QuakeDetailView()
        detailView.quake = quake
        annotationView.detailCalloutAccessoryView = detailView
        
        
        return annotationView
    }
}
