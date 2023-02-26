//
//  SearchByNameVC.swift
//  iDonate
//
//  Created by Im043 on 15/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireImage
import TKFormTextField
import Braintree
import BraintreeDropIn


class SearchByNameVC: BaseViewController,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate,UITextFieldDelegate {
    
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
    @IBOutlet var  typeScrollbtn: UIButton!
    @IBOutlet weak var searchBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollcontraint: NSLayoutConstraint!
    @IBOutlet var noresultsview: UIView!
    @IBOutlet var selectedlbl: UILabel!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var amountText: TKFormTextField!
    @IBOutlet var continuePaymentBTn : UIButton!
    
    @IBOutlet var titlelbl: UILabel!


    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

    @IBOutlet var noresultMEssage: UILabel!
    @IBOutlet var locationBtn: UIButton!
    
    var categoryCode = [String]()
    var subCategoryCode = [String]()
    var childCategory = [String]()
    var deductible = String()
    
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
    weak var payDelegate: paymentDelegate?
    
    var selectedCharity:charityListArray? = nil
    var pageCount = 1
    var searchedName = ""
    var searchEnabled = "false"
    var incomeFrom = ""
    var incomeTo = ""
    
    var previousPageCount = 1
    var comingFromType = false

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

    fileprivate func changePlaceholderText(_ searchBarCustom: UISearchBar) {
        searchBarCustom.placeholder = "Enter nonprofit / charity name"
        searchBarCustom.set(textColor: .white)
        searchBarCustom.setTextField(color: UIColor.clear)
        searchBarCustom.setPlaceholder(textColor: .white)
        searchBarCustom.setSearchImage(color: .white)
        searchBarCustom.setClearButton(color: .white)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }
        else{
            self.scrollcontraint.constant = 80
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        iDonateClass.sharedClass.customSearchBar(searchBar: searchBar)
        
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        mytapGestureRecognizer.cancelsTouchesInView = false
        mytapGestureRecognizer.delegate = self
        
        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
        mytapGestureRecognizer1.numberOfTapsRequired = 1
        mytapGestureRecognizer1.cancelsTouchesInView = false
        self.blurView.addGestureRecognizer(mytapGestureRecognizer1)
        
        self.containerView.addGestureRecognizer(mytapGestureRecognizer)
        
        // 1.
        containerView.translatesAutoresizingMaskIntoConstraints = false
        // headerView is your actual content.

        // 2.
        self.searchTableView.tableHeaderView = containerView
        // 3.
        containerView.centerXAnchor.constraint(equalTo: self.searchTableView.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.searchTableView.widthAnchor, constant: -10).isActive = true
        containerView.topAnchor.constraint(equalTo: self.searchTableView.topAnchor).isActive = true
        // 4.
        self.searchTableView.tableHeaderView?.layoutIfNeeded()
        self.searchTableView.tableHeaderView = self.searchTableView.tableHeaderView
        
        self.searchTableView.isScrollEnabled = true
        
        iDonateClass.sharedClass.customSearchBar(searchBar: searchBar)
        iDonateClass.sharedClass.customSearchBar(searchBar: searchScrollBar)
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            userID = myPeopleList.userID
        }
        
        self.amountText.placeholder = ""
        self.amountText.text = "$ 10"
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
        
        changePlaceholderText(searchBar)
        
        changePlaceholderText(searchScrollBar)
        
