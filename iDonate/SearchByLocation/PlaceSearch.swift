//
//  PlaceSearch.swift
//  i2-Donate
//

import UIKit
import MapKit
import GooglePlaces

// A view controller for searching places.
class PlaceSearch: BaseViewController, UISearchDisplayDelegate {
    
    /// The Google Places client.
    var placesClient: GMSPlacesClient!

    /// The table view displaying search results.
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    /// The local search completer.
    var searchCompleter = MKLocalSearchCompleter()
    
    /// The array of search results.
    var searchResults = [MKLocalSearchCompletion]()
    
    /// The search bar for inputting search queries.
    @IBOutlet var searchBar: UISearchBar!
    
    /// The data source for autocomplete suggestions.
    var tableDataSource: GMSAutocompleteTableDataSource?
    
    /// The search controller for managing search results.
    var searchController: UISearchDisplayController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the search bar
        iDonateClass.sharedClass.customSearchBar(searchBar: searchBar)
        searchBar.becomeFirstResponder()
        
        // Set up the Google Places client
        placesClient = GMSPlacesClient.shared()
        
        // Set up the autocomplete table data source
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self

        // Set up the search controller
        searchController = UISearchDisplayController(searchBar: searchBar!, contentsController: self)
        searchController?.searchResultsDataSource = tableDataSource
        searchController?.searchResultsDelegate = tableDataSource
        searchController?.delegate = self
    }
    
    /// Action method called when the back button is tapped.
    ///
    /// - Parameter _sender: The button initiating the action.
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PlaceSearch: GMSAutocompleteTableDataSourceDelegate {
    
    /// Notifies the delegate that autocomplete predictions have been updated.
    ///
    /// - Parameter tableDataSource: The table data source.
    func didUpdateAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn off the network activity indicator.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        searchDisplayController?.searchResultsTableView.reloadData()
    }

    /// Notifies the delegate that autocomplete predictions have been requested.
    ///
    /// - Parameter tableDataSource: The table data source.
    func didRequestAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn on the network activity indicator.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Reload table data.
        searchDisplayController?.searchResultsTableView.reloadData()
    }
    
    /// Tells the delegate that autocomplete predictions have failed with an error.
    ///
    /// - Parameters:
    ///   - tableDataSource: The table data source.
    ///   - error: The error that occurred.
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("Error: \(error)")
    }
    
    /// Tells the delegate that a place has been selected from the autocomplete suggestions.
    ///
    /// - Parameters:
    ///   - tableDataSource: The table data source.
    ///   - place: The selected place.
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        searchDisplayController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    /// Tells the delegate that the search display controller should reload the table for a search string.
    ///
    /// - Parameters:
    ///   - controller: The search display controller.
    ///   - searchString: The search string.
    /// - Returns: A boolean value indicating whether the table should be reloaded.
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        tableDataSource?.sourceTextHasChanged(searchString)
        return false
    }
}
