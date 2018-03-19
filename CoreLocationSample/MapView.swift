//
//  MapView.swift
//  CoreLocationSample
//
//  Created by Naren on 19/03/18.
//  Copyright © 2018 naren. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapView: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
  
  @IBOutlet weak var mapKitView: MKMapView!
  let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCoreLoactionAndMapkit()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse {
      locationManager.requestLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      let span = MKCoordinateSpanMake(0.05, 0.05)
      let region = MKCoordinateRegion(center: location.coordinate, span: span)
      mapKitView.setRegion(region, animated: true)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error:: (error)")
  }
  
  func setupCoreLoactionAndMapkit(){
    locationManager.delegate = self
    locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
    
    mapKitView.delegate = self
    mapKitView.showsUserLocation = true
    mapKitView.userTrackingMode = .follow
  }
  
  func alertFunc(){
    let alertController = UIAlertController(title: "Location services were previously denied. Please enable location services for this app in Settings.", message: "", preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    alertController.addAction(alertAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
