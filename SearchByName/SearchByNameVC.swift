//
//  SearchByNameVC.swift
//  i2-Donate
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireImage
import TKFormTextField
import WebKit
import SafariServices



///The SearchByNameVC class is a view controller responsible for managing the search functionality within the i2-Donate application. Its main responsibilities include Handling user input for searching charities by name or type.

class SearchByNameVC: BaseViewController,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate,UITextFieldDelegate,WKNavigationDelegate,WKScriptMessageHandler, WKUIDelegate, SFSafariViewControllerDelegate{
    
    
    // MARK: - Outlets
    @IBOutlet var notificationTabBar: UITabBar!  // Tab bar for navigation within the app
    @IBOutlet var searchTableView: UITableView!  // Table view to display search results
    @IBOutlet var searchBar: UISearchBar!  // Main search bar for user input
    @IBOutlet var searchScrollBar: UISearchBar!  // Secondary search bar for user input
    @IBOutlet var containerView: UIView!  // Container view for holding other UI elements
    @IBOutlet var searchBarView: UIView!  // View containing the main search bar
    @IBOutlet var innersearchBarView: UIView!  // Subview within the search bar view
    @IBOutlet var namebtn: UIButton!  // Button to initiate search by name
    @IBOutlet var nameScrollbtn: UIButton!  // Button for name search in a scrollable context
    @IBOutlet var typebtn: UIButton!  // Button to initiate search by type
    @IBOutlet var typeScrollbtn: UIButton!  // Button for type search in a scrollable context
    @IBOutlet weak var searchBarConstraint: NSLayoutConstraint!  // Layout constraint for the search bar
    @IBOutlet weak var scrollcontraint: NSLayoutConstraint!  // Layout constraint for the scroll view
    @IBOutlet var noresultsview: UIView!  // View displayed when no search results are found
    @IBOutlet var selectedlbl: UILabel!  // Label displaying the selected search category/type
    @IBOutlet var blurView: UIVisualEffectView!  // View with blur effect for dimming background
    @IBOutlet var amountText: UITextField!  // Text field for entering donation amounts
    @IBOutlet var continuePaymentBTn: UIButton!  // Button to proceed with payment or donation
    @IBOutlet var titlelbl: UILabel!  // Label displaying the title of the current view or search mode
    @IBOutlet var noresultMEssage: UILabel!  // Label displaying a message when no search results are found
    @IBOutlet var locationBtn: UIButton!  // Button to enable location-based search



    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    // MARK: - Properties
    var categoryCode = [String]()
    var subCategoryCode = [String]()
    var childCategory = [String]()
    var deductible = String()
    var webView: WKWebView!

    var nameFlg:Bool = true
    var donateFlag:Bool = false
    var charityResponse :  CharityModel?
    var charityLikeResponse :  CharityLikeModel?
    var charityFollowResponse :  FollowModel?
    var charityListArray : [charityListArray]?
    var filterdCharityListArray : [charityListArray]?
    var isFiltering:Bool = false
    var longitute:String = ""
    var lattitude:String = ""
    var locationSearch:String = ""
    var userID:String = ""
    var selectedIndex:Int = -1
    weak var payDelegate: PaymentDelegate?
    
    var selectedCharity:charityListArray? = nil
    var pageCount = 1
    var searchedName = ""
    var searchEnabled = "false"
    var incomeFrom = ""
    var incomeTo = ""
    
    var previousPageCount = 1
    var comingFromType = false
    var filterType = ""
    var previousNameKeyWord = ""
    var isFromAdvanceSearch = false


    fileprivate func changePlaceholderText(_ searchBarCustom: UISearchBar) {
        searchBarCustom.placeholder = "Enter nonprofit / charity name"
        searchBarCustom.set(textColor: .white)
        searchBarCustom.setTextField(color: UIColor.clear)
        searchBarCustom.setPlaceholder(textColor: .white)
        searchBarCustom.setSearchImage(color: .white)
        searchBarCustom.setClearButton(color: .white)
    }
    
    let digitBeforeDecimal = 5
    let digitAfterDecimal = 2
    var decimalAdded = false
    func textField(_ textField: UITextField, shouldChangeCharactersIn   range: NSRange, replacementString string: String) -> Bool {
        
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
            return true
        }
        let computationString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
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
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
        
        // Adjust layout constraints based on safe area presence
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            self.scrollcontraint.constant = 80
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add target for back button
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Customize search bars
        iDonateClass.sharedClass.customSearchBar(searchBar: searchBar)
        iDonateClass.sharedClass.customSearchBar(searchBar: searchScrollBar)
        
