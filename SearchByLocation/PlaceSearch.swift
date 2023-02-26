//
//  PlaceSearch.swift
//  iDonate
//
//  Created by Im043 on 25/06/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import MapKit

import GooglePlaces

class PlaceSearch: BaseViewController, UISearchDisplayDelegate {
    
    var placesClient: GMSPlacesClient!

    @IBOutlet weak var searchResultsTableView: UITableView!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    @IBOutlet var searchBar: UISearchBar!
    
    var tableDataSource: GMSAutocompleteTableDataSource?
    var searchController: UISearchDisplayController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        searchCompleter.delegate = self
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        iDonateClass.sharedClass.customSearchBar(searchBar: searchBar)
        searchBar .becomeFirstResponder()
        
        
        placesClient = GMSPlacesClient.shared()
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self

        searchController = UISearchDisplayController(searchBar: searchBar!, contentsController: self)
        searchController?.searchResultsDataSource = tableDataSource
        searchController?.searchResultsDelegate = tableDataSource
        searchController?.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didUpdateAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
      // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      // Reload table data.
      searchDisplayController?.searchResultsTableView.reloadData()
    }

    func didRequestAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
      // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
      // Reload table data.
      searchDisplayController?.searchResultsTableView.reloadData()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension PlaceSearch: GMSAutocompleteTableDataSourceDelegate {
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
            print("Error: \(error)")

    }
    
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        searchDisplayController?.isActive = false
    // Do something with the selected place.
    print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place attributions: \(place.attributions)")
    }
    
  func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
    tableDataSource?.sourceTextHasChanged(searchString)
    return false
  }

  func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: NSError) {
    // TODO: Handle the error.
    print("Error: \(error.description)")
  }

    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
    return true
  }
}
//extension PlaceSearch: UISearchBarDelegate {
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        guard searchText.count >= 3 else {
//            return
//        }
//
//        searchCompleter.queryFragment = searchText
//        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
//        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.0902, longitude: 95.7129), span: span)
//        searchCompleter.region = region
//        searchCompleter.filterType =  .locationsOnly
//
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchCompleter.queryFragment = searchBar.text!
//        searchBar .resignFirstResponder()
//    }
//
//
//}
//
//extension PlaceSearch: MKLocalSearchCompleterDelegate {
//
//    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        searchResults = completer.results
//        searchResultsTableView.reloadData()
//    }
//
//    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
//        // handle error
//    }
//}
//
//extension PlaceSearch: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchResults.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let searchResult = searchResults[indexPath.row]
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
//        cell.textLabel?.text = searchResult.title
//        cell.detailTextLabel?.text = searchResult.subtitle
//        cell.contentView.backgroundColor = UIColor.clear
//        cell.backgroundColor = UIColor.clear
//        cell.textLabel?.backgroundColor = UIColor.clear
//        cell.detailTextLabel?.backgroundColor = UIColor.clear
//
//        return cell
//    }
//}
//
//extension PlaceSearch: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let completion = searchResults[indexPath.row]
//        let searchRequest = MKLocalSearch.Request(completion: completion)
//        let search = MKLocalSearch(request: searchRequest)
//        search.start { (response, error) in
//            let coordinate = response?.mapItems[0].placemark.coordinate
//            print(String(describing: coordinate))
//            let latitude = "\(coordinate?.latitude ?? 0)"
//            let longitude = "\(coordinate?.longitude ?? 0)"

//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Select City Notification"), object: nil)
//            self.navigationController?.popViewController(animated: true)
//        }
//
//
//    }
//
//}