        if comingFromType == false{
            self.titlelbl.text = "SEARCH BY NAME"
        } else {
            self.titlelbl.text = "SEARCH BY TYPE"
        }
        
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil) {
            UserDefaults.standard.removeObject(forKey: "SelectedType")
        }
        self.previousPageCount = self.pageCount
        
        UserDefaults.standard .set("", forKey: "latitude")
        UserDefaults.standard .set("", forKey: "longitude")
        UserDefaults.standard .set("", forKey: "locationname")
        
        lattitude  = ""
        longitute = ""
        locationSearch = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
            
        if lattitude != "\(UserDefaults.standard.value(forKey: "latitude") ?? "")" {
            lattitude  = UserDefaults.standard.value(forKey: "latitude") as! String
            longitute = UserDefaults.standard.value(forKey: "longitude") as! String
            locationSearch = UserDefaults.standard.value(forKey: "locationname") as! String
            self.charityWebSerice()
        }
                
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
            nameScrollbtn.isSelected = true
            namebtn.isSelected =  true
            typeScrollbtn.isSelected = true
            selectedlbl.text = ((UserDefaults.standard.value(forKey:"SelectedType")) as! String)
        } else{
            typebtn.isSelected = false
        }
        
        searchScrollBar.placeholder = "Enter nonprofit/charity name"
        searchBar.placeholder = "Enter nonprofit/charity name"
        
        searchBar.text = locationSearch
        searchScrollBar.text = locationSearch
        
        self.charityWebSerice()

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
    
    // MARK:scrollview delegates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.contentOffset.y < 80) {
            
            self.searchBarView.isHidden = true
            menuBtn.isHidden = false
            navIMage.isHidden = false
            self.searchBarConstraint.constant = 100

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
    
    
    
    
    // MARK:button actions
    @IBAction func filterAction(_ sender:UIButton) {
        
        if(sender.tag == 0){
            UIView.animate(withDuration: 1, animations: {
                
                if(iDonateClass.hasSafeArea){
                    self.scrollcontraint.constant = 100
                    self.searchBarConstraint.constant = 100

                }else{
                    self.scrollcontraint.constant = 120
                    self.searchBarConstraint.constant = 120
                }
                self.innersearchBarView.isHidden = false
            })
            sender.tag = 1
            
        } else {
            sender.tag = 0
            
            if(iDonateClass.hasSafeArea) {
                self.scrollcontraint.constant = 60
                self.searchBarConstraint.constant = 60

            } else{
                self.scrollcontraint.constant = 60
                self.searchBarConstraint.constant = 100

            }
            
            self.innersearchBarView.isHidden = true
            
        }
    }
    
    @objc func myTapAction(recognizer: UITapGestureRecognizer) {
        searchBar.placeholder = "Enter nonprofit/charity name"
        searchBar .resignFirstResponder()
    }
    
    @objc func backAction(_sender:UIButton)  {
    
        if longitute != "", lattitude != "", locationSearch != "Nonprofits"{
            longitute = ""
            lattitude = ""
            locationSearch = "Nonprofits"
            userID = ""
            selectedIndex = -1
            self.charityWebSerice()
        } else if searchedName != ""{
            self.searchBar.text = ""
            self.searchScrollBar.text = ""
            searchedName = ""
            locationSearch = "Nonprofits"
            searchBar.placeholder = "Enter nonprofit / charity name"
            searchScrollBar.placeholder = "Enter nonprofit / charity name"
            nameScrollbtn.isSelected = false
            nameFlg = false
            self.charityWebSerice()
        }
        else {
            self.tabBarController?.selectedIndex = 0
            self.navigationController?.popViewController(animated: true)
        }
        
        searchBar.text = ""
        searchScrollBar.text = ""
                
    }
    
    @objc func cancelView(recognizer: UITapGestureRecognizer) {
        self.view .endEditing(true)
    }
    
    @IBAction func cancelAction(_ sender:UIButton) {
        blurView .removeFromSuperview()
    }
    
    @IBAction func locationAction(_ sender:UIButton) {
        if(sender.isSelected) {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
    }
    
    @IBAction func typeAction(_ sender:UIButton) {
        sender.isSelected = true
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
        vc?.address = locationSearch
        vc?.latitude = lattitude
        vc?.longitude = longitute
        vc?.countryCode = ""
        vc?.comingFromType = comingFromType
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func nameAction(_ sender:UIButton)  {
        
        self.view.endEditing(true)
        searchBar .resignFirstResponder()
        searchedName = ""
        self.searchBar.text = ""
        self.searchScrollBar.text = ""
        searchBar.placeholder = "Enter City/Sate"
        searchScrollBar.placeholder = "Enter City/Sate"
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GooglePlaceSearchViewController") as? GooglePlaceSearchViewController
        vc?.boundaryForPlaces = "US"
        vc?.placesDelegate = self
        self.navigationController?.pushViewController(vc!, animated: true)

//        if(sender.isSelected) {
//            sender.isSelected = false
//            searchBar.placeholder = "Enter nonprofit/charity name"
//            searchScrollBar.placeholder = "Enter nonprofit/charity name"
//            nameScrollbtn.isSelected = false
//            namebtn.isSelected = false
//            typeScrollbtn.isSelected = false
//            typebtn.isSelected = false
//            selectedlbl.text = ""
//            nameFlg = true
//
//        } else {
//            searchBar.placeholder = "Enter City/State"
//            searchScrollBar.placeholder = "Enter City/State"
//            sender.isSelected = true
//            nameScrollbtn.isSelected = true
//            namebtn.isSelected = true
//            nameFlg = false
//        }
        
    }
    
    @IBAction func nameSCrollAction(_ sender:UIButton)  {
        
        self.searchBar.text = ""
        self.searchScrollBar.text = ""
        
        self.view.endEditing(true)
        
//        if(sender.isSelected) {
//            sender.isSelected = false
//            searchBar.placeholder = "Enter nonprofit/charity name"
//            searchScrollBar.placeholder = "Enter nonprofit/charity name"
//            namebtn.isSelected = false
//            nameFlg = true
//        }
//        else {
//            searchBar.placeholder = "Search by city/state"
//            searchScrollBar.placeholder = "Search by city/state"
//            sender.isSelected = true
//            namebtn.isSelected = true
//            nameFlg = false
//        }
        
        searchBar .resignFirstResponder()
        searchedName = ""
        self.searchBar.text = ""
        self.searchScrollBar.text = ""
        searchBar.placeholder = "Enter City/Sate"
        searchScrollBar.placeholder = "Enter City/Sate"
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GooglePlaceSearchViewController") as? GooglePlaceSearchViewController
        vc?.boundaryForPlaces = "US"
        vc?.placesDelegate = self
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func likeAction(_ sender:UIButton)  {
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            var likeCount:String = ""
            userID = myPeopleList.userID
            let charityObject = charityListArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                likeCount = "0"
            }
            else {
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
            let charityObject = charityListArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                followCount = "0"
            } else {
                followCount = "1"
                sender.isSelected = true
            }
            selectedIndex = sender.tag
            followAction(follow: followCount, charityId: charityObject.id!)
        } else{
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
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

            AF.request(request).responseJSON {
                (response) in
                
                switch response.result {
            
                    case .success(let value) :
                        
                        MBProgressHUD.hide(for: self.view, animated: true)

                        if(self.isFiltering) {
                            self.selectedCharity = self.filterdCharityListArray?[sender.tag]
                        } else {
                            self.selectedCharity = self.charityListArray?[sender.tag]
                        }
                        
                        let drop =  BTDropInRequest()
                        drop.vaultManager = true
                        drop.paypalDisabled = false
                        drop.cardDisabled = false
                    print(drop)
                        let dropIn = BTDropInController(authorization: "\(value)", request: drop)
                        { (controller, result, error) in
                            if (error != nil) {
                                print("ERROR")
                            } else if (result?.isCancelled == true) {
                                print("CANCELLED")
                            } else if let result = result {
                                
                                let amount = self.amountText.text?.replacingOccurrences(of: "$", with: "")
                                
                                let amountWithoutDollar = amount!.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                guard Double(amountWithoutDollar) != 0 else {
                                    return
                                }
                                
                                let processingValue = self.calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 1)
                                
                                let amountWithProcessingValue = (Double(amountWithoutDollar) ?? 0) + processingValue
                                
                                let merchantChargesValue = self.calculatePercentage(value: amountWithProcessingValue ,percentageVal: 2.9) + 0.30
                                
                                let totalAmount = amountWithProcessingValue + merchantChargesValue
                           
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
                                else {

                                }

                                
                            }
                            controller.dismiss(animated: true, completion: nil)
                        }
                        self.present(dropIn!, animated: true, completion: nil)

                    case .failure(let error) :
                        print(error)
                }
            }
            
              

//                let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
//                payPalDriver.appSwitchDelegate = self // Optional
//                payPalDriver.viewControllerPresentingDelegate = self
//
//                let amount = self.amountText.text?.replacingOccurrences(of: "$", with: "")
//
//                let request = BTPayPalRequest(amount: (self.amountText.text?.replacingOccurrences(of: "$", with: ""))!)
//
//                request.displayName = "i2~Donate"
//
//                request.billingAgreementDescription = "Donate using Paypal account" //Displayed in customer's PayPal account
//                request.currencyCode = "USD"
//
//                payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) in
//
//                    MBProgressHUD.hide(for: self.view, animated: true)
//
//                    if let tokenizedPayPalAccount = tokenizedPayPalAccount {
//
//                        print(tokenizedPayPalAccount.nonce)
//
//                        if let data = UserDefaults.standard.data(forKey: "people"),
//                            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
//                            print(myPeopleList.name)
//                            // Joe 10
//
//                            let postDict: Parameters = ["user_id":myPeopleList.userID,
//                                                        "token":myPeopleList.token,
//                                                        "charity_id":self.selectedCharity?.id ?? "",
//                                                        "charity_name": self.selectedCharity?.name ?? "",
//                                                        "transaction_id":tokenizedPayPalAccount.nonce,
//                                                        "amount":amount ?? "0",
//                                                        "status":"approved"]
//
//                            let paymentUrl = String(format: URLHelper.iDonatePayment)
//
//                            WebserviceClass.sharedAPI.performRequest(type: paymentModel.self, urlString: paymentUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
//
//                                MBProgressHUD.hide(for: self.view, animated: true)
//
//                                print("payment response", response)
//
//                                let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
//                                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
//                                let messageAttrString = NSMutableAttributedString(string:"Payment Done Successfully", attributes: messageFont)
//                                alertController.setValue(messageAttrString, forKey: "attributedMessage")
//                                let contact = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
//                                    self.blurView.removeFromSuperview()
//                                }
//                                alertController.addAction(contact)
//                                self.present(alertController, animated: true, completion: nil)
//
//                                print("Result: \(String(describing: response))") // response serialization result
//
//
//                            }) { (response) in
//
//                            }
//                        }
//                        else {
//
//                        }
//                    }
//                    else {
//                        // Buyer canceled payment approval
//                        MBProgressHUD.hide(for: self.view, animated: false)
//                    }

            }
            
//            self.configurePaypal(strMarchantName: "i2~Donate")
//            
//            guard let amount = amountText.text else {
//                return
//            }
//            
//            let amountWithoutDollar = amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
//
//            guard Double(amountWithoutDollar) != 0 else {
//                return
//            }
//            
//            let processingValue = calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 1)
//            
//            let merchantChargesValue = calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 2.9) + 0.30
//            
//            let totalAmount = (Double(amountWithoutDollar) ?? 0) + processingValue + merchantChargesValue
//
//            if(isFiltering) {
//                self.selectedCharity = filterdCharityListArray?[sender.tag]
//            } else {
//                self.selectedCharity = charityListArray?[sender.tag]
//            }
//
//            processingCharges.donationAmountValue.text = "$ "+amountWithoutDollar
//            processingCharges.processingFeeValue.text = "$ "+String(format: "%.2f", processingValue)
//            processingCharges.merchantChargesValue.text = "$ "+String(format: "%.2f", merchantChargesValue)
//            processingCharges.totalAmountValue.text = "$ "+String(format: "%.2f", totalAmount)
//
//            self.goforPayNow(merchantCharge: String(format: "%.2f", merchantChargesValue), processingCharge: String(format: "%.2f", processingValue), totalAmount: amountWithoutDollar, strShortDesc: "Paypal", strCurrency: "USD")
//        }
            
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        donateFlag = true
        
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    @IBAction func advancedSearch(_ sender:UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "newcontrollerID") as? NewViewfromadvancedSearchViewController
            vc?.address = locationSearch
            vc?.latitude = lattitude
            vc?.longitude = longitute
            vc?.countryCode = ""
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isFiltering){
            return (filterdCharityListArray?.count)!
        } else{
            return charityListArray?.count ?? 0
        }
        
    }
    
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
            let url = URL(string: charity.logo!)!
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
        cell.donateBtn.addTarget(self, action: #selector(donateAction), for: .touchUpInside)
        
        if(charity.liked == "0") {
            cell.likeBtn.isSelected = false
        } else{
            cell.likeBtn.isSelected = true
        }
        
        if(charity.followed == "0"){
            cell.followingBtn.isSelected = false
            cell.followingBtn.setTitle("Follow", for: .normal)
        } else{
            cell.followingBtn.isSelected = true
            cell.followingBtn.setTitle("Following", for: .normal)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let charity: charityListArray
        
        if(isFiltering) {
            charity = (filterdCharityListArray?[indexPath.row])!
        } else{
            charity = charityListArray![indexPath.row]
        }
        
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
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(nameFlg == false){
            self.view.endEditing(true)
            searchBar .resignFirstResponder()
            searchedName = ""
            self.searchBar.text = ""
            self.searchScrollBar.text = ""
            searchBar.placeholder = "Enter City/Sate"
            searchScrollBar.placeholder = "Enter City/Sate"
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GooglePlaceSearchViewController") as? GooglePlaceSearchViewController
            vc?.boundaryForPlaces = "US"
            vc?.placesDelegate = self
            self.navigationController?.pushViewController(vc!, animated: true)
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
    
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        isFiltering = false
//        searchTableView.reloadData()
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        isFiltering = false
//        searchTableView.reloadData()
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            searchedName = searchText
            self.searchBar.text = searchText
            self.searchScrollBar.text = searchText
            self.charityWebSerice()
        } else {
            self.searchBar.text = searchText
            self.searchScrollBar.text = searchText
            searchedName = ""
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
    
    func charityLikeResponseMethod(){
        if(self.charityLikeResponse?.status == 1) {
           self.pageCount = 1
           self.charityWebSerice()
        }
    }
    
    func charityWebSerice() {
        
        let postDict: Parameters = ["name":searchedName,
                                    "latitude":lattitude,
                                    "longitude":longitute,
                                    "page":pageCount,
                                    "address":locationSearch,
                                    "category_code":categoryCode ,
                                    "deductible":deductible,
                                    "income_from":incomeFrom,
                                    "income_to":incomeTo,
                                    "country_code":"",
                                    "sub_category_code":subCategoryCode ,
                                    "child_category_code":childCategory ,
                                    "user_id":userID]
        
        let charityListUrl = String(format: URLHelper.iDonateCharityList)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        WebserviceClass.sharedAPI.performRequest(type: CharityModel.self, urlString: charityListUrl, methodType:  HTTPMethod.post, parameters: postDict, success: { (response) in
            
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
            
            self.responsemethod()
            
            print("Result: \(String(describing: response))") // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }) { (_) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }
    
    func responsemethod() {
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
    
    private func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.location(in: searchTableView)
            return (searchTableView.indexPathForRow(at: location) == nil)
        }
        return true
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

extension SearchByNameVC: SearchByCityDelegate{
    
    func getCharityListFromPlaces(inputDetails: [String : String]) {
           print("inputDetails", inputDetails)
           
           self.searchEnabled = inputDetails["placesFlag"]!
           self.lattitude  = inputDetails["latitude"]! //UserDefaults.standard.value(forKey: "latitude") as! String
           self.longitute = inputDetails["longitude"]! //UserDefaults.standard.value(forKey: "longitude") as! String
           self.locationSearch = inputDetails["locationname"]! //UserDefaults.standard.value(forKey: "locationname") as! String
           self.pageCount = 1
           self.charityWebSerice()
           
       }
}

extension SearchByNameVC {
    
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
        
        let processingValue = calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 1)
        
        let amountWithProcessingValue = (Double(amountWithoutDollar) ?? 0) + processingValue
        
        let merchantChargesValue = calculatePercentage(value: amountWithProcessingValue ,percentageVal: 2.9) + 0.30
        
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

//extension SearchByNameVC: PayPalPaymentDelegate {
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
// MARK: - BTAppSwitch Delegate Method
extension SearchByNameVC: BTAppSwitchDelegate {
    
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        showLoadingUI()
        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingUI), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        hideLoadingUI()
    }

    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {

    }

    // MARK: - Private methods

    func showLoadingUI() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    //    MARK: - Private Methods
    @objc func hideLoadingUI() {
        MBProgressHUD.hide(for: self.view, animated: true)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

// MARK: - BT View Controller Presenting Delegate Method
extension SearchByNameVC: BTViewControllerPresentingDelegate {
    /*!
     @brief The payment driver requires dismissal of a view controller.
     
     @discussion Your implementation should dismiss the viewController, e.g. via
     `dismissViewControllerAnimated:completion:`
     
     @param driver         The payment driver
     @param viewController The view controller to be dismissed
     */
    @available(iOS 2.0, *)
    public func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
    }
    
    /*!
     @brief The payment driver requires presentation of a view controller in order to proceed.
     
     @discussion Your implementation should present the viewController modally, e.g. via
     `presentViewController:animated:completion:`
     
     @param driver         The payment driver
     @param viewController The view controller to present
     */
    @available(iOS 2.0, *)
    public func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
}

extension UISearchBar {

    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func set(textColor: UIColor) { if let textField = getTextField() { textField.textColor = textColor } }
    func setPlaceholder(textColor: UIColor) { getTextField()?.setPlaceholder(textColor: textColor) }
    func setClearButton(color: UIColor) { getTextField()?.setClearButton(color: color) }

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

    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

private extension UITextField {

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


    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
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

    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    var placeholderLabel: UILabel? { return value(forKey: "placeholderLabel") as? UILabel }

    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else { return }
        let label = Label(label: placeholderLabel, textColor: textColor)
        setValue(label, forKey: "placeholderLabel")
    }

    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}