        // Add gesture recognizers
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        mytapGestureRecognizer.cancelsTouchesInView = false
        mytapGestureRecognizer.delegate = self
        self.containerView.addGestureRecognizer(mytapGestureRecognizer)
        
        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
        mytapGestureRecognizer1.numberOfTapsRequired = 1
        mytapGestureRecognizer1.cancelsTouchesInView = false
        self.blurView.addGestureRecognizer(mytapGestureRecognizer1)
        
        // Setup container view for table header
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.searchTableView.tableHeaderView = containerView
        containerView.centerXAnchor.constraint(equalTo: self.searchTableView.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.searchTableView.widthAnchor, constant: -10).isActive = true
        containerView.topAnchor.constraint(equalTo: self.searchTableView.topAnchor).isActive = true
        self.searchTableView.tableHeaderView?.layoutIfNeeded()
        self.searchTableView.tableHeaderView = self.searchTableView.tableHeaderView
        
        self.searchTableView.isScrollEnabled = true
        
        // Initialize and setup the web view
        self.webView = WKWebView(frame: self.view.frame)
        self.webView.navigationDelegate = self
        self.webView?.uiDelegate = self
        
        // Retrieve user data
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            userID = myPeopleList.userID
        }
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Setup table view
        searchTableView.estimatedRowHeight = UITableView.automaticDimension
        
        // Customize placeholder text for search bars
        changePlaceholderText(searchBar)
        changePlaceholderText(searchScrollBar)
        
        // Update title label based on context
        if comingFromType == false {
            self.titlelbl.text = "SEARCH BY NAME"
        } else {
            self.titlelbl.text = "SEARCH BY TYPE"
        }
        if self.isFromAdvanceSearch {
            if comingFromType == false {
                self.titlelbl.text = "ADVANCE SEARCH BY NAME"
            } else {
                self.titlelbl.text = "ADVANCE SEARCH BY TYPE"
            }
        }
        
        // Dismiss keyboard when tapped around
        self.hideKeyboardWhenTappedAround()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        // Remove SelectedType from UserDefaults if it exists
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil) {
            UserDefaults.standard.removeObject(forKey: "SelectedType")
        }
        
        // Store current page count to previous page count
        self.previousPageCount = self.pageCount
        
        // Reset location data in UserDefaults and instance variables
        UserDefaults.standard.set("", forKey: "latitude")
        UserDefaults.standard.set("", forKey: "longitude")
        UserDefaults.standard.set("", forKey: "locationname")
        
        lattitude  = ""
        longitute = ""
        locationSearch = ""
    }

    
    override func viewWillAppear(_ animated: Bool) {
        // Update location data if it has changed
        if lattitude != "\(UserDefaults.standard.value(forKey: "latitude") ?? "")" {
            lattitude  = UserDefaults.standard.value(forKey: "latitude") as! String
            longitute = UserDefaults.standard.value(forKey: "longitude") as! String
            locationSearch = UserDefaults.standard.value(forKey: "locationname") as! String
            self.charityWebSerice()
        }
        
        // Update UI for SelectedType if it exists
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
            nameScrollbtn.isSelected = true
            namebtn.isSelected =  true
            typeScrollbtn.isSelected = true
            selectedlbl.text = ((UserDefaults.standard.value(forKey:"SelectedType")) as! String)
        } else{
            typebtn.isSelected = false
        }
        
        // Set placeholders for search bars
        searchScrollBar.placeholder = "Enter nonprofit/charity name"
        searchBar.placeholder = "Enter nonprofit/charity name"
        
        // Set search bar texts to locationSearch
        searchBar.text = locationSearch
        searchScrollBar.text = locationSearch
        
        // Preserve the searched name
        if !self.searchedName.isEmpty {
            self.searchBar.text = self.searchedName
        }
        
        // Call charity web service
        self.charityWebSerice()
    }

    
    /**
     Observes and handles the keyboard show notification, adjusting the view's frame to accommodate the keyboard if `donateFlag` is `true`.

     - Parameter notification: The notification object containing information about the keyboard.
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if donateFlag {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }

    /**
     Observes and handles the keyboard hide notification, resetting the view's frame to its original position.
     
     - Parameter notification: The notification object containing information about the keyboard.
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    /**
     Delegate method called when the scroll view's content is scrolled. Manages the visibility and position of UI elements based on the scroll view's content offset.

     - Parameter scrollView: The scroll view.
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 80 {
            // Hide certain UI elements and adjust constraints
            self.searchBarView.isHidden = true
            menuBtn.isHidden = false
            navIMage.isHidden = false
            self.searchBarConstraint.constant = 100
            self.scrollcontraint.constant = iDonateClass.hasSafeArea ? 60 : 60
            self.innersearchBarView.isHidden = true
        }

        if scrollView.contentOffset.y > 80 {
            // Show search bar view when scrolling down
            self.searchBarView.isHidden = false
            menuBtn.isHidden = true
            navIMage.isHidden = true
        }
    }

    /**
     Delegate method called when scrolling ends. Checks if the scroll view has reached the bottom and triggers data fetching if necessary.

     - Parameter scrollView: The scroll view.
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating == false {
            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
                // Reached end of the table, increment pageCount and fetch data
                pageCount += 1
                self.charityWebSerice()
            }
        }
    }

    /**
     Handles the action when the filter button is tapped, toggling the visibility of the inner search bar view and adjusting constraints.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func filterAction(_ sender:UIButton) {
        if sender.tag == 0 {
            // Expand search bar view
            UIView.animate(withDuration: 1) {
                self.scrollcontraint.constant = iDonateClass.hasSafeArea ? 100 : 120
                self.searchBarConstraint.constant = iDonateClass.hasSafeArea ? 100 : 120
                self.innersearchBarView.isHidden = false
            }
            sender.tag = 1
        } else {
            // Collapse search bar view
            sender.tag = 0
            self.scrollcontraint.constant = iDonateClass.hasSafeArea ? 60 : 60
            self.searchBarConstraint.constant = iDonateClass.hasSafeArea ? 60 : 100
            self.innersearchBarView.isHidden = true
        }
    }

    /**
     Handles tap gestures outside the search bar, resetting the search bar's placeholder and resigning the keyboard.

     - Parameter recognizer: The tap gesture recognizer.
     */
    @objc func myTapAction(recognizer: UITapGestureRecognizer) {
        searchBar.placeholder = "Enter nonprofit/charity name"
        searchBar.resignFirstResponder()
    }

    
    /**
     Handles the action when the back button is tapped. It resets location and search-related variables and triggers data fetching if necessary, or navigates back to the previous screen.

     - Parameter _sender: The button that triggered the action.
     */
    @objc func backAction(_sender:UIButton)  {
        if longitute != "", lattitude != "", locationSearch != "Nonprofits" {
            // Reset location-related variables and fetch data
            longitute = ""
            lattitude = ""
            locationSearch = "Nonprofits"
            userID = ""
            selectedIndex = -1
            self.charityWebSerice()
        } else if searchedName != "" {
            // Clear search bar and search-related variables and fetch data
            self.searchBar.text = ""
            self.searchScrollBar.text = ""
            searchedName = ""
            locationSearch = "Nonprofits"
            searchBar.placeholder = "Enter nonprofit / charity name"
            searchScrollBar.placeholder = "Enter nonprofit / charity name"
            nameScrollbtn.isSelected = false
            nameFlg = false
            self.charityWebSerice()
        } else {
            // Navigate back to previous screen
            self.tabBarController?.selectedIndex = 0
            self.navigationController?.popViewController(animated: true)
        }
        
        // Clear search bars
        searchBar.text = ""
        searchScrollBar.text = ""
    }

    /**
     Handles tap gestures to dismiss the keyboard.

     - Parameter recognizer: The tap gesture recognizer.
     */
    @objc func cancelView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    /**
     Handles the action when the cancel button is tapped, removing the blur view.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func cancelAction(_ sender:UIButton) {
        blurView.removeFromSuperview()
    }

    /**
     Handles the action when the location button is tapped, toggling its selection state.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func locationAction(_ sender:UIButton) {
        sender.isSelected.toggle()
    }

    /**
     Handles the action when the type button is tapped, navigating to the AdvancedVC screen with relevant parameters.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func typeAction(_ sender:UIButton) {
        sender.isSelected = true
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
        debugPrint("searchedName",searchedName)
        vc?.address = locationSearch
        vc?.latitude = lattitude
        vc?.longitude = longitute
        vc?.countryCode = ""
        vc?.searchNameKey = searchedName
        vc?.comingFromType = comingFromType
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    /**
     Handles the action when the name button is tapped, resetting search-related variables and placeholders.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func nameAction(_ sender:UIButton)  {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
        searchedName = ""
        self.searchBar.text = ""
        self.searchScrollBar.text = ""
        searchBar.placeholder = "Enter City/Sate"
        searchScrollBar.placeholder = "Enter City/Sate"
    }

    /**
     Handles the action when the name scroll button is tapped, resetting search-related variables, placeholders, and setting the filter type.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func nameSCrollAction(_ sender:UIButton)  {
        self.searchBar.text = ""
        self.searchScrollBar.text = ""
        searchedName = ""
        self.searchBar.text = ""
        self.searchScrollBar.text = ""
        searchBar.placeholder = "Enter City/Sate"
        searchScrollBar.placeholder = "Enter City/Sate"
        self.filterType = "location"
    }

    /**
     Handles the action when the like button is tapped, toggling the like status of a charity and performing the respective action.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func likeAction(_ sender:UIButton)  {
        // Check if user is logged in
        if let data = UserDefaults.standard.data(forKey: "people"), let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            var likeCount:String = ""
            userID = myPeopleList.userID
            let charityObject = charityListArray![sender.tag]
            if sender.isSelected {
                sender.isSelected = false
                likeCount = "0"
            } else {
                likeCount = "1"
                sender.isSelected = true
            }
            selectedIndex = sender.tag
            charityLikeAction(like: likeCount, charityId: charityObject.id!)
        } else {
            // Display login/register prompt if not logged in
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

    /**
     Handles the action when the follow button is tapped, toggling the follow status of a charity and performing the respective action.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func followAction(_ sender:UIButton)  {
        // Check if user is logged in
        if let data = UserDefaults.standard.data(forKey: "people"), let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            var followCount:String = ""
            userID = myPeopleList.userID
            let charityObject = charityListArray![sender.tag]
            if sender.isSelected {
                sender.isSelected = false
                followCount = "0"
            } else {
                followCount = "1"
                sender.isSelected = true
            }
            selectedIndex = sender.tag
            followAction(follow: followCount, charityId: charityObject.id!)
        } else {
            // Display login/register prompt if not logged in
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
    

    /**
     Handles the action when the donate button is tapped, displaying the payment view if the user is logged in.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func donateAction(_ sender:UIButton)  {
        // Check if user is logged in
        if let data = UserDefaults.standard.data(forKey: "people"), let _ = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            blurView.frame =  self.view.frame
            self.continuePaymentBTn.tag = sender.tag
            self.view.addSubview(blurView)
        } else {
            // Display login/register prompt if not logged in
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

    /**
     Handles the action when the payment button is tapped, initiating the donation process for a charity.

     - Parameter sender: The button that triggered the action.
     */
    @IBAction func paymentAction(_ sender:UIButton) {
        // Check if user is logged in
        if let data = UserDefaults.standard.data(forKey: "people"), let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            let charityObject = charityListArray![self.continuePaymentBTn.tag]
            donateToCharity(charityID: charityObject.id!)
        }
    }

    /**
     Initiates the donation process for a charity with the provided charity ID.

     - Parameter charityID: The ID of the charity to donate to.
     */
    func donateToCharity(charityID: String) {
        // Display loading indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let data = UserDefaults.standard.data(forKey: "people"), let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                let userID = myPeopleList.userID
                let postDict = ["user_id": userID, "charity_id": charityID]
                let iDonateTransString = "https://devb.i2-donate.com/i2d_mob/webservice/donate_trans"
                WebserviceClass.sharedAPI.performRequest(type: [String: String].self, urlString: iDonateTransString, methodType: .post, parameters: postDict, success: { (response) in
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                    if let url = response["url"] as? String, let paymentURL = URL(string: url) {
                        let safariViewController = SFSafariViewController(url: paymentURL)
                        safariViewController.delegate = self
                        self.present(safariViewController, animated: true, completion: nil)
                    } else {
                        print("Error: Invalid payment URL")
                    }
                }) { (error) in
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                    print("Error: \(error)")
                    // You may display an error message to the user if needed
                }
            }
        }
    }

    // Function to dismiss the web view
    @objc func dismissWebView() {
        webView.isHidden = true
        blurView.removeFromSuperview()
        webView.navigationDelegate = nil
    }

    /**
     Handles the message received by the web view from JavaScript.

     - Parameters:
       - userContentController: The user content controller that received the message.
       - message: The message received from JavaScript.
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? String, messageBody == "dismissWebView" {
            dismissWebView()
        }
    }

    // Delegate method called when the web view finishes loading a new navigation.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Check if the URL contains the success message
        if let currentURL = webView.url {
            if currentURL.absoluteString.contains("donation_payment_show_successfull_msg") {
                // Dismiss the web view
                dismissWebView()
            }
            if currentURL.absoluteString.contains("donation_payment_cancel_payment") {
                // Dismiss the web view and display a message
                dismissWebView()
                let alertController = UIAlertController(title: "Payment Cancelled", message: "Your donation payment has been cancelled.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    ///This method is called when the text field begins editing.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        donateFlag = true
        
        textField.becomeFirstResponder()
    }
    ///This method is called when the return key is pressed in the text field.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    ///This method is called when the advanced search button is tapped.
    @IBAction func advancedSearch(_ sender:UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "newcontrollerID") as? NewViewfromadvancedSearchViewController
            vc?.address = locationSearch
            vc?.latitude = lattitude
            vc?.longitude = longitute
            vc?.countryCode = ""
            vc?.searchNameKey = self.searchedName
            self.searchedName = ""
            self.navigationController?.pushViewController(vc!, animated: true)
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
    
    // MARK: - tableview delegate and datasource
    
    ///Decides how many rows the table should have.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isFiltering){
            return (filterdCharityListArray?.count)!
        } else{
            return charityListArray?.count ?? 0
        }
        
    }
    ///This function fills each row of the table with information about a charity, like its name, address, and number of likes.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let charity: charityListArray
        
        if(isFiltering) {
            charity = (filterdCharityListArray?[indexPath.row])!
        }else {
            charity = charityListArray![indexPath.row]
        }
        
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
        cell.title.text = charity.name
        cell.address.text = charity.street!+","+charity.city!
        let likeString = charity.like_count! + " Likes"
        cell.likeBtn.setTitle(likeString, for: .normal)
        let placeholderImage = UIImage(named: "defaultImageCharity")!
        
        if charity.logo != nil {
            if let url = URL(string: charity.logo!) {
                cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
            }
            
        } else {
            cell.logoImage.image = placeholderImage
        }
        
        cell.followingBtn.tag = indexPath.row
        cell.likeBtn.tag = indexPath.row
        cell.donateBtn.tag = indexPath.row
        cell.followingBtn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
        cell.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        cell.donateBtn.addTarget(self, action: #selector(donateAction), for: .touchUpInside)
        
        if(charity.liked == "0") {
            cell.likeBtn.isSelected = false
        } else{
            cell.likeBtn.isSelected = true
        }
        
        let count = charity.followed_count
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
    ///
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Getting information about the selected charity

        let charity: charityListArray
        
        if(isFiltering) {
            charity = (filterdCharityListArray?[indexPath.row])!
        } else{
            charity = charityListArray![indexPath.row]
        }
        // Navigating to a new screen to show details about the selected charity

        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchDetailsVC") as? SearchDetailsVC
        vc?.charityList = charity
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - tabBar  delegate methods
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0) {
            UserDefaults.standard.set(0, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        } else {
            UserDefaults.standard.set(1, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    // MARK: - searchbar delegate
    ///Whenever the user types something in the search bar, this function updates the list of charities displayed according to the entered text.
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(nameFlg == false){
            //self.clearAllTypes()
            self.view.endEditing(true)
            searchBar .resignFirstResponder()
            searchedName = ""
            self.searchBar.text = ""
            self.searchScrollBar.text = ""
            searchBar.placeholder = "Enter City/Sate"
            searchScrollBar.placeholder = "Enter City/Sate"
    
        } else{
            searchBar.placeholder = ""
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if(nameFlg == false){
            searchBar.placeholder = "Enter City/Sate"
            searchScrollBar.placeholder = "Enter City/Sate"
            nameScrollbtn.isSelected = false
            nameFlg = false
        } else{
            searchScrollBar.placeholder = "Enter nonprofit/charity name"
            searchBar.placeholder = "Enter nonprofit/charity name"
            typebtn.isSelected = false
            nameScrollbtn.isSelected = true
            nameFlg = true
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        self.view.endEditing(true)
    }
    
    func clearAllTypes(){
        self.categoryCode.removeAll()
        self.subCategoryCode.removeAll()
        self.childCategory.removeAll()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.pageCount = 1
        debugPrint("comingFromType",comingFromType)
        if comingFromType == false {
            self.clearAllTypes()
        }
        
        //
        if searchText.count >= 3 {
            searchedName = searchText
            self.searchBar.text = searchText
            self.searchScrollBar.text = searchText
            if self.filterType != "location" {
                self.previousNameKeyWord = searchText
            }
            self.charityWebSerice(searchKeyWord: searchText)
        } else {
            self.searchBar.text = searchText
            self.searchScrollBar.text = searchText
            searchedName = ""
        }
        
        if searchText.count == 0{
            setFilterForName()
            self.charityWebSerice()
        }

    }
    func charityWebSerice(searchKeyWord:String = "") {
            debugPrint("categoryCode",categoryCode)
            var postDict: Parameters = ["name":searchedName,
                                        "latitude":lattitude,
                                        "longitude":longitute,
                                        "page":pageCount,
                                        "address":locationSearch,
                                        "category_code":categoryCode.joined(separator:",") ,
                                        "deductible":deductible,
                                        "income_from":incomeFrom,
                                        "income_to":incomeTo,
                                        "country_code":"US",
                                        "sub_category_code":subCategoryCode.joined(separator:",") ,
                                        "child_category_code":childCategory.joined(separator:",") ,
                                        "user_id":userID]
            if (self.filterType == "location") {
                postDict["city"] = searchKeyWord
                postDict["name"] = self.previousNameKeyWord
            }
            
            debugPrint("Name:Search:postDict",postDict)
            let charityListUrl = String(format: URLHelper.iDonateCharityList)
            let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            
            WebserviceClass.sharedAPI.performRequest(type: CharityModel.self, urlString: charityListUrl, methodType:  HTTPMethod.post, parameters: postDict, success: { (response) in
                debugPrint("response.count",response.data.count)
                if self.pageCount == self.previousPageCount && self.pageCount != 1{
                    
                } else {
                    if self.charityResponse == nil && self.pageCount == 1 {
                        self.charityResponse = response
                        self.charityListArray =  response.data.sorted{ $0.name?.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
                    } else if  self.pageCount == 1 {
                        self.charityResponse = response
                        self.charityListArray =  response.data.sorted{ $0.name?.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
                    } else {
                        self.charityResponse?.data.append(contentsOf: response.data)
                        self.charityListArray?.append(contentsOf: response.data)
                    }
                }
                
                
                self.responseMethod()
                
                print("Result: \(String(describing: response))") // response serialization result
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                
            }) { (_) in
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            }
        }
    func setFilterForName() {
        self.filterType = ""
        self.previousNameKeyWord = ""
        searchScrollBar.placeholder = "Enter nonprofit/charity name"
        searchBar.placeholder = "Enter nonprofit/charity name"
    }
    
    // MARK:Webservicemethod
    // Performs an action to follow/unfollow a charity.
    func followAction(follow:String,charityId:String) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            // Joe 10
            let postDict = ["user_id":myPeopleList.userID,
                            "token":myPeopleList.token,
                            "charity_id":charityId,
                            "status":follow]
            let charityFollowUrl = String(format: URLHelper.iDonateCharityFollow)
            WebserviceClass.sharedAPI.performRequest(type: FollowModel.self, urlString: charityFollowUrl, methodType:  HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                self.charityFollowResponse = response
                self.charityFollowResponseMethod()
                print("Result: \(String(describing: response))")                     // response serialization result
            }) { (response) in
                
            }
        }
        else {
            
        }
    }
    
    func charityFollowResponseMethod() {
       if(self.charityFollowResponse?.status == 1) {
           self.pageCount = 1
           self.charityWebSerice()
        }
    }
    ///Enables users to like or unlike charities they are interested in.

    func charityLikeAction(like:String,charityId:String) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            // Joe 10
            let postDict = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityId,"status":like]
            let charityLikeUrl = String(format: URLHelper.iDonateCharityLike)
            
            WebserviceClass.sharedAPI.performRequest(type: CharityLikeModel.self, urlString: charityLikeUrl, methodType:  HTTPMethod.post, parameters: postDict, success: { (response) in
                self.charityLikeResponse = response
                self.charityLikeResponseMethod()
                print("Result: \(String(describing: response))")                     // response serialization result
                
            }) { (response) in
                
            }
        }
        else {
            
        }
    }
    //Handle the response after following or liking a charity.
    func charityLikeResponseMethod(){
        if(self.charityLikeResponse?.status == 1) {
           self.pageCount = 1
           self.charityWebSerice()
        }
    }
    
    /**
     Fetches charity data from the server based on search parameters.

     - Parameters:
        - searchKeyWord: The keyword used for searching charities.

     This method constructs a dictionary containing various parameters for the API request, such as the search keyword, location coordinates, category codes, etc. It adjusts the parameters based on the search filter type (e.g., "location"). Then, it sends an HTTP POST request to the server using the performRequest method of a shared API service. After receiving the response from the server, it updates the charity list in the app's UI accordingly.

     - Note: This method assumes the availability of various instance properties, such as `categoryCode`, `deductible`, `incomeFrom`, `incomeTo`, `userID`, `locationSearch`, `lattitude`, `longitute`, `pageCount`, `previousPageCount`, `charityResponse`, `charityListArray`, `searchTableView`, `noresultsview`, and `noresultMEssage`.

     - Returns: None.
    */
    func charityWebService(searchKeyWord: String = "") {
        // Constructing parameters for the API request
        var postDict: Parameters = [
            "name": searchedName,
            "latitude": lattitude,
            "longitude": longitute,
            "page": pageCount,
            "address": locationSearch,
            "category_code": categoryCode.joined(separator: ","),
            "deductible": deductible,
            "income_from": incomeFrom,
            "income_to": incomeTo,
            "country_code": "US",
            "sub_category_code": subCategoryCode.joined(separator: ","),
            "child_category_code": childCategory.joined(separator: ","),
            "user_id": userID
        ]

        // Adjusting parameters based on the search filter type
        if self.filterType == "location" {
            postDict["city"] = searchKeyWord
            postDict["name"] = self.previousNameKeyWord
        }

        debugPrint("Name:Search:postDict", postDict)

        // Constructing the URL for charity list API
        let charityListUrl = String(format: URLHelper.iDonateCharityList)

        // Showing loading indicator
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"

        // Sending HTTP POST request to fetch charity data
        WebserviceClass.sharedAPI.performRequest(type: CharityModel.self, urlString: charityListUrl, methodType: HTTPMethod.post, parameters: postDict, success: { (response) in
            debugPrint("response.count", response.data.count)

            // Handling the response
            if self.pageCount == self.previousPageCount && self.pageCount != 1 {
                // Append new data to existing charity list
            } else {
                if self.charityResponse == nil && self.pageCount == 1 {
                    // Set retrieved data as the new charity list
                } else if self.pageCount == 1 {
                    // Set retrieved data as the new charity list
                } else {
                    // Append new data to existing charity list
                }
            }

            // Handle UI updates based on response
            self.responseMethod()

            print("Result: \(String(describing: response))") // Response serialization result

            // Hide loading indicator
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }) { (_) in
            // Hide loading indicator in case of failure
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }

    /**
     Handles the response from the server after fetching charity data.

     This method reloads the table view to reflect the latest charity data. If the response status indicates success, it hides the "no results" view; otherwise, it shows an error message if no results are found.

     - Note: This method assumes the availability of instance properties such as `searchTableView`, `charityResponse`, `charityListArray`, `noresultsview`, and `noresultMEssage`.

     - Returns: None.
    */
    func responseMethod() {
            self.searchTableView .reloadData()
            if(charityResponse?.status == 1) {
                self.noresultsview.isHidden = true
            } else {
                if pageCount <= 1{
                    self.noresultsview.isHidden = false
                    self.noresultMEssage.text = charityResponse?.message
                }
            }
        }

    /**
     Determines whether the gesture recognizer should receive the touch event.

     This method is called when a touch event is detected by the gesture recognizer. It checks if the gesture recognizer is a UITapGestureRecognizer and whether the touch occurred outside the searchTableView. If so, it returns true to allow the gesture recognizer to handle the touch event; otherwise, it returns false.

     - Parameters:
        - gestureRecognizer: The gesture recognizer that detected the touch event.
        - touch: The touch event detected by the gesture recognizer.

     - Returns: A boolean value indicating whether the gesture recognizer should receive the touch event.
    */
    private func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.location(in: searchTableView)
            return (searchTableView.indexPathForRow(at: location) == nil)
        }
        return true
    }

    
}

