//
//  SearchByNameVC.swift
//  iDonate
//
//  Created by Im043 on 13/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireImage
import TKFormTextField
import WebKit
import SafariServices

//MARK: Protocols
protocol SearchByCityDelegate {
    func getCharityListFromPlaces(inputDetails: [String:String])
}
var searchBool1 = false
var searchBool2 = false
class SearchByLocationVC: BaseViewController,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UISearchBarDelegate,SearchByCityDelegate ,WKNavigationDelegate,WKScriptMessageHandler, WKUIDelegate, SFSafariViewControllerDelegate{
    //MARK: Outlets
    @IBOutlet var notificationTabBar: UITabBar!
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchScrollBar: UISearchBar!
    @IBOutlet var containerView: UIView!
    @IBOutlet var searchBarView: UIView!
    @IBOutlet var innersearchBarView: UIView!
    @IBOutlet var namebtn: UIButton!
    @IBOutlet var nameScrollbtn: UIButton!
    @IBOutlet var  typebtn: UIButton!
    @IBOutlet var  Scrolltypebtn: UIButton!
    @IBOutlet var  locationNameText: UILabel!
    @IBOutlet weak var searchBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollcontraint: NSLayoutConstraint!
    @IBOutlet var noresultsview: UIView!
    @IBOutlet var noresultMEssage: UILabel!
    @IBOutlet var headerTitle: UILabel!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var cancelBtn : UIButton!
    @IBOutlet var continuePaymentBTn : UIButton!
    @IBOutlet var amountText: UITextField!
    var isFromAdvanceSearch = false
    
    //MARK: Variables
    var selectedCharity:CharityListArray? = nil
    var placesDelegate:SearchByCityDelegate?
    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

    var webView: WKWebView!

    var donateFlag:Bool = false
    var nameFlg:Bool = false
    var charityResponse :  CharityModel?
    var charityLikeResponse :  CharityLikeModel?
    var charityFollowResponse :  FollowModel?
    var charityListArray : [CharityListArray]?
    var filterdCharityListArray : [CharityListArray]?
    var isFiltering:Bool = false
    var longitute:String = ""
    var lattitude:String = ""
    var locationSearch:String = "Nonprofits"
    var userID:String = ""
    var selectedIndex:Int = -1
    var headertitle:String = ""
    var country: String = "US"
    var categoryCode : [String]?
    var subCategoryCode : [String]?
    var childCategory : [String]?
    var deductible = String()

    var likeActionTriggered = false
    
    var pageCount = 1
    
    var previousPageCount = 1
    var searchEnabled = "false"
    var searchName = ""
    var incomeFrom = ""
    var incomeTo = ""
    
    
    let digitBeforeDecimal = 5
    let digitAfterDecimal = 2
   
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(country)
       
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            self.scrollcontraint.constant = 80
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView?.uiDelegate = self
        iDonateClass.sharedClass.customSearchBar(searchBar: searchBar)
        iDonateClass.sharedClass.customSearchBar(searchBar: searchScrollBar)
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        mytapGestureRecognizer.cancelsTouchesInView = false
        self.containerView.addGestureRecognizer(mytapGestureRecognizer)
        
        // 1.
        containerView.translatesAutoresizingMaskIntoConstraints = false
        // headerView is your actual content.

        // 2.
        self.searchTableView.tableHeaderView = containerView
        // 3.
        containerView.centerXAnchor.constraint(equalTo: self.searchTableView.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.searchTableView.widthAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.searchTableView.topAnchor).isActive = true
        // 4.
        self.searchTableView.tableHeaderView?.layoutIfNeeded()
        self.searchTableView.tableHeaderView = self.searchTableView.tableHeaderView
        self.webView.uiDelegate = self
        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        mytapGestureRecognizer.cancelsTouchesInView = false
        self.blurView.addGestureRecognizer(mytapGestureRecognizer1)
        
        headerTitle.text = headertitle
        debugPrint("headertitle",headertitle)
        
        if self.isFromAdvanceSearch {
            if headertitle ==  "INTERNATIONAL CHARITIES REGISTERED IN USA" {
                headerTitle.text = "ADVANCE SEARCH INTERNATIONAL"
            }
            if headertitle == "UNITED STATES" {
                headerTitle.text = "ADVANCE SEARCH USA"
            }
            
        }
        
        
     
        
     
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        searchTableView.estimatedRowHeight = UITableView.automaticDimension
                
