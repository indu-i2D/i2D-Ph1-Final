//
//  GooglePlaceSearchViewController.swift
//  iDonate
//
//  Created by Satheesh k on 24/06/20.
//  Copyright © 2020 Im043. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMapsBase

class GooglePlaceSearchViewController: BaseViewController, UISearchBarDelegate {
    
    var resultText: UITextView?
    var fetcher: GMSAutocompleteFetcher?
    var boundaryForPlaces = String()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextField!
    var  searchPredictions: [GMSAutocompletePrediction]? = nil
    
    var placesDelegate:SearchByCityDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        edgesForExtendedLayout = []
        
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
            
        // Set up the autocomplete filter.
       let filter = GMSAutocompleteFilter()
        
        if boundaryForPlaces == "US" {
            filter.country = boundaryForPlaces
        }
        
        filter.type = .noFilter
        
        // Create a new session token.
        let token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher(filter: filter)
        //fetcher = GMSAutocompleteFetcher(bounds: nil, filter: filter)
        fetcher?.delegate = self
        fetcher?.provide(token)
        
        
        textField?.autoresizingMask = .flexibleWidth
        textField?.addTarget(self, action: #selector(textFieldDidChange(textField:)),
                             for: .editingChanged)
        let placeholder = boundaryForPlaces == "US" ? NSAttributedString(string: " Search by City/State") : NSAttributedString(string: " Search by Country")
        
        textField?.attributedPlaceholder = placeholder
        textField.backgroundColor = hexStringToUIColor(hex: "9C7192").withAlphaComponent(0.3)
        let placeHolderText = textField.placeholder ?? ""
        let str = NSAttributedString(string:placeHolderText, attributes: [NSAttributedString.Key.foregroundColor :UIColor.white])
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
        textField.attributedPlaceholder = str
        textField.textColor = .white
        textField.tintColor = .white
        
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if textField.text?.count ?? 0 >= 3 {
            fetcher?.sourceTextHasChanged(textField.text!)
        }
    }
    
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension GooglePlaceSearchViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        let resultsStr = NSMutableString()
        for prediction in predictions {
            resultsStr.appendFormat("\n Primary text: %@\n", prediction.attributedFullText)
            resultsStr.appendFormat("Place ID: %@\n", prediction.placeID)
            
            print(resultsStr)
        }
        searchPredictions = predictions
        print(predictions)
        tableView.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print(error)
    }
}

extension GooglePlaceSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchPredictions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.attributedText = searchPredictions?[indexPath.row].attributedFullText
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        GMSPlacesClient.shared().lookUpPlaceID("\(searchPredictions?[indexPath.row].placeID ?? "")") { (place, error) in
            print(place?.coordinate.latitude ?? 0.00)
            print(place?.coordinate.longitude ?? 0.00)
            print(place?.formattedAddress ?? "test")
            
//            let new = place?.addressComponents
            
            var placesDict = [String: String]()
            
            placesDict["latitude"] = "\(place?.coordinate.latitude ?? 0.00)"
            placesDict["longitude"] = "\(place?.coordinate.longitude ?? 0.00)"
            placesDict["locationname"] = "\(place?.formattedAddress ?? "")"
            placesDict["city"] = place?.name
            placesDict["placesFlag"] = "true"
            print(placesDict)
            self.placesDelegate?.getCharityListFromPlaces(inputDetails: placesDict)
            UserDefaults.standard .set("\(place?.coordinate.latitude ?? 0.00)", forKey: "latitude")
            UserDefaults.standard .set("\(place?.coordinate.longitude ?? 0.00)", forKey: "longitude")
            UserDefaults.standard .set("\(place?.formattedAddress ?? "")", forKey: "locationname")
            self.navigationController?.popViewController(animated: true)
        }

    }
    
}

    