/**
 Extends the functionality of SearchByNameVC to conform to the SearchByCityDelegate protocol.

 This extension adds the implementation of the getCharityListFromPlaces method, which is required by the SearchByCityDelegate protocol. It retrieves input details related to city-based charity search and updates relevant properties of SearchByNameVC to trigger a new charity search.

 - Note: This extension assumes the availability of instance properties such as `searchEnabled`, `lattitude`, `longitute`, `locationSearch`, `pageCount`, and `charityWebSerice`.

 - Parameters:
    - inputDetails: A dictionary containing input details for city-based charity search.

 - Returns: None.
*/
extension SearchByNameVC: SearchByCityDelegate {
    func getCharityListFromPlaces(inputDetails: [String: String]) {
        print("inputDetails", inputDetails)

        // Update instance properties based on input details
        self.searchEnabled = inputDetails["placesFlag"]!
        self.lattitude = inputDetails["latitude"]!
        self.longitute = inputDetails["longitude"]!
        self.locationSearch = inputDetails["locationname"]!
        self.pageCount = 1

        // Trigger charity search based on updated properties
        self.charityWebService()
    }
}

extension SearchByNameVC {
    
    /**
     Handles the action of showing processing charges for a donation amount.
     
     This method is triggered when the user taps on the "Show Processing Charges" button. It calculates the processing charges and total amount based on the entered donation amount, and displays them in a popup view.
     
     - Note: This method assumes the availability of instance properties such as `processingCharges`, `amountText`, and `processingCharges` view.
     
     - Returns: None.
     */
    @IBAction func showProcessingCharges(_ sender: UIButton) {
        // Dismiss keyboard
        self.view.endEditing(true)
        
        // Show processing charges view
        processingCharges.isHidden = false
        processingCharges.layer.cornerRadius = 10
        
        guard let amount = amountText.text else {
                   return
               }
               
        
        // If the entered amount is available
        let amountWithoutDollar = amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let donationAmount = Double(amountWithoutDollar), donationAmount != 0 else {
            return
        }
        
        // Calculate processing charges
        let processingValue = calculatePercentage(value: donationAmount, percentageVal: 1)
        let amountWithProcessingValue = donationAmount + processingValue
        let merchantChargesValue = calculatePercentage(value: amountWithProcessingValue, percentageVal: 2.9) + 0.30
        let totalAmount = amountWithProcessingValue + merchantChargesValue
        
        // Update processing charges view with calculated values
        processingCharges.donationAmountValue.text = "$ " + amountWithoutDollar
        processingCharges.processingFeeValue.text = "$ " + String(format: "%.2f", processingValue)
        processingCharges.merchantChargesValue.text = "$ " + String(format: "%.2f", merchantChargesValue)
        processingCharges.totalAmountValue.text = "$ " + String(format: "%.2f", totalAmount)
        
        // Add processing charges view to the main view
        self.view.addSubview(processingCharges)
        
        // Add target action for closing processing charges view
        processingCharges.closeBtn.addTarget(self, action: #selector(hideProcessingCharges), for: .touchUpInside)
    }
    
    /**
     Handles the action of hiding the processing charges view.
     
     This method is triggered when the user taps on the close button of the processing charges view. It hides the processing charges view from the screen.
     
     - Note: This method assumes the availability of the `processingCharges` view.
     
     - Returns: None.
     */
    @objc func hideProcessingCharges() {
        processingCharges.isHidden = true
        processingCharges.removeFromSuperview()
    }
}

/**
 Extension of UISearchBar to provide customization options.

 This extension adds methods to customize the appearance of a UISearchBar, including setting text color, placeholder text color, clear button color, background color of the text field, and tint color of the search icon.

 - Note: This extension assumes the availability of instance properties such as `searchBarStyle`.

 - Returns: None.
*/
extension UISearchBar {

