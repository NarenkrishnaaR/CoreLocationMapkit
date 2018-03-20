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

protocol HandleMapSearch {
  func dropPinInAddress(placemark:MKPlacemark)
}

class MapView: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,HandleMapSearch {
  
  @IBOutlet weak var mapKitView: MKMapView!
  let locationManager = CLLocationManager()
  var resultSearchController: UISearchController? = nil
  var selectedPin:MKPlacemark? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCoreLoactionAndMapkit()
    appendLocationControllerToTheSearchController()
    setupSearch()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
  }
  
  func setupSearch(){
    let searchBar = resultSearchController?.searchBar
    searchBar?.sizeToFit()
    searchBar?.placeholder = "Search for places"
    navigationItem.titleView = resultSearchController?.searchBar
    resultSearchController?.hidesNavigationBarDuringPresentation = false
    resultSearchController?.dimsBackgroundDuringPresentation = true
    definesPresentationContext = true
  }
  
  func appendLocationControllerToTheSearchController(){
    let locationSearchClass = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTableView") as! LocationSearchTableView
    locationSearchClass.mapView = mapKitView
    locationSearchClass.handleMapSearchDelegate = self
    resultSearchController = UISearchController(searchResultsController: locationSearchClass)
    resultSearchController?.searchResultsUpdater = locationSearchClass
  }
  
  func dropPinInAddress(placemark: MKPlacemark) {
    selectedPin = placemark
    // clear existing pins
    mapKitView.removeAnnotations(mapKitView.annotations)
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    annotation.title = placemark.name
    if let city = placemark.locality,
      let state = placemark.administrativeArea {
      annotation.subtitle = "(\(city) (\(state))"
    }
    mapKitView.addAnnotation(annotation)
    let span = MKCoordinateSpanMake(0.05, 0.05)
    let region = MKCoordinateRegionMake(placemark.coordinate, span)
    mapKitView.setRegion(region, animated: true)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      //return nil so map view draws "blue dot" for standard user location
      return nil
    }
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView?.pinTintColor = UIColor.red
    pinView?.canShowCallout = true
    let smallSquare = CGSize(width: 30, height: 30)
    let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
    button.setImage(#imageLiteral(resourceName: "car"), for: .normal)
    button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
    pinView?.leftCalloutAccessoryView = button
    return pinView
  }
  
  @objc func getDirections(){
    if let selectedPin = selectedPin {
      let mapItem = MKMapItem(placemark: selectedPin)
      let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
      mapItem.openInMaps(launchOptions: launchOptions)
    }
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
    print("error:: (\(error)")
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
