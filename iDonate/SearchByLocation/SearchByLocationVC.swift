//
//  i2-Donate
//


import UIKit
import MBProgressHUD
import Alamofire
import AlamofireImage
import TKFormTextField
import WebKit
import SafariServices


/// `SearchByLocationVC`: This module handles the search functionality by location.
//MARK: Protocols
/**
 Protocol to communicate search results based on city.
 */
protocol SearchByCityDelegate {
    func getCharityListFromPlaces(inputDetails: [String:String])
}
// Global variables
var searchBool1 = false // Flag indicating search state
var searchBool2 = false // Another flag indicating search state

// `SearchByLocationVC`: This module handles the search functionality by location.
///
// This module includes the `SearchByLocationVC` class, which is responsible for managing the search functionality
/// based on location. It conforms to various protocols and manages UI components and data variables related to
/// searching for charities.
// Main view controller class
class SearchByLocationVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate, SearchByCityDelegate, WKNavigationDelegate, WKUIDelegate, SFSafariViewControllerDelegate {

    //MARK: Outlets
    
    // UI components outlets
    @IBOutlet var notificationTabBar: UITabBar! // Tab bar for notifications
    @IBOutlet var searchTableView: UITableView! // Table view for displaying search results
    @IBOutlet var searchBar: UISearchBar! // Search bar for searching
    @IBOutlet var searchScrollBar: UISearchBar! // Another search bar
    @IBOutlet var containerView: UIView! // Container view
    @IBOutlet var searchBarView: UIView! // Search bar view
    @IBOutlet var innersearchBarView: UIView! // Inner search bar view
    @IBOutlet var namebtn: UIButton! // Button for name
    @IBOutlet var nameScrollbtn: UIButton! // Button for scrolling name
    @IBOutlet var typebtn: UIButton! // Button for type
    @IBOutlet var scrollTypebtn: UIButton! // Button for scrolling type
    @IBOutlet var locationNameText: UILabel! // Label for location name
    @IBOutlet weak var searchBarConstraint: NSLayoutConstraint! // Search bar constraint
    @IBOutlet weak var scrollConstraint: NSLayoutConstraint! // Scroll constraint
    @IBOutlet var noresultsview: UIView! // View for no results
    @IBOutlet var noresultMessage: UILabel! // Message for no results
    @IBOutlet var headerTitle: UILabel! // Header title
    @IBOutlet var blurView: UIVisualEffectView! // Blur view
    @IBOutlet var cancelBtn: UIButton! // Cancel button
    @IBOutlet var continuePaymentBtn: UIButton! // Continue payment button
    @IBOutlet var amountText: UITextField! // Text field for amount
    var isFromAdvanceSearch = false // Flag indicating if from advance search
    
    //MARK: Variables
    
