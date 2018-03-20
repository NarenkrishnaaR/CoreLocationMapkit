//
//  LocationSearchTableView.swift
//  CoreLocationSample
//
//  Created by Naren on 20/03/18.
//  Copyright © 2018 naren. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableView: UITableViewController,UISearchResultsUpdating {
  
  var matchingItems:[MKMapItem] = []
  var mapView: MKMapView? = nil
  var handleMapSearchDelegate:HandleMapSearch? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let mapView = mapView,
      let searchBarText = searchController.searchBar.text else { return }
    let request = MKLocalSearchRequest()
    request.naturalLanguageQuery = searchBarText
    request.region = mapView.region
    let search = MKLocalSearch(request: request)
    search.start { response, _ in
      guard let response = response else {
        return
      }
      self.matchingItems = response.mapItems
      self.tableView.reloadData()
    }
  }
  
  func parseAddress(selectedItem:MKPlacemark) -> String {
    // put a space between "4" and "Melrose Place"
    let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
    // put a comma between street and city/state
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
    // put a space between "Washington" and "DC"
    let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let addressLine = String(
      format:"%@%@%@%@%@%@%@",
      // street number
      selectedItem.subThoroughfare ?? "",
      firstSpace,
      // street name
      selectedItem.thoroughfare ?? "",
      comma,
      // city
      selectedItem.locality ?? "",
      secondSpace,
      // state
      selectedItem.administrativeArea ?? ""
    )
    return addressLine
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return matchingItems.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let locationString = matchingItems[indexPath.row].placemark
    cell.textLabel?.text = locationString.name
    cell.detailTextLabel?.text = parseAddress(selectedItem: locationString)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedItem = matchingItems[indexPath.row].placemark
    handleMapSearchDelegate?.dropPinInAddress(placemark: selectedItem)
    dismiss(animated: true, completion: nil)
  }
}
