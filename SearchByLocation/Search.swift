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
import Braintree
import BraintreeDropIn
//MARK: Protocols
var searchName = false
class SearchByLocation: BaseViewController,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UISearchBarDelegate {
    
    //MARK: Outlets
   
    @IBOutlet var searchTableView: UITableView!
//    @IBOutlet var searchBar: UISearchBar!
   
    @IBOutlet var txtdata:UITextField!
    
    @IBOutlet var img:UIImageView!

    @IBOutlet var amountText: TKFormTextField!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var continuePaymentBTn : UIButton!
    @IBOutlet var noresultsview: UIView!
    @IBOutlet var noresultMEssage: UILabel!
//    @IBOutlet var containerView: UIView!
//    @IBOutlet weak var searchBarConstraint: NSLayoutConstraint!
    
  //  @IBOutlet weak var scrollcontraint: NSLayoutConstraint!
  
    
   
   
   
  
    
    //MARK: Variables
    var selectedCharity:charityListArray? = nil
    var placesDelegate:SearchByCityDelegate?
    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

    var donateFlag:Bool = false
    var nameFlg:Bool = false
    var charityResponse :  CharityModel?
    var charityLikeResponse :  CharityLikeModel?
    var charityFollowResponse :  FollowModel?
    var charityListArray : [charityListArray]?
    var filterdCharityListArray : [charityListArray]?
    var isFiltering:Bool = true
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
    var searchname = ""
    var incomeFrom = ""
    var incomeTo = ""
    var strSearch = ""
    
    
    
    
    
    
//    var payPalConfig = PayPalConfiguration()
//    let items:NSMutableArray = NSMutableArray()
//    //Set environment connection.
//    var environment:String = PayPalEnvironmentNoNetwork {
//        willSet(newEnvironment) {
//            if (newEnvironment != environment) {
//                PayPalMobile.preconnect(withEnvironment: newEnvironment)
//            }
//        }
//    }
    //MARK: LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
           // self.scrollcontraint.constant = 80
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
      
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        mytapGestureRecognizer.cancelsTouchesInView = false
       
        self.filterdCharityListArray =   self.charityListArray
        txtdata.delegate = self
        txtdata.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        self.searchTableView.tableHeaderView = containerView
//        containerView.centerXAnchor.constraint(equalTo: self.searchTableView.centerXAnchor).isActive = true
//        containerView.widthAnchor.constraint(equalTo: self.searchTableView.widthAnchor).isActive = true
//        containerView.topAnchor.constraint(equalTo: self.searchTableView.topAnchor).isActive = true
//
        self.searchTableView.tableHeaderView?.layoutIfNeeded()
        self.searchTableView.tableHeaderView = self.searchTableView.tableHeaderView
        
        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        mytapGestureRecognizer.cancelsTouchesInView = false
       
        self.amountText.placeholder = ""
        self.amountText.text = "$10"
        self.amountText.enablesReturnKeyAutomatically = true
        self.amountText.returnKeyType = .done
        self.amountText.delegate = self
        self.amountText.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.amountText.font = UIFont.systemFont(ofSize: 34)
        self.amountText.selectedTitleColor = UIColor.darkGray
        self.amountText.titleColor = UIColor.darkGray
        self.amountText.placeholderColor = UIColor.darkGray
        self.amountText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        searchTableView.estimatedRowHeight = UITableView.automaticDimension
                
        searchTableView.isScrollEnabled = true
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
      
        getToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchTableView.reloadData()
        self.filterdCharityListArray =   self.charityListArray
        txtdata.delegate = self
        txtdata.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        if UserDefaults.standard.bool(forKey: "country") == true {
                  country = "INT"
            txtdata.placeholder = "Search by country"
              }else {
                  country = "US"
                  txtdata.placeholder = "Search by city/state"
              }
        
        
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
            if country == "US"{
                txtdata.placeholder = "Search by city/state"
             
            } else {
                txtdata.placeholder = "Search by country"
            }
            
           
        }
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            userID = myPeopleList.userID
        }
        
        print( self.searchEnabled)
        self.pageCount = 1
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
    @IBAction func cancelAction(_ sender:UIButton){
        blurView .removeFromSuperview()
    }
    
    @IBAction func likeAction(_ sender:UIButton)  {
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            var likeCount:String = ""
            userID = myPeopleList.userID
            let charityObject = filterdCharityListArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                likeCount = "0"
            }
            else{
                likeCount = "1"
                sender.isSelected = true
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
    @IBAction func followAction(_ sender:UIButton)  {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            var followCount:String = ""
            userID = myPeopleList.userID
            let charityObject = filterdCharityListArray![sender.tag]
            
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
    
    @IBAction func donateAction(_ sender:UIButton)  {
        
        self.amountText.text = "$10"

        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            blurView.frame =  self.view.frame
            self.continuePaymentBTn.tag = sender.tag
            self.view .addSubview(blurView)
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
    
    @IBAction func paymentAction(_ sender:UIButton) {
        
        if(amountText.text == "") {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:"please enter amount", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        } else {
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let urlString = "\(URLHelper.baseURL)braintree_client_token"

            let url = URL(string: urlString)!
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
//            request.setValue("text/plain", forHTTPHeaderField: "Accept")
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

            AF.request(request).responseJSON {
                (response) in
               print(response.response?.statusCode)
                MBProgressHUD.hide(for: self.view, animated: true)
                print(response.result)
                print(response.response)
                print(response.error)
                
                switch response.result {
                  
                case .success(let value):
                    print("value**: \(value)")
                    
                    if(self.isFiltering) {
                        self.selectedCharity = self.filterdCharityListArray?[sender.tag]
                    } else {
                        self.selectedCharity = self.filterdCharityListArray?[sender.tag]
                    }
//                    self.selectedCharity = self.filterdCharityListArray?[sender.tag]
                    let drop =  BTDropInRequest()
                    drop.vaultManager = true
                    drop.paypalDisabled = false
                    drop.cardDisabled = false
                    drop.payPalRequest?.currencyCode = "$"
                    print(drop)
                    let amount = self.amountText.text?.replacingOccurrences(of: "$", with: "")
                    
                    let amountWithoutDollar = amount!.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    guard Double(amountWithoutDollar) != 0 else {
                        return
                    }
                    
                    let processingValue = self.calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 1)
                    
                    let amountWithProcessingValue = (Double(amountWithoutDollar) ?? 0) + processingValue
                    
                    let merchantChargesValue = self.calculatePercentage(value: amountWithProcessingValue ,percentageVal: 2.9) + 0.30
                    
                    let totalAmount = amountWithProcessingValue + merchantChargesValue
                    
                    let dropIn = BTDropInController(authorization: "\(value)", request: drop)
                    { (controller, result, error) in
                        
                        print("result",result!)
                        
                        if (error != nil) {
                            print("ERROR")
                        } else if (result?.isCancelled == true) {
                            print("CANCELLED")
                        } else if let result = result {
                            
                            if let data = UserDefaults.standard.data(forKey: "people"),
                               let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                                print(myPeopleList.name)
                                // Joe 10
                                
                                MBProgressHUD.showAdded(to: self.view, animated: true)
                                
                                let postDict: Parameters = ["user_id":myPeopleList.userID,
                                                            "token":myPeopleList.token,
                                                            "charity_id":self.selectedCharity?.id ?? "",
                                                            "charity_name": self.selectedCharity?.name ?? "",
                                                            "transaction_id":result.paymentMethod?.nonce ?? "",
                                                            "amount":amount,
                                                            "payment_type": result.paymentMethod?.type ?? "",
                                                            "status":"approved",
                                                            "merchant_charges":merchantChargesValue,
                                                            "processing_fee":processingValue]
                                
                                let paymentUrl = String(format: URLHelper.iDonatePayment)
                                
                                self.blurView.removeFromSuperview()
                                
                                WebserviceClass.sharedAPI.performRequest(type: paymentModel.self, urlString: paymentUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                                    
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    
                                    print("payment response", response)
                                    
                                    let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                                    let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                                    let messageAttrString = NSMutableAttributedString(string:"Payment Done Successfully", attributes: messageFont)
                                    alertController.setValue(messageAttrString, forKey: "attributedMessage")
                                    let contact = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                                        self.blurView.removeFromSuperview()
                                    }
                                    alertController.addAction(contact)
                                    self.present(alertController, animated: true, completion: nil)
                                    
                                    print("Result: \(String(describing: response))") // response serialization result
                                    
                                }) { (response) in
                                    
                                }
                            }
                            
                        }
                        controller.dismiss(animated: true, completion: nil)
                    }
                    self.present(dropIn!, animated: true, completion: nil)
                    
                    
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
   
    //MARK: Follow method
   
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
    func charityFollowResponseMethod() {
        if(self.charityFollowResponse?.status == 1) {
           self.pageCount = 1
           self.charityWebSerice()
        }
    }
    //MARK:  like method
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
    
    //MARK: - websevice method
    @objc func charityWebSerice() {
        
        let postDict: Parameters = ["name":searchName,
                                    "latitude":lattitude,
                                    "longitude":longitute,
                                    "page":pageCount,
                                    "address":locationSearch,
                                    "category_code":categoryCode ?? [String](),
                                    "deductible":deductible,
                                    "income_from":incomeFrom,
                                    "income_to":incomeTo,
                                    "country_code":country,
                                    "sub_category_code":subCategoryCode ?? [String](),
                                    "child_category_code":childCategory ?? [String](),
                                    "user_id":userID]
        
        print(postDict)
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
        
      //  if textField == txtdata, let str = txtdata.text, str.count > 0{
            
            let arr: [charityListArray]? = self.charityListArray?.filter({$0.city?.lowercased().contains(strSearch.lowercased()) as! Bool
            })
           
                self.filterdCharityListArray = arr
            
       
       
        
        
      
        if(charityResponse?.status == 1){
            self.noresultsview.isHidden = true
        }else {
            if pageCount <= 1{
                self.noresultsview.isHidden = false
                self.noresultMEssage.text = charityResponse?.message
            }
        }
        DispatchQueue.main.async {

         //   self.filterdCharityListArray = self.charityListArray
            self.searchTableView.reloadData()
        }
    }




    
  //MARK: - Functions
    
    func getToken(){
    
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
  
    
    
    //MARK: Scrollview delegates
    
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
        

        txtdata.resignFirstResponder()
    }
    
    @objc func cancelView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    @objc func backAction(_sender:UIButton)  {
        
       
            self.navigationController?.popViewController(animated: true)
        
    }
    
    func paymentResponse(string: String) {
        print(string)
    }
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if(textField == amountText) {
//            donateFlag = true
//            textField.becomeFirstResponder()
//        }
//    }
   
    
    override func viewDidDisappear(_ animated: Bool) {
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
            UserDefaults.standard.removeObject(forKey: "SelectedType")
        }
    }
    
    //MARK: textfiled delegate method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtdata{
        textField .resignFirstResponder()
        }
        return true
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        
      
        if textField == txtdata, let str = txtdata.text, str.count > 0{
            strSearch = txtdata.text!
            let arr: [charityListArray]? = self.charityListArray?.filter({$0.city?.lowercased().contains(str.lowercased()) as! Bool
            })
           
                self.filterdCharityListArray = arr
            
        }else{
            self.filterdCharityListArray = self.charityListArray
        }
        self.searchTableView.reloadData()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == amountText) {
            donateFlag = true
            textField.becomeFirstResponder()
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
//        if (isFiltering){
//            return (filterdCharityListArray?.count)!
//        }else{
//            return charityListArray?.count ?? 0
//        }
        return filterdCharityListArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let charity: charityListArray
      
//        if(isFiltering) {
//            charity = (filterdCharityListArray?[indexPath.row])!
//        }else {
//            charity = charityListArray![indexPath.row]
//        }
        print(filterdCharityListArray?[indexPath.row])
       
        charity = filterdCharityListArray![indexPath.row]
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
        cell.title.text = charity.name
        cell.address.text = charity.street!+","+charity.city!
        let likeString = charity.like_count! + " Likes"
        cell.likeBtn.setTitle(likeString, for: .normal)
        let placeholderImage = UIImage(named: "defaultImageCharity")!
        print(likeString)
        print(charity.like_count)
        print(charity.liked)
        if charity.logo != nil && charity.logo != "" {
            let url = URL(string: charity.logo ?? "")!
            cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
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
        
        if(charity.followed == "0"){
            cell.followingBtn.isSelected = false
            cell.followingBtn.setTitle("Follow", for: .normal)
        }
        else {
            cell.followingBtn.isSelected = true
            cell.followingBtn.setTitle("Following", for: .normal)
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
        
        let charity: charityListArray
//        if(isFiltering) {
//            charity = (filterdCharityListArray?[indexPath.row])!
//        }
//        else {
//            charity = charityListArray![indexPath.row]
//        }
        charity = filterdCharityListArray![indexPath.row]
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchDetailsVC") as? SearchDetailsVC
        vc?.charityList = charity
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Searchbar delegate
    
    
    
   
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if(nameFlg == false){
//           if country == "US"{
////                searchBar.placeholder = "Search by city/state"
//               textfield.placeholder = "Search by city/state"
//            } else {
////                searchBar.placeholder = "Search by country"
//                textfield.placeholder = "Search by country"
//            }
//
//            nameFlg = false
//        } else{
//
////            searchBar.placeholder = "Enter nonprofit/charity name"
//            textfield.placeholder = "Enter nonprofit/charity name"
//            nameFlg = true
//        }
//        self.view.endEditing(true)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        if searchText.count >= 3 {
//            searchName = searchText
////            self.searchBar.text = searchText
//            self.textfield.text = searchText
//            self.charityWebSerice()
//        } else {
////            self.searchBar.text = searchText
//            self.textfield.text = searchText
//            searchName = ""
//        }
//
//        if searchText.count == 0{
//            self.charityWebSerice()
//        }
//    }
    
    
    // MARK:Webservicemethod
}
extension SearchByLocation {
    
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
//extension SearchByLocationVC: UITextFieldDelegate {
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if range.length>0  && range.location == 0 {
//            return false
//        }
//        return true
//    }
//    
//}
// MARK: - BTAppSwitch Delegate Method

// MARK: - BT View Controller Presenting Delegate Method




//extension SearchByLocationVC: PayPalPaymentDelegate {
//
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
//        paymentViewController.dismiss(animated: true) { () -> Void in
//            print("and Dismissed")
//        }
//        print("Payment cancel")
//    }
//
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
//        paymentViewController.dismiss(animated: true) { () -> Void in
//            print("and done")
//        }
//        print("Paymane is going on")
//    }
//
//
//    func acceptCreditCards() -> Bool {
//        return self.payPalConfig.acceptCreditCards
//    }
//
//    func setAcceptCreditCards(acceptCreditCards: Bool) {
//        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
//    }
//
//
//    func configurePaypal(strMarchantName:String) {
//
//        // Set up payPalConfig
//        payPalConfig.acceptCreditCards = true
//
//        payPalConfig.merchantName = strMarchantName
//
//        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full") //NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
//
//        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
//
//        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
//
//        payPalConfig.payPalShippingAddressOption = .payPal;
//
//        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
//
//        PayPalMobile.preconnect(withEnvironment: environment)
//
//    }
//
//    //Start Payment for selected shopping items
//
//    func goforPayNow(merchantCharge:String?, processingCharge:String?, totalAmount:String?, strShortDesc:String?, strCurrency:String?) {
//
//        var subtotal : NSDecimalNumber = 0
//
//        var merchant : NSDecimalNumber = 0
//
//        var processing : NSDecimalNumber = 0
//
//        subtotal = NSDecimalNumber(string: totalAmount)
//
//        // Optional: include payment details
//        if (merchantCharge != nil) {
//            merchant = NSDecimalNumber(string: merchantCharge)
//        }
//
//        if (processingCharge != nil) {
//            processing = NSDecimalNumber(string: processingCharge)
//        }
//
//        var description = strShortDesc
//
//        if (description == nil) {
//            description = ""
//        }
//
//        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: merchant, withTax: processing)
//
//        let total = subtotal.adding(merchant).adding(processing)
//
//        let payment = PayPalPayment(amount: total, currencyCode: strCurrency!, shortDescription: selectedCharity?.name ?? description!, intent: .sale)
//
//        payment.items = [PayPalItem(name: selectedCharity?.name ?? "", withQuantity: 1, withPrice: NSDecimalNumber(string: totalAmount), withCurrency: "USD", withSku: "")]
//
//        payment.paymentDetails = paymentDetails
//        self.payPalConfig.acceptCreditCards = self.acceptCreditCards();
//
//        if self.payPalConfig.acceptCreditCards == true {
//            print("We are able to do the card payment")
//        }
//
//        if (payment.processable) {
//            let objVC = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//            self.present(objVC!, animated: true, completion: { () -> Void in
//                print("Paypal Presented")
//            })
//        }
//        else {
//            print("Payment not processalbe: \(payment)")
//        }
//
//    }
//
//}

extension SearchByLocation: UITextFieldDelegate{
    
    
}
////
////  SearchByNameVC.swift
////  iDonate
////
////  Created by Im043 on 13/05/19.
////  Copyright © 2019 Im043. All rights reserved.
////
//
//import UIKit
//import MBProgressHUD
//import Alamofire
//import AlamofireImage
//import TKFormTextField
//import Braintree
//import BraintreeDropIn
////MARK: Protocols
//var searchName = false
//class SearchByLocation: BaseViewController,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UISearchBarDelegate {
//
//    //MARK: Outlets
//
//    @IBOutlet var searchTableView: UITableView!
////    @IBOutlet var searchBar: UISearchBar!
//
//    @IBOutlet var txtdata:UITextField!
//
//    @IBOutlet var img:UIImageView!
//
//
//
//
//
////    @IBOutlet weak var searchBarConstraint: NSLayoutConstraint!
//
//  //  @IBOutlet weak var scrollcontraint: NSLayoutConstraint!
//
//
//
//
//
//
//
//    //MARK: Variables
//    var selectedCharity:charityListArray? = nil
//    var placesDelegate:SearchByCityDelegate?
//    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
//
//    var donateFlag:Bool = false
//    var nameFlg:Bool = false
//    var charityResponse :  CharityModel?
//    var charityLikeResponse :  CharityLikeModel?
//    var charityFollowResponse :  FollowModel?
//    var charityListArray : [charityListArray]?
//    var filterdCharityListArray : [charityListArray]?
//    var isFiltering:Bool = false
//    var longitute:String = ""
//    var lattitude:String = ""
//    var locationSearch:String = "Nonprofits"
//    var userID:String = ""
//    var selectedIndex:Int = -1
//    var headertitle:String = ""
//    var country: String = "US"
//    var categoryCode : [String]?
//    var subCategoryCode : [String]?
//    var childCategory : [String]?
//    var deductible = String()
//
//    var likeActionTriggered = false
//
//    var pageCount = 1
//
//    var previousPageCount = 1
//    var searchEnabled = "false"
//    var searchname = ""
//    var incomeFrom = ""
//    var incomeTo = ""
//
////    var payPalConfig = PayPalConfiguration()
////    let items:NSMutableArray = NSMutableArray()
////    //Set environment connection.
////    var environment:String = PayPalEnvironmentNoNetwork {
////        willSet(newEnvironment) {
////            if (newEnvironment != environment) {
////                PayPalMobile.preconnect(withEnvironment: newEnvironment)
////            }
////        }
////    }
//    //MARK: LifeCycle
////    override func viewDidLoad() {
////
////        super.viewDidLoad()
////        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
////
////        if(iDonateClass.hasSafeArea){
////            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
////        }else {
////           // self.scrollcontraint.constant = 80
////            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
////        }
////
////        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
////        self.view .addSubview(menuBtn)
////        menuBtn.setImage(UIImage(named: "back"), for: .normal)
////
//////        iDonateClass.sharedClass.customSearchBar(searchBar: searchBar)
////
////        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
////        mytapGestureRecognizer.numberOfTapsRequired = 1
////        mytapGestureRecognizer.cancelsTouchesInView = false
////
////        self.filterdCharityListArray =   self.charityListArray
////        txtdata.delegate = self
////        txtdata.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
////
////        self.searchTableView.tableHeaderView?.layoutIfNeeded()
////        self.searchTableView.tableHeaderView = self.searchTableView.tableHeaderView
////
////        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
////        mytapGestureRecognizer.numberOfTapsRequired = 1
////        mytapGestureRecognizer.cancelsTouchesInView = false
////
////
////        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
////        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
////
////        searchTableView.estimatedRowHeight = UITableView.automaticDimension
////
////        searchTableView.isScrollEnabled = true
////        searchTableView.delegate = self
////        searchTableView.dataSource = self
////
////
//////        self.changePlaceholderText(searchBar)
////        getToken()
////    }
////    override func viewWillAppear(_ animated: Bool) {
////        searchTableView.reloadData()
////
//////        self.tableTopConstraint.constant = 40
////
////
////
////        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
////            if country == "US"{
//////                searchBar.placeholder = "Search by city/state"
////                txtdata.placeholder = "Search by city/state"
////
////            } else {
//////                searchBar.placeholder = "Search by country"
////                txtdata.placeholder = "Search by country"
////            }
////
////
////        }
////
////        if let data = UserDefaults.standard.data(forKey: "people"),
////            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
////            userID = myPeopleList.userID
////        }
////
////        print( self.searchEnabled)
////        self.pageCount = 1
////        self.charityWebSerice()
////
////    }
////    override func viewWillDisappear(_ animated: Bool) {
////        UserDefaults.standard .set("", forKey: "latitude")
////        UserDefaults.standard .set("", forKey: "longitude")
////        UserDefaults.standard .set("Nonprofits", forKey: "locationname")
////        lattitude  = ""
////        longitute = ""
////        locationSearch = ""
////        previousPageCount = pageCount
////    }
//    override func viewDidLoad() {
//
//        super.viewDidLoad()
//        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
//
//        if(iDonateClass.hasSafeArea){
//            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
//        }else {
//
//            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
//        }
//
//        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
//        self.view .addSubview(menuBtn)
//        menuBtn.setImage(UIImage(named: "back"), for: .normal)
//
//        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
//        mytapGestureRecognizer.numberOfTapsRequired = 1
//        mytapGestureRecognizer.cancelsTouchesInView = false
////
//        self.searchTableView.tableHeaderView?.layoutIfNeeded()
//        self.searchTableView.tableHeaderView = self.searchTableView.tableHeaderView
//
//        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
//        mytapGestureRecognizer.numberOfTapsRequired = 1
//        mytapGestureRecognizer.cancelsTouchesInView = false
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//
//        searchTableView.estimatedRowHeight = UITableView.automaticDimension
//
//        searchTableView.isScrollEnabled = true
//        searchTableView.delegate = self
//        searchTableView.dataSource = self
//
//
//        getToken()
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        searchTableView.reloadData()
//        if UserDefaults.standard.bool(forKey: "country") == true {
//            country = "INT"
//        }else {
//            country = "US"
//        }
//
//        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
//            if country == "US"{
//                txtdata.placeholder = "Search by city/state"
//            } else {
//                txtdata.placeholder = "Search by country"
//            }
//
//        }
//
//        if let data = UserDefaults.standard.data(forKey: "people"),
//            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
//            userID = myPeopleList.userID
//        }
//
//        print( self.searchEnabled)
//        self.pageCount = 1
//        self.charityWebSerice()
//
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        UserDefaults.standard .set("", forKey: "latitude")
//        UserDefaults.standard .set("", forKey: "longitude")
//        UserDefaults.standard .set("Nonprofits", forKey: "locationname")
//        lattitude  = ""
//        longitute = ""
//        locationSearch = ""
//        previousPageCount = pageCount
//    }
//
//    func getToken(){
//
//    }
//
////
////    fileprivate func changePlaceholderText(_ searchBarCustom: UISearchBar) {
////
////        if country == "US"{
////            searchBarCustom.placeholder = "Search by City/State"
////        } else {
////            searchBarCustom.placeholder = "Search by country"
////        }
////
////        searchBarCustom.set(textColor: .white)
////        searchBarCustom.setTextField(color: UIColor.clear)
////        searchBarCustom.setPlaceholder(textColor: .white)
////        searchBarCustom.setSearchImage(color: .white)
////        searchBarCustom.setClearButton(color: .white)
////
////    }
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if(donateFlag == true){
//                if self.view.frame.origin.y == 0 {
//                    self.view.frame.origin.y -= keyboardSize.height
//                }
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
//
//
//
//    //MARK: Scrollview delegates
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        if scrollView.isDecelerating == false{
//            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
//                       //you reached end of the table
//                       pageCount = pageCount + 1
//                       self.charityWebSerice()
//                   }
//        }
//
//    }
//
//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//
//    }
//
//    @objc func myTapAction(recognizer: UITapGestureRecognizer) {
//
////        searchBar.resignFirstResponder()
//        txtdata.resignFirstResponder()
//    }
//
//    @objc func cancelView(recognizer: UITapGestureRecognizer) {
//        self.view.endEditing(true)
//    }
//
//
//    @objc func backAction(_sender:UIButton)  {
//
//
//            self.navigationController?.popViewController(animated: true)
//
//    }
//
//    func paymentResponse(string: String) {
//        print(string)
//    }
//
//
//
//    override func viewDidDisappear(_ animated: Bool) {
//        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
//            UserDefaults.standard.removeObject(forKey: "SelectedType")
//        }
//    }
//
//    //MARK: textfiled delegate method
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == txtdata{
//        textField .resignFirstResponder()
//        }
//        return true
//    }
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        if textField == txtdata, let str = txtdata.text, str.count > 0{
//            let arr: [charityListArray]? = self.charityListArray?.filter({$0.city?.lowercased().contains(str.lowercased()) as! Bool})
////            let arr1: [charityListArray]? = self.charityListArray?.filter({$0.state?.lowercased().contains(str.lowercased()) as! Bool})
////            let arr2: [charityListArray]? = self.charityListArray?.filter({$0.name?.lowercased().contains(str.lowercased()) as! Bool})
////            let arr3: [charityListArray]? = self.charityListArray?.filter({$0.zip_code?.lowercased().contains(str.lowercased()) as! Bool})
////            let arr4: [charityListArray]? = self.charityListArray?.filter({$0.country?.lowercased().contains(str.lowercased()) as! Bool})
//
//
//                self.filterdCharityListArray = arr!
////            self.filterdCharityListArray = arr4!
////            self.filterdCharityListArray = arr1
////            self.filterdCharityListArray = arr2
////            self.filterdCharityListArray = arr3
//        }else{
//            self.filterdCharityListArray = self.charityListArray
//        }
//        self.searchTableView.reloadData()
//    }
//
//    // MARK: - tabBar  delegate methods
//    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
//        if(item.tag == 0){
//            UserDefaults.standard.set(0, forKey: "tab")
//            UserDefaults.standard.synchronize()
//            self.navigationController?.pushViewController(vc!, animated: false)
//        }
//        else{
//            UserDefaults.standard.set(1, forKey: "tab")
//            UserDefaults.standard.synchronize()
//            self.navigationController?.pushViewController(vc!, animated: false)
//        }
//    }
//
//// MARK: - Tableview delegate and datasource
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return filterdCharityListArray?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let charity: charityListArray
//
//        charity = filterdCharityListArray![indexPath.row]
//        let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
//        cell.title.text = charity.name
//        cell.address.text = charity.street!+","+charity.city!
//        let likeString = charity.like_count! + " Likes"
//        cell.likeBtn.setTitle(likeString, for: .normal)
//        let placeholderImage = UIImage(named: "defaultImageCharity")!
//
//        if charity.logo != nil && charity.logo != "" {
//            let url = URL(string: charity.logo ?? "")!
//            cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
//        } else {
//            cell.logoImage.image = placeholderImage
//        }
//
//
//        cell.followingBtn.tag = indexPath.row
//        cell.likeBtn.tag = indexPath.row
//        cell.donateBtn.tag = indexPath.row
//
//
//        if(charity.liked == "0"){
//            cell.likeBtn.isSelected = false
//        }
//        else{
//            cell.likeBtn.isSelected = true
//        }
//
//        if(charity.followed == "0"){
//            cell.followingBtn.isSelected = false
//            cell.followingBtn.setTitle("Follow", for: .normal)
//        }
//        else {
//            cell.followingBtn.isSelected = true
//            cell.followingBtn.setTitle("Following", for: .normal)
//        }
//
//        return cell
//    }
//   //MARK: END OF TABLEVIEW CELL FOR ROW Method
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 150
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let charity: charityListArray
//
//        charity = filterdCharityListArray![indexPath.row]
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchDetailsVC") as? SearchDetailsVC
//        vc?.charityList = charity
//        self.navigationController?.pushViewController(vc!, animated: true)
//    }
//
//    // MARK: - Searchbar delegate
//
//
//
//
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if(nameFlg == false){
//           if country == "US"{
////                searchBar.placeholder = "Search by city/state"
//               txtdata.placeholder = "Search by city/state"
//            } else {
////                searchBar.placeholder = "Search by country"
//                txtdata.placeholder = "Search by country"
//            }
//
//            nameFlg = false
//        } else{
//
////            searchBar.placeholder = "Enter nonprofit/charity name"
//            txtdata.placeholder = "Enter nonprofit/charity name"
//            nameFlg = true
//        }
//        self.view.endEditing(true)
//    }
////
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        if searchText.count >= 3 {
//            searchname = searchText
////            self.searchBar.text = searchText
//            self.txtdata.text = searchText
//            self.charityWebSerice()
//        } else {
////            self.searchBar.text = searchText
//            self.txtdata.text = searchText
//            searchname = ""
//        }
//
//        if searchText.count == 0{
//            self.charityWebSerice()
//        }
//    }
//
//
//    // MARK:Webservicemethod
//    func followAction(follow:String,charityId:String) {
//        if let data = UserDefaults.standard.data(forKey: "people"),
//            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
//            print(myPeopleList.name)
//            // Joe 10
//            let postDict: Parameters = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityId,"status":follow]
//            let charityFollowUrl = String(format: URLHelper.iDonateCharityFollow)
//            WebserviceClass.sharedAPI.performRequest(type: FollowModel.self, urlString: charityFollowUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
//                self.charityFollowResponse = response
//                self.charityFollowResponseMethod()
//                print("Result: \(String(describing: response))") // response serialization result
//
//            }) { (response) in
//
//            }
//        }
//        else {
//
//        }
//    }
//
//    func charityFollowResponseMethod() {
//        if(self.charityFollowResponse?.status == 1) {
//           self.pageCount = 1
//           self.charityWebSerice()
//        }
//    }
//
//    func charityLikeAction(like:String,charityId:String) {
//        if let data = UserDefaults.standard.data(forKey: "people"),
//            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
//            print(myPeopleList.name)
//            // Joe 10
//            let postDict: Parameters = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityId,"status":like]
//
//            let charityLikeUrl = String(format: URLHelper.iDonateCharityLike)
//
//            WebserviceClass.sharedAPI.performRequest(type: CharityLikeModel.self, urlString: charityLikeUrl, methodType: HTTPMethod.post, parameters: postDict,  success: {
//                (response) in
//                self.charityLikeResponse = response
//                self.charityLikeResponseMethod()
//                print("Result: \(String(describing: response))")                     // response serialization result
//            }) { (response) in
//
//            }
//        }
//        else {
//
//        }
//    }
//
//    func charityLikeResponseMethod() {
//        if(self.charityLikeResponse?.status == 1) {
//            self.pageCount = 1
//            self.charityWebSerice()
//        }
//    }
//
//    @objc func charityWebSerice() {
//
//        let postDict: Parameters = ["name":searchname,
//                                    "latitude":lattitude,
//                                    "longitude":longitute,
//                                    "page":pageCount,
//                                    "address":locationSearch,
//                                    "category_code":categoryCode ?? [String](),
//                                    "deductible":deductible,
//                                    "income_from":incomeFrom,
//                                    "income_to":incomeTo,
//                                    "country_code":country,
//                                    "sub_category_code":subCategoryCode ?? [String](),
//                                    "child_category_code":childCategory ?? [String](),
//                                    "user_id":userID]
//
//        print(postDict)
//
//        let charityListUrl = String(format: URLHelper.iDonateCharityList)
//        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
//        loadingNotification.mode = MBProgressHUDMode.indeterminate
//        loadingNotification.label.text = "Loading"
//        WebserviceClass.sharedAPI.performRequest(type: CharityModel.self, urlString: charityListUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: {
//            (response) in
//
//            if self.pageCount == self.previousPageCount && self.pageCount != 1{
//
//            } else {
//                if self.charityResponse == nil || self.pageCount == 1 {
//                    self.charityResponse = response
//                    self.charityListArray =  response.data.sorted{ $0.name?.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
//                } else {
//                    self.charityResponse?.data.append(contentsOf: response.data)
//                    self.charityListArray?.append(contentsOf: response.data)
//                }
//            }
//
//            self.responsemethod()
//            print("Result: \(String(describing: response))")                     // response serialization result
//            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
//
//        }) { (response) in
//            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
//        }
//    }
//
//
//    func responsemethod() {
//
//        DispatchQueue.main.async {
//            self.searchTableView.reloadData()
//        }
//
//    }
//}
//
//
//
////extension SearchByLocationVC: UITextFieldDelegate {
////
////    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
////        if range.length>0  && range.location == 0 {
////            return false
////        }
////        return true
////    }
////
////}
//// MARK: - BTAppSwitch Delegate Method
//
//// MARK: - BT View Controller Presenting Delegate Method
//
//
//
//
////extension SearchByLocationVC: PayPalPaymentDelegate {
////
////    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
////        paymentViewController.dismiss(animated: true) { () -> Void in
////            print("and Dismissed")
////        }
////        print("Payment cancel")
////    }
////
////    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
////        paymentViewController.dismiss(animated: true) { () -> Void in
////            print("and done")
////        }
////        print("Paymane is going on")
////    }
////
////
////    func acceptCreditCards() -> Bool {
////        return self.payPalConfig.acceptCreditCards
////    }
////
////    func setAcceptCreditCards(acceptCreditCards: Bool) {
////        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
////    }
////
////
////    func configurePaypal(strMarchantName:String) {
////
////        // Set up payPalConfig
////        payPalConfig.acceptCreditCards = true
////
////        payPalConfig.merchantName = strMarchantName
////
////        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full") //NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
////
////        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
////
////        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
////
////        payPalConfig.payPalShippingAddressOption = .payPal;
////
////        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
////
////        PayPalMobile.preconnect(withEnvironment: environment)
////
////    }
////
////    //Start Payment for selected shopping items
////
////    func goforPayNow(merchantCharge:String?, processingCharge:String?, totalAmount:String?, strShortDesc:String?, strCurrency:String?) {
////
////        var subtotal : NSDecimalNumber = 0
////
////        var merchant : NSDecimalNumber = 0
////
////        var processing : NSDecimalNumber = 0
////
////        subtotal = NSDecimalNumber(string: totalAmount)
////
////        // Optional: include payment details
////        if (merchantCharge != nil) {
////            merchant = NSDecimalNumber(string: merchantCharge)
////        }
////
////        if (processingCharge != nil) {
////            processing = NSDecimalNumber(string: processingCharge)
////        }
////
////        var description = strShortDesc
////
////        if (description == nil) {
////            description = ""
////        }
////
////        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: merchant, withTax: processing)
////
////        let total = subtotal.adding(merchant).adding(processing)
////
////        let payment = PayPalPayment(amount: total, currencyCode: strCurrency!, shortDescription: selectedCharity?.name ?? description!, intent: .sale)
////
////        payment.items = [PayPalItem(name: selectedCharity?.name ?? "", withQuantity: 1, withPrice: NSDecimalNumber(string: totalAmount), withCurrency: "USD", withSku: "")]
////
////        payment.paymentDetails = paymentDetails
////        self.payPalConfig.acceptCreditCards = self.acceptCreditCards();
////
////        if self.payPalConfig.acceptCreditCards == true {
////            print("We are able to do the card payment")
////        }
////
////        if (payment.processable) {
////            let objVC = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
////            self.present(objVC!, animated: true, completion: { () -> Void in
////                print("Paypal Presented")
////            })
////        }
////        else {
////            print("Payment not processalbe: \(payment)")
////        }
////
////    }
////
////}
//
//extension SearchByLocation: UITextFieldDelegate{
//
//
//}
////
