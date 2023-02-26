//
//  CountryListVC.swift
//  iDonate
//
//  Created by Im043 on 31/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
class CountryListVC: BaseViewController,UISearchBarDelegate,UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBOutlet var tableView: UITableView!
    var countryArray = [countryListArray]()
    var countryModel :  CountryList?
    var tableData = [String]()
    var filteredTableData = [countryListArray]()
    let dict : [String:Any] = [String:Any]()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      self.navigationController?.isNavigationBarHidden = true
        
       // navigationItem.backBarButtonItem = backItem
     // self.navigationController?.
        self.searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search country"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        definesPresentationContext = true
        // Setup the search footer
        // Do any additional setup after loading the view.
//        getCountryData()
        
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        
        for code in NSLocale.isoCountryCodes  {

            let flag = String.emojiFlag(for: code)
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])

            if let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) {
                countryArray.append(countryListArray(sortname: code, name: name, flag: flag!))
            }
        }

        countryArray = countryArray.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending }
        
        print(countryArray.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending })
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
       
    }
    
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.view .endEditing(true)
         NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func getCountryData(){
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        let countryListUrl = URLHelper.iDonateCountryList
        
        WebserviceClass.sharedAPI.performRequest(type: CountryList.self ,urlString: countryListUrl, methodType: .post, parameters: [:], success: { (response) in
            self.countryModel = response
            self.countryArray  =  self.countryModel?.countryListArray ?? [countryListArray]()
            self.responseMethod()
            print("Result: \(String(describing: self.countryModel))") // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }, failure: {
            (response) in
            
            print(response)
        })
    }
    
    func responseMethod(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if iFiltering() {
            return filteredTableData.count
        }
        
        return countryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let country: countryListArray
        
        if iFiltering() {
            country = filteredTableData[indexPath.row]
        } else {
            country = countryArray[indexPath.row]
        }
        
        cell.textLabel!.text = "\(country.flag ?? "") " + country.name
        cell.backgroundColor = .clear
     
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view .endEditing(true)
        self.searchController.searchBar.resignFirstResponder()
         let country: countryListArray
        if iFiltering() {
            country = filteredTableData[indexPath.row]
        } else {
            country = countryArray[indexPath.row]
        }
        UserDefaults.standard .set(country.name, forKey: "selectedname")
        UserDefaults.standard .set(country.sortname, forKey: "selectedcountry")
        navigationController?.setNavigationBarHidden(true, animated: true)
        searchController.isActive = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.isNavigationBarHidden = true
           self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredTableData = countryArray.filter({( candy : countryListArray) -> Bool in
            print(candy)
            return candy.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    //MARK: Filter Function
    func iFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        _ = searchController.searchBar
        filterContentForSearchText(searchController.searchBar.text!)
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


extension String {

    static func emojiFlag(for countryCode: String) -> String! {
        func isLowercaseASCIIScalar(_ scalar: Unicode.Scalar) -> Bool {
            return scalar.value >= 0x61 && scalar.value <= 0x7A
        }

        func regionalIndicatorSymbol(for scalar: Unicode.Scalar) -> Unicode.Scalar {
            precondition(isLowercaseASCIIScalar(scalar))

            // 0x1F1E6 marks the start of the Regional Indicator Symbol range and corresponds to 'A'
            // 0x61 marks the start of the lowercase ASCII alphabet: 'a'
            return Unicode.Scalar(scalar.value + (0x1F1E6 - 0x61))!
        }

        let lowercasedCode = countryCode.lowercased()
        guard lowercasedCode.count == 2 else { return nil }
        guard lowercasedCode.unicodeScalars.reduce(true, { accum, scalar in accum && isLowercaseASCIIScalar(scalar) }) else { return nil }

        let indicatorSymbols = lowercasedCode.unicodeScalars.map({ regionalIndicatorSymbol(for: $0) })
        return String(indicatorSymbols.map({ Character($0) }))
    }
}