    // Data variables
    var selectedCharity: CharityListArray? = nil // Selected charity
    var placesDelegate: SearchByCityDelegate? // Delegate for search by city
    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)) // Processing charges view
    var webView: WKWebView! // Web view
    var donateFlag: Bool = false // Flag for donation
    var nameFlg: Bool = false // Flag for name
    var charityResponse: CharityModel? // Charity response model
    var charityLikeResponse: CharityLikeModel? // Charity like response model
    var charityFollowResponse: FollowModel? // Charity follow response model
    var charityListArray: [CharityListArray]? // Array of charity list
    var filteredCharityListArray: [CharityListArray]? // Array of filtered charity list
    var isFiltering: Bool = false // Flag indicating if filtering
    var longitude: String = "" // Longitude
    var latitude: String = "" // Latitude
    var locationSearch: String = "Nonprofits" // Location search string
    var userID: String = "" // User ID
    var selectedIndex: Int = -1 // Selected index
    var headerTitleText: String = "" // Header title text
    var country: String = "US" // Country
    var categoryCode: [String]? // Category code
    var subCategoryCode: [String]? // Subcategory code
    var childCategory: [String]? // Child category
    var deductible = String() // Deductible
    var likeActionTriggered = false // Flag indicating if like action triggered
    var pageCount = 1 // Page count
    var previousPageCount = 1 // Previous page count
    var searchEnabled = "false" // Flag indicating if search enabled
    var searchName = "" // Search name
    var incomeFrom = "" // Income from
    var incomeTo = "" // Income to
    let digitBeforeDecimal = 5 // Number of digits before decimal
    let digitAfterDecimal = 2 // Number of digits after decimal
   
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        // Called after the controller's view is loaded into memory
        super.viewDidLoad()
        
        // Registering a custom table view cell from a nib file
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
        
        // Setting up menu button
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            self.scrollConstraint.constant = 80
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Configuring a WKWebView
        webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView?.uiDelegate = self
        
        // Customizing search bars
        iDonateClass.sharedClass.customSearchBar(searchBar: searchBar)
        iDonateClass.sharedClass.customSearchBar(searchBar: searchScrollBar)
        
        // Adding tap gesture recognizer to containerView
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        mytapGestureRecognizer.cancelsTouchesInView = false
        self.containerView.addGestureRecognizer(mytapGestureRecognizer)
        
        // Setting up constraints for containerView as tableHeaderView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.searchTableView.tableHeaderView = containerView
        containerView.centerXAnchor.constraint(equalTo: self.searchTableView.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.searchTableView.widthAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.searchTableView.topAnchor).isActive = true
        self.searchTableView.tableHeaderView?.layoutIfNeeded()
        self.searchTableView.tableHeaderView = self.searchTableView.tableHeaderView
        
        // Configuring blur view tap gesture recognizer
        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        mytapGestureRecognizer.cancelsTouchesInView = false
        self.blurView.addGestureRecognizer(mytapGestureRecognizer1)
        
        // Setting up header title
        headerTitle.text = headerTitleText
        debugPrint("headertitle", headerTitleText)
        
        // Modifying header title based on a condition
        if self.isFromAdvanceSearch {
            if headerTitleText ==  "INTERNATIONAL CHARITIES REGISTERED IN USA" {
                headerTitle.text = "ADVANCE SEARCH INTERNATIONAL"
            }
            if headerTitleText == "UNITED STATES" {
                headerTitle.text = "ADVANCE SEARCH USA"
            }
        }
        
        // Observing keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Configuring table view
        searchTableView.estimatedRowHeight = UITableView.automaticDimension
        searchTableView.isScrollEnabled = true
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        // Changing placeholder text
        self.changePlaceholderText(searchScrollBar)
        self.changePlaceholderText(searchBar)
        
        // Fetching token
        getToken()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        // Called when the view is about to appear on the screen
        
        // Print the current country
        print(country)
        
        // Reload the search table view data
        searchTableView.reloadData()
        
        // Set the text color of locationNameText to ivory
        locationNameText.textColor = ivoryColor
        
        // Set the locationNameText if locationSearch is not empty
        if !locationSearch.isEmpty {
            locationNameText.text = locationSearch + " & charities near you"
        }
        
        // Check if the 'SelectedType' key exists in UserDefaults
        if let selectedType = UserDefaults.standard.value(forKey: "SelectedType") as? String {
            // Set the search placeholders based on the country
            if country == "US" {
                searchBar.placeholder = "Search by city/state"
                searchScrollBar.placeholder = "Search by city/state"
            } else {
                searchBar.placeholder = "Search by country"
                searchScrollBar.placeholder = "Search by country"
            }
            
            // Update button selections based on 'SelectedType'
            nameScrollbtn.isSelected = false
            scrollTypebtn.isSelected = true
            typebtn.isSelected = true
            namebtn.isSelected = false
            
            // Set the text of locationNameText to the value of 'SelectedType'
            locationNameText.textColor = ivoryColor
            locationNameText.text = selectedType
        }
        
        // Check if user data exists in UserDefaults and set the userID
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            userID = myPeopleList.userID
        }
        
        // Print the value of searchEnabled
        print(self.searchEnabled)
        
        // Reset pageCount to 1 and perform search operations if searchName is not empty
        self.pageCount = 1
        if !self.searchName.isEmpty {
            self.searchBar.text = self.searchName
            self.makeNameSearchClicked()
        }
        
        // Call charityWebSerice to fetch charity data
        self.charityWebSerice()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Called when the view is about to disappear from the screen
        
        // Reset UserDefaults values related to location
        UserDefaults.standard.set("", forKey: "latitude")
        UserDefaults.standard.set("", forKey: "longitude")
        UserDefaults.standard.set("Nonprofits", forKey: "locationname")
        
        // Reset latitude, longitude, and locationSearch
        latitude = ""
        longitude = ""
        locationSearch = ""
        
        // Reset previousPageCount to pageCount
        previousPageCount = pageCount
    }

    
    // MARK: Button actions

    // Action for the filter button
    @IBAction func filterAction(_ sender: UIButton) {
        // Toggle filter view visibility based on button tag
        
        if(sender.tag == 0) {
            // Expand filter view
            UIView.animate(withDuration: 1, animations: {
                self.searchBarConstraint.constant = 100
                
                // Adjust scroll constraint based on safe area
                if(iDonateClass.hasSafeArea) {
                    self.scrollConstraint.constant = 100
                } else {
                    self.scrollConstraint.constant = 100
                }
                
                // Show inner search bar view
                self.innersearchBarView.isHidden = false
            })
            // Update button tag
            sender.tag = 1
        } else {
            // Collapse filter view
            sender.tag = 0
            self.searchBarConstraint.constant = 60
            
            // Adjust scroll constraint based on safe area
            if(iDonateClass.hasSafeArea) {
                self.scrollConstraint.constant = 60
            } else {
                self.scrollConstraint.constant = 60
            }
            
            // Hide inner search bar view
            self.innersearchBarView.isHidden = true
        }
    }

    // Action for the cancel button
    @IBAction func cancelAction(_ sender: UIButton) {
        // Remove blur view from superview
        blurView.removeFromSuperview()
    }

    // Action for the location button
    @IBAction func locationAction(_ sender: UIButton) {
        // Toggle selection state of location button
        
        typebtn.isSelected = false
        if(sender.isSelected) {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
    }

    // Action for the type button
    @IBAction func typeAction(_ sender: UIButton) {
        // Toggle selection state of type button and navigate to advanced search
        
        if(sender.isSelected) {
            sender.isSelected = false
        } else {
            namebtn.isSelected = false
            nameScrollbtn.isSelected = false
            sender.isSelected = true
            
            // Initialize and push advanced search view controller
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
            vc?.address = locationSearch
            vc?.latitude = latitude
            vc?.longitude = longitude
            vc?.countryCode = country
            vc?.searchNameKey = self.searchName
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }

    // Helper function to handle name search button click
    func makeNameSearchClicked() {
        // Configure search bar placeholders and update button states
        
        searchScrollBar.placeholder = "Enter nonprofit/charity name"
        searchBar.placeholder = "Enter nonprofit/charity name"
        nameScrollbtn.isSelected = true
        typebtn.isSelected = false
        nameFlg = true
    }

    // Action for the name button
    @IBAction func nameAction(_ sender: UIButton) {
        // Handle name button action
        
        typebtn.isSelected = false
    //    locationNameText.text = ""
        
        if(sender.isSelected) {
            // Deselect name button and update UI
            
            if country == "US" {
                searchBar.placeholder = "Search by city/state"
                searchScrollBar.placeholder = "Search by city/state"
            } else {
                searchBar.placeholder = "Search by country"
                searchScrollBar.placeholder = "Search by country"
            }
            sender.isSelected = false
            nameScrollbtn.isSelected = false
            nameFlg = false
            if !locationSearch.isEmpty {
                locationNameText.text = locationSearch + " & charities near you"
            }
           
        } else {
            // Make name search clicked and update UI
            
            self.makeNameSearchClicked()
        }
    }

    // Action for the name scroll button
    @IBAction func nameScrollAction(_ sender: UIButton) {
        // Handle name scroll button action
        
        typebtn.isSelected = false
        //  locationNameText.text = ""
        //tableTopConstraint.constant = 0
        
        // Clear search bar text and end editing
        self.searchBar.text = ""
        self.searchScrollBar.text = ""
        self.view.endEditing(true)
        
        if(sender.isSelected) {
            // Deselect name scroll button and update UI
            
            if country == "US" {
                searchBar.placeholder = "Search by city/state"
                searchScrollBar.placeholder = "Search by city/state"
            } else {
                searchBar.placeholder = "Search by country"
                searchScrollBar.placeholder = "Search by country"
            }
            sender.isSelected = false
            nameScrollbtn.isSelected = false
            nameFlg = false
            if !locationSearch.isEmpty {
                locationNameText.text = locationSearch + " & charities near you"
            }
        } else {
            // Make name search clicked and update UI
            
            self.makeNameSearchClicked()
        }
    }

    // Action for the like button
    @IBAction func likeAction(_ sender: UIButton) {
        // Handle like button action
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            var likeCount: String = ""
            userID = myPeopleList.userID
            let charityObject = charityListArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                likeCount = "0"
            } else {
                likeCount = "1"
                sender.isSelected = true
            }
            selectedIndex = sender.tag
            charityLikeAction(like: likeCount, charityId: charityObject.id!)
        } else {
            // Show alert for non-logged in users
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // Action for the advanced search button
    @IBAction func advancedSearch(_ sender: UIButton) {
        // Handle advanced search button action
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "newcontrollerID") as? NewViewfromadvancedSearchViewController
            vc?.address = locationSearch
            vc?.latitude = latitude
            vc?.longitude = longitude
            vc?.countryCode = country
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            // Show alert for non-logged in users
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // Action for the follow button
    @IBAction func followAction(_ sender: UIButton) {
        // Handle follow button action
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            var followCount: String = ""
            userID = myPeopleList.userID
            let charityObject = charityListArray![sender.tag]
            
            if(sender.isSelected) {
                // If already selected, deselect and update count
                sender.isSelected = false
                followCount = "0"
            } else {
                // If not selected, select and update count
                followCount = "1"
                sender.isSelected = true
            }
            
            selectedIndex = sender.tag
            followAction(follow: followCount, charityId: charityObject.id!)
        } else {
            // Show alert for non-logged in users
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    
func getToken(){
    
    }
    
    @IBAction func paymentAction(_ sender:UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let charityObject = charityListArray![self.continuePaymentBtn.tag]

            donateToCharity(charityID: charityObject.id!)
        }
    }
    func donateToCharity(charityID: String) {
      
        guard let userID = UserDefaults.standard.data(forKey: "people"),
              let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: userID) as? UserDetails else {
            print("Error: User details not found")
            return
        }
        
        let postDict = ["user_id": myPeopleList.userID, "charity_id": charityID]
        let iDonateTransString = String(format: URLHelper.iDonateTrans)

        WebserviceClass.sharedAPI.performRequest(type: [String: String].self, urlString: iDonateTransString, methodType: .post, parameters: postDict, success: { [self] (response) in
            // Hide loading indicator
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            print("RESPONSE", response)
            if let url = response["url"] as? String, let paymentURL = URL(string: url) {
                let safariViewController = SFSafariViewController(url: paymentURL)
                          // Set the delegate
                          safariViewController.delegate = self
                          // Present the SFSafariViewController
                            present(safariViewController, animated: true, completion: nil)

            } else {
                print("Error: Invalid payment URL")
            }
        }) { (error) in
            // Hide loading indicator
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)

            // Handle error if API call fails
            print("Error: \(error)")
            // You may display an error message to the user if needed
        }
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            // This method is called when the user dismisses the Safari view controller
            print("Safari view controller dismissed")
        }
        
   
    fileprivate func changePlaceholderText(_ searchBarCustom: UISearchBar) {
        
        if country == "US"{
            searchBarCustom.placeholder = "Search by City/State"
        } else {
            searchBarCustom.placeholder = "Search by country"
        }
        
        searchBarCustom.set(textColor: .white)
        searchBarCustom.setTextField(color: UIColor.clear)
        searchBarCustom.setPlaceholder(textColor: .white)
        searchBarCustom.setSearchImage(color: .white)
        searchBarCustom.setClearButton(color: .white)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if(donateFlag == true){
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    //MARK: Protocol Function
    func getCharityListFromPlaces(inputDetails: [String : String]) {
        print("inputDetails", inputDetails)
        print(charityListArray)
        let city = inputDetails["city"]
        print(city)
//        let newArr = charityListArray?.filter({ $0.contains(<#T##Bound#>)})
        self.searchEnabled = inputDetails["placesFlag"]!
        self.latitude  = inputDetails["latitude"]! //UserDefaults.standard.value(forKey: "latitude") as! String
        self.longitude = inputDetails["longitude"]! //UserDefaults.standard.value(forKey: "longitude") as! String
        self.locationSearch = inputDetails["locationname"]! //UserDefaults.standard.value(forKey: "locationname") as! String
        self.pageCount = 1
        self.charityWebSerice()
        print(locationSearch)
    }
    
    //MARK: Scrollview delegates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.contentOffset.y < 80) {
            
            self.searchBarView.isHidden = true
            menuBtn.isHidden = false
            navIMage.isHidden = false
            self.searchBarConstraint.constant = 60
            
            if(iDonateClass.hasSafeArea) {
                self.scrollConstraint.constant = 60
            } else{
                self.scrollConstraint.constant = 60
            }
            self.innersearchBarView.isHidden = true
            
        }
        
        if(scrollView.contentOffset.y > 80) {
            self.searchBarView.isHidden = false
            menuBtn.isHidden = true
            navIMage.isHidden = true
        }
        
        print(scrollView.contentOffset.y)
        
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.isDecelerating == false{
            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
                       //you reached end of the table
                       pageCount = pageCount + 1
                       self.charityWebSerice()
                   }
        }
       
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    @objc func myTapAction(recognizer: UITapGestureRecognizer) {
        
        searchBar.resignFirstResponder()
    }
    
    @objc func cancelView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    @objc func backAction(_sender:UIButton)  {
        
        if longitude != "", latitude != "", locationSearch != "Nonprofits"{
            
            longitude = ""
            latitude = ""
            locationSearch = "Nonprofits"
            userID = ""
            selectedIndex = -1
            categoryCode = nil
            subCategoryCode = nil
            childCategory = nil
            deductible = ""
            self.charityWebSerice()
        } else if searchName != ""{
            self.searchBar.text = ""
            self.searchScrollBar.text = ""
            searchName = ""
            
            locationSearch = "Nonprofits"
            if country == "US"{
                searchBar.placeholder = "Search by city/state"
                searchScrollBar.placeholder = "Search by city/state"
            } else {
                searchBar.placeholder = "Search by country"
                searchScrollBar.placeholder = "Search by country"
            }
            nameScrollbtn.isSelected = false
            nameFlg = false
            self.charityWebSerice()
        }
        else {
            self.tabBarController?.selectedIndex = 0
            self.navigationController?.popViewController(animated: true)
        }
        if !locationSearch.isEmpty {
            locationNameText.text = locationSearch + " & charities near you"
        }

    }
    
    func paymentResponse(string: String) {
        print(string)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == amountText) {
            donateFlag = true
            textField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
            UserDefaults.standard.removeObject(forKey: "SelectedType")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField .resignFirstResponder()
        return true
    }
    // MARK: - Dismissal

      @objc func dismissWebView() {
          webView.isHidden = true
          blurView.removeFromSuperview()
          webView.navigationDelegate = nil
          // Perform additional actions if needed after dismissing the web view
      }
