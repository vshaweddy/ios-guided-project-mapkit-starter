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
    
    var quakes: [Quake] = [] {
        didSet {
            mapView.addAnnotations(quakes)
        }
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTrackingButton)
        
        userTrackingButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20.0).isActive = true
        userTrackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20.0).isActive = true
        
        fetchQuakes()
        
        self.mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
	}
    
    func fetchQuakes() {
        let visibleRegion = mapView.visibleMapRect
        
        quakeFetcher.fetchQuakes(in: visibleRegion) { (quakes, error) in
            if let error = error {
                NSLog("Error fetching quakes: \(error)")
            }
            
            self.quakes = quakes ?? []
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.setCenter(userLocation.coordinate, animated: true)
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
}