    // Method to retrieve the text field of the search bar
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }

    // Method to set the text color of the search bar
    func set(textColor: UIColor) { if let textField = getTextField() { textField.textColor = textColor } }

    // Method to set the placeholder text color of the search bar
    func setPlaceholder(textColor: UIColor) { getTextField()?.setPlaceholder(textColor: textColor) }

    // Method to set the clear button color of the search bar
    func setClearButton(color: UIColor) { getTextField()?.setClearButton(color: color) }

    // Method to set the background color of the text field of the search bar
    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }

    // Method to set the tint color of the search icon
    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}
/**
 Private extension of UITextField to provide additional functionality.

 This extension adds methods to customize the appearance of a UITextField, including setting the placeholder text color and clear button color.

 - Note: This extension assumes the availability of instance properties such as `placeholderLabel`.

 - Returns: None.
*/
private extension UITextField {
    
    // Internal class to customize the placeholder text color
    private class Label: UILabel {
        private var _textColor = UIColor.lightGray
        override var textColor: UIColor! {
            set { super.textColor = _textColor }
            get { return _textColor }
        }
        
        init(label: UILabel, textColor: UIColor = .lightGray) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }
        
        required init?(coder: NSCoder) { super.init(coder: coder) }
    }
    
    // Internal class to retrieve the clear button image of the text field asynchronously
    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?) -> ()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }
    
    // Method to set the clear button color of the text field
    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard let image = image, let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    // Method to retrieve the placeholder label of the text field
    var placeholderLabel: UILabel? { return value(forKey: "placeholderLabel") as? UILabel }
    
    // Method to set the placeholder text color of the text field
    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else { return }
        let label = Label(label: placeholderLabel, textColor: textColor)
               setValue(label, forKey: "placeholderLabel")
           }

           func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}