//    // MARK: - WKScriptMessageHandler
//
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if let messageBody = message.body as? String, messageBody == "dismissWebView" {
//            dismissWebView()
//        }
//    }
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        // Extract the current URL of the web view
//        if let currentURL = webView.url {
//            // Analyze the URL to determine the payment status
//            let payButtonScript = "document.getElementById('payButton').onclick = function() { window.webkit.messageHandlers.dismissWebView.postMessage('dismissWebView'); }"
//            webView.evaluateJavaScript(payButtonScript, completionHandler: nil)
//            print(webView.url)
//            
//            // Check if the URL contains the success message
//            if currentURL.absoluteString.contains("donation_payment_show_successfull_msg") {
//                // Dismiss the web view
//                dismissWebView()
//
//            
//            }
//            if currentURL.absoluteString.contains("donation_payment_cancel_payment"){
//                dismissWebView()
//                let alertController = UIAlertController(title: "Payment Cancelled", message: "Your donation payment has been cancelled.", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(okAction)
//                present(alertController, animated: true, completion: nil)
//            }
//        }
//    }
    // MARK: - tabBar  delegate methods
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0){
            UserDefaults.standard.set(0, forKey: "tab")
            UserDefaults.standard.synchronize()
            self.navigationController?.pushViewController(vc!, animated: false)
        }
        else{
            UserDefaults.standard.set(1, forKey: "tab")
            UserDefaults.standard.synchronize()
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    
// MARK: - Tableview delegate and datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltering){
            return (filteredCharityListArray?.count)!
        }else{
            return charityListArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let charity: CharityListArray
        print(filteredCharityListArray?[indexPath.row])
        print(charityListArray?[indexPath.row])
        if(isFiltering) {
            charity = (filteredCharityListArray?[indexPath.row])!
        }else {
            charity = charityListArray![indexPath.row]
        }
        
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
        cell.title.text = charity.name
        cell.address.text = charity.street!+","+charity.city!
        let likeString = charity.likeCount! + " Likes"
        cell.likeBtn.setTitle(likeString, for: .normal)
        let placeholderImage = UIImage(named: "defaultImageCharity")!
        print(likeString)
        print(charity.likeCount)
        print(charity.liked)
        if charity.logo != nil && charity.logo != "" {
            if let url = URL(string: charity.logo!) {
                cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)

            }
        } else {
            cell.logoImage.image = placeholderImage
        }
        
        //        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: 150, duration: 0.5, delayFactor: 0.05)
        //        let animator = Animator(animation: animation)
        //        animator.animate(cell: cell, at: indexPath, in: tableView)
        
        cell.followingBtn.tag = indexPath.row
        cell.likeBtn.tag = indexPath.row
        cell.donateBtn.tag = indexPath.row
        cell.followingBtn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
        cell.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        cell.donateBtn.addTarget(self, action: #selector(donateAction(_:)), for: .touchUpInside)

        if(charity.liked == "0"){
            cell.likeBtn.isSelected = false
        }
        else{
            cell.likeBtn.isSelected = true
        }
        let count = charity.followedCount
        if(charity.followed == "0"){
            cell.followingBtn.isSelected = false
            cell.followingBtn.setTitle((count ?? "0") + " Follow", for: .normal)
        }
        else {
            cell.followingBtn.isSelected = true
            cell.followingBtn.setTitle((count ?? "0") + " Following", for: .normal)
            
        }
       
        return cell
    }
   //MARK: END OF TABLEVIEW CELL FOR ROW Method
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let charity: CharityListArray
        if(isFiltering) {
            charity = (filteredCharityListArray?[indexPath.row])!
        }
        else {
            charity = charityListArray![indexPath.row]
        }
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchDetailsVC") as? SearchDetailsVC
        vc?.charityList = charity
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Searchbar delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(nameFlg == false) {
            
         /*   self.view.endEditing(true)
            searchBar.resignFirstResponder()
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocation") as? SearchByLocation
            self.navigationController?.pushViewController(vc!, animated: true) */
        } else {
            searchBar.placeholder = ""
            searchBar.becomeFirstResponder()
        }
    }
   
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if(nameFlg == false){
            if country == "US"{
                searchBar.placeholder = "Search by city/state"
                searchScrollBar.placeholder = "Search by city/state"
                searchBool1 = true
                searchBool2 = false
            } else {
                searchBar.placeholder = "Search by country"
                searchScrollBar.placeholder = "Search by country"
                searchBool2 = true
                searchBool1 = false
            }
            nameScrollbtn.isSelected = false
            nameFlg = false
        } else{
            searchScrollBar.placeholder = "Enter nonprofit/charity name"
            searchBar.placeholder = "Enter nonprofit/charity name"
            typebtn.isSelected = false
            scrollTypebtn.isSelected = false
            nameScrollbtn.isSelected = true
            nameFlg = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(nameFlg == false){
           if country == "US"{
                searchBar.placeholder = "Search by city/state"
                searchScrollBar.placeholder = "Search by city/state"
            } else {
                searchBar.placeholder = "Search by country"
                searchScrollBar.placeholder = "Search by country"
            }
            nameScrollbtn.isSelected = false
            nameFlg = false
        } else{
            searchScrollBar.placeholder = "Enter nonprofit/charity name"
            searchBar.placeholder = "Enter nonprofit/charity name"
            typebtn.isSelected = false
            scrollTypebtn.isSelected = false
            nameScrollbtn.isSelected = true
            nameFlg = true
        }
        self.view.endEditing(true)
    }
    func clearAllTypes(){
        self.categoryCode?.removeAll()
        self.subCategoryCode?.removeAll()
        self.childCategory?.removeAll()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.pageCount = 1
        self.clearAllTypes()
        if searchText.count >= 3 {
            
            searchName = searchText
            self.searchBar.text = searchText
            self.searchScrollBar.text = searchText
           
            self.charityWebSerice(searchKeyWord:searchText)
        } else {
            self.searchBar.text = searchText
            self.searchScrollBar.text = searchText
            searchName = ""
        }
        
        if searchText.count == 0{
            self.charityWebSerice()
        }
    }
    
    
    // MARK:Webservicemethod
    func followAction(follow:String,charityId:String) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            // Joe 10
            let postDict: Parameters = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityId,"status":follow]
            let charityFollowUrl = String(format: URLHelper.iDonateCharityFollow)
            WebserviceClass.sharedAPI.performRequest(type: FollowModel.self, urlString: charityFollowUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                self.charityFollowResponse = response
                self.charityFollowResponseMethod()
                print("Result: \(String(describing: response))") // response serialization result
                
            }) { (response) in
                
            }
        }
        else {
            
        }
    }
    @IBAction func donateAction(_ sender:UIButton)  {
        if let data = UserDefaults.standard.data(forKey: "people"),
                   let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                   print(myPeopleList.name)
                   blurView.frame =  self.view.frame
                   self.continuePaymentBtn.tag = sender.tag
                   self.view.addSubview(blurView)
               } else {
                   let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                   let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                   let messageAttrString = NSMutableAttributedString(string: "For Advance Features Please Log-in/Register", attributes: messageFont)
                   alertController.setValue(messageAttrString, forKey: "attributedMessage")
                   let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                       let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                       
                       self.navigationController?.pushViewController(vc!, animated: true)
                   }
                   let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                       
                   }
                   alertController.addAction(ok)
                   alertController.addAction(cancel)
                   self.present(alertController, animated: true, completion: nil)
               }
    }
    
    func charityFollowResponseMethod() {
        if(self.charityFollowResponse?.status == 1) {
           self.pageCount = 1
           self.charityWebSerice()
        }
    }
    
    func charityLikeAction(like:String,charityId:String) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            // Joe 10
            let postDict: Parameters = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityId,"status":like]
            
            let charityLikeUrl = String(format: URLHelper.iDonateCharityLike)
            
            WebserviceClass.sharedAPI.performRequest(type: CharityLikeModel.self, urlString: charityLikeUrl, methodType: HTTPMethod.post, parameters: postDict,  success: {
                (response) in
                self.charityLikeResponse = response
                self.charityLikeResponseMethod()
                print("Result: \(String(describing: response))")                     // response serialization result
            }) { (response) in
                
            }
        }
        else {
            
        }
    }
    
    func charityLikeResponseMethod() {
        if(self.charityLikeResponse?.status == 1) {
            self.pageCount = 1
            self.charityWebSerice()
        }
    }
    
    @objc func charityWebSerice(searchKeyWord:String = "") {
                
        var postDict: Parameters = ["name":searchName,
                                    "latitude":latitude,
                                    "longitude":longitude,
                                    "page":pageCount,
                                    "address":locationSearch,
                                    "category_code":categoryCode?.joined(separator:",") ?? [String](),
                                    "deductible":deductible,
                                    "income_from":incomeFrom,
                                    "income_to":incomeTo,
                                    "country_code":country,
                                    "sub_category_code":subCategoryCode?.joined(separator:",") ?? [String](),
                                    "child_category_code":childCategory?.joined(separator:",") ?? [String](),
                                    "user_id":userID]
        if (!searchKeyWord.isEmpty && (nameFlg == false)){
            postDict["city"] = searchKeyWord
            postDict["name"] = ""
        }
        
       
        
        print("postDict",postDict)
        print(searchName)
        print(latitude)
        print(longitude)
        print(pageCount)
        print(locationSearch)
        print(categoryCode ?? "")
        print(deductible)
        print(incomeTo)
        print(incomeFrom )
        print(country)
        print(subCategoryCode ??  "")
        print(childCategory ?? "")
        print(userID)
        let charityListUrl = String(format: URLHelper.iDonateCharityList)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        WebserviceClass.sharedAPI.performRequest(type: CharityModel.self, urlString: charityListUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: {
            (response) in
         print(response)
            if self.pageCount == self.previousPageCount && self.pageCount != 1{
                
            } else {
                if self.charityResponse == nil || self.pageCount == 1 {
                    self.charityResponse = response
                    self.charityListArray =  response.data.sorted{ $0.name?.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
                    print(self.charityResponse)
                } else {
                    self.charityResponse?.data.append(contentsOf: response.data)
                    self.charityListArray?.append(contentsOf: response.data)
                    
                }
            }
        
            self.responsemethod()
            print("Result: \(String(describing: response))")                     // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }
    
    
    func responsemethod() {
        debugPrint("pageCount",pageCount)
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
        }
        if(charityResponse?.status == 1){
            self.noresultsview.isHidden = true
        }else {
            if pageCount <= 1{
                self.noresultsview.isHidden = false
                self.noresultMessage.text = charityResponse?.message
            }
        }
    }
}

extension SearchByLocationVC {
    
    @IBAction func showProcessingCharges(_ sender:UIButton) {
        
        self.view.endEditing(true)
        
        processingCharges.isHidden = false
        processingCharges.layer.cornerRadius = 10
        
        
        guard let amount = amountText.text else {
            return
        }
        
        let amountWithoutDollar = amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard Double(amountWithoutDollar) != 0 else {
            return
        }
        
       let processingValue = self.calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 1)
        
        let amountWithProcessingValue = (Double(amountWithoutDollar) ?? 0) + processingValue
        
        let merchantChargesValue = self.calculatePercentage(value: amountWithProcessingValue ,percentageVal: 2.9) + 0.30
        
        let totalAmount = amountWithProcessingValue + merchantChargesValue

        processingCharges.donationAmountValue.text = "$ "+amountWithoutDollar
        processingCharges.processingFeeValue.text = "$ "+String(format: "%.2f", processingValue)
        processingCharges.merchantChargesValue.text = "$ "+String(format: "%.2f", merchantChargesValue)
        processingCharges.totalAmountValue.text = "$ "+String(format: "%.2f", totalAmount)

        self.view.addSubview(processingCharges)
    
        processingCharges.closeBtn.addTarget(self, action: #selector(hideProcessingCharges), for: .touchUpInside)
    }
    
    @objc func hideProcessingCharges() {
        processingCharges.isHidden = true
        processingCharges.removeFromSuperview()
    }
    
}
  
var decimalAdded = false
extension SearchByLocationVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.amountText.text!.isEmpty {
            decimalAdded = false
        }
        if self.amountText.text!.contains(".") {
            decimalAdded = true
        }else{
            decimalAdded = false
        }
        if decimalAdded && string == "." {
            return false
        }
        if textField != self.amountText {
            if range.length>0  && range.location == 0 {
                return false
            }
            return true
        }
        let computationString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        debugPrint("string ?? ",string)
        if computationString.contains("..") {
            return false
        }
        let arrayOfSubStrings = computationString.components(separatedBy: ".")
        if arrayOfSubStrings.count == 1 && computationString.count > digitBeforeDecimal {//
            return false
        } else if arrayOfSubStrings.count == 2 {
            let stringPostDecimal = arrayOfSubStrings[1]
            return stringPostDecimal.count <= digitAfterDecimal
        }
       
        return true
    }
    
}


extension Double {
    var dollarString:String {
        return String(format: "%.2f", self)
    }
}