        searchTableView.isScrollEnabled = true
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        self.changePlaceholderText(searchScrollBar)
        self.changePlaceholderText(searchBar)
        
        getToken()
    }
    override func viewWillAppear(_ animated: Bool) {
        print(country)
        searchTableView.reloadData()
        locationNameText.textColor = ivoryColor
//        self.tableTopConstraint.constant = 40
        if !locationSearch.isEmpty {
            locationNameText.text = locationSearch + " & charities near you"
        }
        
        
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
            if country == "US"{
                searchBar.placeholder = "Search by city/state"
                searchScrollBar.placeholder = "Search by city/state"
            } else {
                searchBar.placeholder = "Search by country"
                searchScrollBar.placeholder = "Search by country"
            }
            
            nameScrollbtn.isSelected = false
            Scrolltypebtn.isSelected = true
            typebtn.isSelected = true
            namebtn.isSelected =  false
            locationNameText.textColor = ivoryColor
            locationNameText.text = ((UserDefaults.standard.value(forKey:"SelectedType")) as! String)
        }
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            userID = myPeopleList.userID
        }
        
        print( self.searchEnabled)
        self.pageCount = 1
        if !self.searchName.isEmpty {
            self.searchBar.text = self.searchName
            self.makeNameSearchClicked()
        }
        self.charityWebSerice()

    }
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard .set("", forKey: "latitude")
        UserDefaults.standard .set("", forKey: "longitude")
        UserDefaults.standard .set("Nonprofits", forKey: "locationname")
        lattitude  = ""
        longitute = ""
        locationSearch = ""
        previousPageCount = pageCount
    }
    
    
    
    // MARK: Button actions
    @IBAction func filterAction(_ sender:UIButton){
        
        if(sender.tag == 0){
            UIView.animate(withDuration: 1, animations: {
                self.searchBarConstraint.constant = 100
                
                if(iDonateClass.hasSafeArea){
                    self.scrollcontraint.constant = 100
                }else{
                    self.scrollcontraint.constant = 100
                }
                self.innersearchBarView.isHidden = false
            })
            sender.tag = 1
            
        } else {
            sender.tag = 0
            self.searchBarConstraint.constant = 60
            
            if(iDonateClass.hasSafeArea) {
                self.scrollcontraint.constant = 60
            } else{
                self.scrollcontraint.constant = 60
            }
            
            self.innersearchBarView.isHidden = true
            
        }
    }
    
    
    @IBAction func cancelAction(_ sender:UIButton){
        blurView .removeFromSuperview()
    }
    
   
    
    @IBAction func locationAction(_ sender:UIButton) {
        typebtn.isSelected = false
        if(sender.isSelected) {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
    }
    
    @IBAction func typeAction(_ sender:UIButton) {
        if(sender.isSelected){
            sender.isSelected = false
        } else{
            namebtn.isSelected = false
            nameScrollbtn.isSelected = false
            sender.isSelected = true
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
            vc?.address = locationSearch
            vc?.latitude = lattitude
            vc?.longitude = longitute
            vc?.countryCode = country
            vc?.searchNameKey = self.searchName
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func makeNameSearchClicked(){
        searchScrollBar.placeholder = "Enter nonprofit/charity name"
        searchBar.placeholder = "Enter nonprofit/charity name"
        nameScrollbtn.isSelected = true
        typebtn.isSelected = false
        nameFlg = true
    }
    @IBAction func nameAction(_ sender:UIButton)  {
        
        typebtn.isSelected = false
//        locationNameText.text = ""
        
        if(sender.isSelected){
            if country == "US"{
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
           
        } else{
            self.makeNameSearchClicked()
        }
        
    }
    
    @IBAction func nameSCrollAction(_ sender:UIButton)  {
        typebtn.isSelected = false
      //  locationNameText.text = ""
        //tableTopConstraint.constant = 0
        
        self.searchBar.text = ""
        self.searchScrollBar.text = ""
        self.view.endEditing(true)
        
        if(sender.isSelected){
            if country == "US"{
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
            //locationNameText.text = locationSearch + " & charities near you"
            
        } else {
            self.makeNameSearchClicked()
        }
    }
    
    @IBAction func likeAction(_ sender:UIButton)  {
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            var likeCount:String = ""
            userID = myPeopleList.userID
            var charityObject = charityListArray![sender.tag]
            let currentLikeCount = Int(charityObject.like_count ?? "0") ?? 0

            if(sender.isSelected) {
                sender.isSelected = false
                likeCount = "0"
                charityObject.like_count = "\(currentLikeCount - 1)"

            }
            else{
                likeCount = "1"
                sender.isSelected = true
                charityObject.like_count = "\(currentLikeCount + 1)"

            }
            selectedIndex = sender.tag
            charityLikeAction(like: likeCount, charityId: charityObject.id!)
        }
        else{
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
    
    @IBAction func advancedSearch(_ sender:UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "newcontrollerID") as? NewViewfromadvancedSearchViewController
            vc?.address = locationSearch
            vc?.latitude = lattitude
            vc?.longitude = longitute
            vc?.countryCode = country
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
    
    @IBAction func followAction(_ sender:UIButton)  {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            var followCount:String = ""
            userID = myPeopleList.userID
            let charityObject = charityListArray![sender.tag]
            
            if(sender.isSelected){
                sender.isSelected = false
                followCount = "0"
            } else{
                followCount = "1"
                sender.isSelected = true
            }
            
            selectedIndex = sender.tag
            followAction(follow: followCount, charityId: charityObject.id!)
        }
        else{
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
    
    
func getToken(){
    
    }
    
    @IBAction func paymentAction(_ sender:UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let charityObject = charityListArray![self.continuePaymentBTn.tag]

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
        self.lattitude  = inputDetails["latitude"]! //UserDefaults.standard.value(forKey: "latitude") as! String
        self.longitute = inputDetails["longitude"]! //UserDefaults.standard.value(forKey: "longitude") as! String
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
                self.scrollcontraint.constant = 60
            } else{
                self.scrollcontraint.constant = 60
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
        
        if longitute != "", lattitude != "", locationSearch != "Nonprofits"{
            
            longitute = ""
            lattitude = ""
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
    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? String, messageBody == "dismissWebView" {
            dismissWebView()
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Extract the current URL of the web view
        if let currentURL = webView.url {
            // Analyze the URL to determine the payment status
            let payButtonScript = "document.getElementById('payButton').onclick = function() { window.webkit.messageHandlers.dismissWebView.postMessage('dismissWebView'); }"
            webView.evaluateJavaScript(payButtonScript, completionHandler: nil)
            print(webView.url)
            
            // Check if the URL contains the success message
            if currentURL.absoluteString.contains("donation_payment_show_successfull_msg") {
                // Dismiss the web view
                dismissWebView()

            
            }
            if currentURL.absoluteString.contains("donation_payment_cancel_payment"){
                dismissWebView()
                let alertController = UIAlertController(title: "Payment Cancelled", message: "Your donation payment has been cancelled.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
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
            return (filterdCharityListArray?.count)!
        }else{
            return charityListArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let charity: CharityListArray
        print(filterdCharityListArray?[indexPath.row])
        print(charityListArray?[indexPath.row])
        if(isFiltering) {
            charity = (filterdCharityListArray?[indexPath.row])!
        }else {
            charity = charityListArray![indexPath.row]
        }
        
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
        cell.title.text = charity.name
        cell.address.text = charity.street!+","+charity.city!
        if let likeCount = charity.like_count {
            let likeString = "\(likeCount) Likes"
            cell.likeBtn.setTitle(likeString, for: .normal)
            print(likeString)
        } else {
            print("likeCount is nil")
        }

        if let liked = charity.liked {
            print(liked)
        } else {
            print("liked is nil")
        }

        if let placeholderImage = UIImage(named: "defaultImageCharity") {
            if charity.logo != nil && charity.logo != "" {
                if let url = URL(string: charity.logo!) {
                    cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)

                }
            } else {
                cell.logoImage.image = placeholderImage
            }
        } else {
            print("defaultImageCharity image not found")
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
            charity = (filterdCharityListArray?[indexPath.row])!
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
            Scrolltypebtn.isSelected = false
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
            Scrolltypebtn.isSelected = false
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
                   self.continuePaymentBTn.tag = sender.tag
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
                                    "latitude":lattitude,
                                    "longitude":longitute,
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
        print(lattitude)
        print(longitute)
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
                self.noresultMEssage.text = charityResponse?.message
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
